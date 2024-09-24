import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/firebase_options.dart';
import 'package:mynotes/main.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    super.initState();

    _checkUser();

    _email = TextEditingController();
    _password = TextEditingController();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();

    super.dispose();
  }

  void _checkUser() {
    final auth = FirebaseAuth.instance;

    final authStateChanges = auth.authStateChanges();

    authStateChanges.listen((User? user) {
      // If no user is signed in, navigate to LoginView
      if (user == null) {
        print("There's no user logged in");
      } else {
        print("Logged user: $user");
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        backgroundColor: Colors.blueAccent,
        titleTextStyle: const TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: Colors.teal),
        elevation: 5,
        centerTitle: true,
      ),
      body: FutureBuilder(
          future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          ),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 15.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _email,
                        decoration: const InputDecoration(
                            labelText: "Enter your email",
                            border: OutlineInputBorder()),
                        keyboardType: TextInputType.emailAddress,
                        enableSuggestions: false,
                        autocorrect: false,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _password,
                        decoration: const InputDecoration(
                            labelText: "Enter your password",
                            border: OutlineInputBorder()),
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () async {
                          final email = _email.text;
                          final password = _password.text;

                          checkLogin(email, password);
                        },
                        style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 60, vertical: 15)),
                        child: const Text("Login"),
                      ),
                    ],
                  ),
                );
              default:
                return const Text("Loading....");
            }
          }),
    );
  }

  void _showAlert(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                onPressed: Navigator.of(context).pop,
                child: const Text("Ok"),
              )
            ],
          ),
        );
      },
    );
  }

  void checkLogin(String email, String password) async {
    // await FirebaseAuth.instance.signOut();

    if (email.isEmpty) {
      _showAlert(context, "Error", "Email field is empty");
      return;
    }

    if (password.isEmpty) {
      _showAlert(context, "Error", "Password field is empty");
      return;
    }

    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print(userCredential);
      if (mounted) {
        _showAlert(context, "", "$email logged in successfully!");
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'user-not-found') {
        if (mounted) {
          _showAlert(context, "Error", "No user found for that email.");
        }
      } else if (error.code == 'wrong-password') {
        if (mounted) {
          _showAlert(
              context, "Error", "Wrong password provided for that user.");
        }
      } else {
        if (mounted) {
          _showAlert(context, "Error", error.code);
        }
      }
    } catch (error) {
      print(error);
      if (mounted) {
        _showAlert(context, "Error", error.toString());
      }
    }
  }
}

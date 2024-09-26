import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/firebase_options.dart';
import 'package:mynotes/views/home_page.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
        backgroundColor: Colors.blueAccent,
        titleTextStyle: const TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: Colors.white),
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
                        child: const Text("Register"),
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

  void _showAlert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: AlertDialog(
            title: const Text("Error"),
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
    if (email.isEmpty) {
      _showAlert(context, "Email field is empty");
      return;
    }

    if (password.isEmpty) {
      _showAlert(context, "Password field is empty");
      return;
    }

    try {
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print(userCredential);
      if (mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil("/home/", (route) => false);
      }
    } catch (error) {
      if (mounted) {
        _showAlert(context, error.toString());
      }
    }
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/firebase_options.dart';
import 'package:mynotes/views/login_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const LoginView(),
    ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    _checkUser();
  }

  void _checkUser() {
    final auth = FirebaseAuth.instance;

    final authStateChanges = auth.authStateChanges();

    authStateChanges.listen((User? user) {
      // If no user is signed in, navigate to LoginView
      if (user == null) {
        Navigator.pop(context);
      } else {
        print("Logged user: $user");
      }
    });
  }

  void checkEmailVerification() {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.emailVerified ?? false) {
      print("You are a verified user");
    } else {
      print("You need to verify your email");
    }
    print(user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Home"),
          backgroundColor: Colors.blueAccent,
          titleTextStyle: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          elevation: 5,
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: TextButton(
                  onPressed: () async {
                    signOut();
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  child: const Text("Sign out")),
            )
          ],
        ),
        body: const Center(
          child: Text("Logged in"),
        ));
  }

  void signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (error) {
      print("Signout error: $error");
    }
  }
}

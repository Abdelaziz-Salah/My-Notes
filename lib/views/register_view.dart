import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'dart:developer';

import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/utilities/dialogs/error_dialog.dart';

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
        child: Column(
          children: [
            TextField(
              controller: _email,
              decoration: const InputDecoration(
                  labelText: "Enter your email", border: OutlineInputBorder()),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 60, vertical: 15)),
              child: const Text("Register"),
            ),
          ],
        ),
      ),
    );
  }

  void checkLogin(String email, String password) async {
    if (email.isEmpty) {
      showErrorDialog(context, "Email field is empty");
      return;
    }

    if (password.isEmpty) {
      showErrorDialog(context, "Password field is empty");
      return;
    }

    try {
      final userCredential = await AuthService.firebase().createUser(
        email: email,
        password: password,
      );
      log(userCredential.toString());
      if (mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(notesRoute, (route) => false);
      }
    } on InvalidEmailAuthException {
      if (mounted) {
        showErrorDialog(context, "Invalid Email");
      }
    } on WeakPasswordAuthException {
      if (mounted) {
        showErrorDialog(context, "Weak Password");
      }
    } on EmailAlreadyInUseAuthException {
      if (mounted) {
        showErrorDialog(context, "Email is already in use");
      }
    } on GenericAuthException catch (error) {
      if (mounted) {
        showErrorDialog(context, error.toString());
      }
    } catch (error) {
      if (mounted) {
        showErrorDialog(context, error.toString());
      }
    }
  }
}

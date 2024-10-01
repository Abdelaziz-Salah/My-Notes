import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_service.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
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
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Text("Please verify your email address"),
              TextButton(
                onPressed: () async {
                  await AuthService.firebase().sendEmailVerification();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blueAccent,
                ),
                child: const Text("Send email verification"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

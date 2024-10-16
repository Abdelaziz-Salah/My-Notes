import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';
import 'package:mynotes/utilities/dialogs/error_dialog.dart';
import 'package:mynotes/utilities/dialogs/password_reset_email_sent_dialog.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _email;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgotPassword) {
          if (state.error != null) {
            showErrorDialog(context, state.error!);
          } else if (state.hasSentEmail) {
            _email.clear;
            await showPasswordResetSentDialog(context);
          }
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Forgot Password"),
              backgroundColor: Colors.blueAccent,
              titleTextStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
              elevation: 5,
              centerTitle: true,
            ),
            body: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
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
                    autofocus: true,
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () async {
                      final email = _email.text;
                      _resetPassword(email);
                    },
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 60, vertical: 15)),
                    child: const Text("Reset password"),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () async {
                      context.read<AuthBloc>().add(AuthEventShouldLogin());
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blueAccent,
                    ),
                    child: const Text("Back to login page"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _resetPassword(String email) async {
    if (email.isEmpty) {
      showErrorDialog(context, "Email field is empty");
      return;
    }

    context.read<AuthBloc>().add(AuthEventForgotPassword(email: email));
  }
}

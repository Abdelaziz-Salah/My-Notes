import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';
import 'package:mynotes/utilities/dialogs/error_dialog.dart';
import 'package:mynotes/utilities/dialogs/loading_dialog.dart';
import 'package:mynotes/views/register_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  CloseDialog? _closeDialogHandle;

  @override
  void initState() {
    super.initState();

    _email = TextEditingController();
    _password = TextEditingController();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          final closeDialog = _closeDialogHandle;

          if (!state.isLoading && closeDialog != null) {
            closeDialog();
            _closeDialogHandle = null;
          } else if (state.isLoading && closeDialog == null) {
            _closeDialogHandle = showLoadingDialog(
              context: context,
              text: "Loading...",
            );
          }

          if (state.error != null) {
            showErrorDialog(context, state.error!);
          }
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Login"),
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
                      _checkLogin(email, password);
                    },
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 60, vertical: 15)),
                    child: const Text("Login"),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthEventShouldRegister());
                    },
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.blueAccent),
                    child: const Text("Create new account"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _checkLogin(String email, String password) async {
    if (email.isEmpty) {
      showErrorDialog(context, "Email field is empty");
      return;
    }

    if (password.isEmpty) {
      showErrorDialog(context, "Password field is empty");
      return;
    }

    // try {
    // final user = await AuthService.firebase().logIn(
    //   email: email,
    //   password: password,
    // );

    // log(user.toString());

    context
        .read<AuthBloc>()
        .add(AuthEventLogin(email: email, password: password));
    // if (mounted) {
    //   Navigator.of(context)
    //       .pushNamedAndRemoveUntil(notesRoute, (route) => false);
    // }
    // } catch (error) {
    //   if (mounted) {
    //     showErrorDialog(context, error.toString());
    //   }
    // }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/bloc/login/login_bloc.dart';
import 'package:mynotes/bloc/login/login_events.dart';
import 'package:mynotes/bloc/login/login_states.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(),
      child: LoginForm(),
    );
  }
}

class LoginForm extends StatelessWidget {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccessState) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Login Successful")));
        } else if (state is LoginErrorState) {
          // Handle login error (e.g., show error message)
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.errorMessage)));
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Login"),
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              centerTitle: true,
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(labelText: "Username"),
                    onChanged: (value) {
                      context
                          .read<LoginBloc>()
                          .add(UsernameChangedEvent(value));
                    },
                  ),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    onChanged: (password) {
                      context
                          .read<LoginBloc>()
                          .add(PasswordChangedEvent(password));
                    },
                  ),
                  SizedBox(height: 20),
                  if (state is LoginValidatingState)
                    CircularProgressIndicator(),
                  if (state is! LoginValidatingState)
                    ElevatedButton(
                      onPressed: () {
                        final username = _usernameController.text;
                        final password = _passwordController.text;
                        context.read<LoginBloc>().add(
                              LoginSubmittedEvent(username, password),
                            );
                      },
                      child: Text('Login'),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

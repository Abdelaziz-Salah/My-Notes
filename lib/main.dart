import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/bloc/login/login_observer.dart';
import 'package:mynotes/bloc/view/login_page.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/views/home_page.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/create_update_note_view.dart';
import 'package:mynotes/views/register_view.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/views/verify_email_view.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await AuthService.firebase().initialize();

//   runApp(
//     MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
//         useMaterial3: true,
//       ),
//       home: const LoginView(),
//       routes: {
//         homeRoute: (context) => const HomePage(),
//         verifyEmailRoute: (context) => const VerifyEmailView(),
//         registerRoute: (context) => const RegisterView(),
//         loginRoute: (context) => const LoginView(),
//         createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
//       },
//     ),
//   );
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = const LoginObserver();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    ),
  );
}

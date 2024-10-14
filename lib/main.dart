import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc_observer.dart';
import 'package:mynotes/services/auth/firebase_auth_provider.dart';
import 'package:mynotes/views/home_page.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/create_update_note_view.dart';
import 'package:mynotes/views/notes_view.dart';
import 'package:mynotes/views/register_view.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/views/verify_email_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = const AuthBlocObserver();

  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const HomePage(),
      ),
      routes: {
        homeRoute: (context) => HomePage(),
        verifyEmailRoute: (context) => VerifyEmailView(),
        registerRoute: (context) => RegisterView(),
        loginRoute: (context) => LoginView(),
        createOrUpdateNoteRoute: (context) => CreateUpdateNoteView(),
        notesRoute: (context) => NotesView(),
      },
    ),
  );
}

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   Bloc.observer = const LoginObserver();
//   runApp(
//     MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
//         useMaterial3: true,
//       ),
//       home: const LoginPage(),
//     ),
//   );
// }

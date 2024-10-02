import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_service.dart';
import 'package:mynotes/views/verify_email_view.dart';
import 'dart:developer';
import 'package:mynotes/enums/menu_action.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final NotesService _notesService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    _checkUser();
    _notesService = NotesService();
    _notesService.open();
    super.initState();
  }

  @override
  void dispose() {
    _notesService.close();
    super.dispose();
  }

  void _checkUser() {
    final auth = FirebaseAuth.instance;

    final authStateChanges = auth.authStateChanges();

    authStateChanges.listen((User? user) {
      // If no user is signed in, navigate to LoginView
      if (user == null) {
        if (mounted) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil(loginRoute, (route) => false);
        }
      } else {
        log("Logged user: $user");
        if (user.emailVerified) {
          log("You are a verified user");
        } else {
          log("You need to verify your email");
          if (mounted) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const VerifyEmailView()));
          }
        }
      }
    });
  }

  void checkEmailVerification() {
    final user = AuthService.firebase().currentUser;
    if (user?.isEmailVerified ?? false) {
      log("You are a verified user");
    } else {
      log("You need to verify your email");
    }
    log(user.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
        backgroundColor: Colors.blueAccent,
        titleTextStyle: const TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        elevation: 5,
        centerTitle: true,
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) {
              _selectMenuItem(value);
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  value: MenuAction.logout,
                  child: Text("Logout"),
                )
              ];
            },
            iconColor: Colors.white,
          )
        ],
      ),
      body: FutureBuilder(
        future: _notesService.getOrCreateUser(email: userEmail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                stream: _notesService.allNotes,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Text("Waiting for all Notes.");
                    default:
                      return CircularProgressIndicator();
                  }
                },
              );
            default:
              return CircularProgressIndicator();
          }
        },
      ),
    );
  }

  void signOut() async {
    try {
      await AuthService.firebase().logout();
    } catch (error) {
      log("Signout error: $error");
    }
  }

  void _selectMenuItem(MenuAction action) {
    switch (action) {
      case MenuAction.logout:
        _showLogoutAlert(context);
    }
  }

  void _showLogoutAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: AlertDialog(
            title: const Text("Logout"),
            content: const Text("Are you sure you want to logout?"),
            actions: <Widget>[
              TextButton(
                onPressed: Navigator.of(context).pop,
                child: const Text("No"),
              ),
              TextButton(
                onPressed: signOut,
                child: const Text("Yes"),
              )
            ],
          ),
        );
      },
    );
  }
}

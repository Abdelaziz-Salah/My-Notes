import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_service.dart';
import 'package:mynotes/utilities/dialogs/logout_dialog.dart';
import 'package:mynotes/views/notes_list_view.dart';
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
          IconButton(
            onPressed: () {
              if (mounted) {
                Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
              }
            },
            icon: const Icon(Icons.add),
            color: Colors.white,
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) {
              _selectMenuItem(value);
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  value: MenuAction.deleteAll,
                  child: Text("Delete all"),
                ),
                const PopupMenuItem(
                  value: MenuAction.logout,
                  child: Text("Logout"),
                ),
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
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        final allNotes = snapshot.data as List<DatabaseNote>;
                        log("ALL Notes: $allNotes");
                        return NotesListView(
                          notes: allNotes,
                          onDeleteNote: (note) async {
                            await _notesService.deleteNote(id: note.id);
                          },
                          onTapNote: (note) {
                            Navigator.of(context).pushNamed(
                              createOrUpdateNoteRoute,
                              arguments: note,
                            );
                          },
                        );
                      } else {
                        return const Text("No Data Found");
                      }
                    default:
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                  }
                },
              );
            default:
              return const CircularProgressIndicator();
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

  void deleteAllNotes() async {
    try {
      await _notesService.deleteAllNotes();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      log("delete all notes error: $error");
    }
  }

  void _selectMenuItem(MenuAction action) {
    switch (action) {
      case MenuAction.logout:
        _showLogoutAlert(context);
      case MenuAction.deleteAll:
        _showDeleteAllAlert(context);
    }
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
                Navigator.of(context).pushNamedAndRemoveUntil(verifyEmailRoute, (route) => false);
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

  void _showLogoutAlert(BuildContext context) async {
    final shouldLogout = await showLogoutDialog(context);
    if (shouldLogout) {
      signOut();
    }
  }

  void _showDeleteAllAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: AlertDialog(
            title: const Text("Delete all notes"),
            content: const Text("Are you sure you want to delete all notes?"),
            actions: <Widget>[
              TextButton(
                onPressed: Navigator.of(context).pop,
                child: const Text("No"),
              ),
              TextButton(
                onPressed: deleteAllNotes,
                child: const Text("Yes"),
              )
            ],
          ),
        );
      },
    );
  }
}

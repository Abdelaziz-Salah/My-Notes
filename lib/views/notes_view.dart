import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/main.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/firebase_cloud_storage.dart';
import 'package:mynotes/utilities/dialogs/logout_dialog.dart';
import 'package:mynotes/views/notes_list_view.dart';
import 'dart:developer';
import 'package:mynotes/enums/menu_action.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  // late final NotesService _notesService;
  late final FirebaseCloudStorage _notesService;
  // String get userEmail => AuthService.firebase().currentUser!.email;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    // _notesService = NotesService();
    _notesService = FirebaseCloudStorage();

    // _notesService.open();
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
        body: StreamBuilder(
          stream: _notesService.allNotes(ownerUserId: userId),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.active:
                if (snapshot.hasData) {
                  final allNotes = snapshot.data as Iterable<CloudNote>;
                  log("ALL Notes: $allNotes");
                  return NotesListView(
                    notes: allNotes,
                    onDeleteNote: (note) async {
                      await _notesService.deleteNote(
                          documentId: note.documentId);
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
        ));
  }

  void signOut() async {
    // try {
    context.read<AuthBloc>().add(AuthEventLogout());
    // await AuthService.firebase().logout();
    // if (mounted) {
    //   Navigator.of(context)
    //       .pushNamedAndRemoveUntil(loginRoute, (route) => false);
    // }
    // } catch (error) {
    //   log("Signout error: $error");
    // }
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

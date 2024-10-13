import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/firebase_cloud_storage.dart';
import 'package:mynotes/utilities/dialogs/cannot_share_empty_note_dialog.dart';
import 'package:mynotes/utilities/generics/get_arguments.dart';
import 'package:share_plus/share_plus.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  late final TextEditingController _textController;
  // DatabaseNote? _note;
  // late final NotesService _notesService;

  CloudNote? _note;
  late final FirebaseCloudStorage _notesService;

  @override
  void initState() {
    // _notesService = NotesService();
    _notesService = FirebaseCloudStorage();
    _textController = TextEditingController();
    _setupTextControllerListener();
    super.initState();
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  // Future<DatabaseNote> createOrGetExistingNote(BuildContext context) async {
  //   final widgetNote = context.getArguments<DatabaseNote>();

  //   if (widgetNote != null) {
  //     _note = widgetNote;
  //     _textController.text = widgetNote.text;
  //     return widgetNote;
  //   }

  //   final existingNotes = _note;
  //   if (existingNotes != null) {
  //     return existingNotes;
  //   }
  //   final currentUser = AuthService.firebase().currentUser!;
  //   final email = currentUser.email;
  //   final owner = await _notesService.getUser(email: email);
  //   final note = await _notesService.createNote(owner: owner);
  //   _note = note;
  //   return note;
  // }

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArguments<CloudNote>();

    if (widgetNote != null) {
      _note = widgetNote;
      _textController.text = widgetNote.text;
      return widgetNote;
    }

    final existingNotes = _note;
    if (existingNotes != null) {
      return existingNotes;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final note = await _notesService.createNewNote(ownerUserId: currentUser.id);
    _note = note;
    return note;
  }

  // void _textControllerListener() async {
  //   final note = _note;
  //   if (note == null) {
  //     return;
  //   }
  //   final text = _textController.text;
  //   try {
  //     final updatedNote = await _notesService.updateNote(
  //       note: note,
  //       text: text,
  //     );
  //     _note = updatedNote;
  //   } catch (e) {
  //     log("Error updating Note $e");
  //   }
  // }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textController.text;
    try {
      await _notesService.updateNote(
        documentId: note.documentId,
        text: text,
      );
      // _note = updatedNote;
    } catch (e) {
      log("Error updating Note $e");
    }
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  // void _deleteNoteIfTextIsEmpty() {
  //   final note = _note;
  //   if (_textController.text.isEmpty && note != null) {
  //     _notesService.deleteNote(id: note.id);
  //   }
  // }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      _notesService.deleteNote(documentId: note.documentId);
    }
  }

  // void _saveNoteIfTextNotEmpty() async {
  //   final note = _note;
  //   if (_textController.text.isNotEmpty && note != null) {
  //     await _notesService.updateNote(
  //       note: note,
  //       text: note.text,
  //     );
  //   }
  // }

  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    if (_textController.text.isNotEmpty && note != null) {
      await _notesService.updateNote(
        documentId: note.documentId,
        text: _textController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Note"),
        backgroundColor: Colors.blueAccent,
        titleTextStyle: const TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () async {
              final text = _textController.text;
              if (_note == null || text.isEmpty) {
                await showCannotShareEmptyNoteErrorDialog(context);
              } else {
                Share.share(text);
              }
            },
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _setupTextControllerListener();
              return Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: _textController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    hintText: "Enter your text here...",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              );
            default:
              return const Center(
                child: CircularProgressIndicator(),
              );
          }
        },
      ),
    );
  }
}

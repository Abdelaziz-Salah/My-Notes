import 'package:flutter/material.dart';
import 'package:mynotes/services/crud/notes_service.dart';
import 'package:mynotes/utilities/dialogs/delete_dialog.dart';

typedef DeleteNoteCallback = void Function(DatabaseNote note);

class NotesListView extends StatelessWidget {
  final List<DatabaseNote> notes;
  final DeleteNoteCallback onDeleteNote;
  const NotesListView(
      {super.key, required this.notes, required this.onDeleteNote});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      separatorBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
          child: Divider(
            thickness: 1,
            color: Colors.grey,
          ),
        );
      },
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final text = notes[index].text;
        return Dismissible(
          key: Key(notes[index].id.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          confirmDismiss: (direction) async {
            // Delete Note
            final shouldDelete = await showDeleteDialog(context);
            if (shouldDelete) {
              onDeleteNote(notes[index]);
              return true;
            } else {
              return false;
            }
          },
          child: ListTile(
            title: Text(
              text,
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/utilities/dialogs/delete_dialog.dart';

// typedef NoteCallback = void Function(DatabaseNote note);
typedef NoteCallback = void Function(CloudNote note);


class NotesListView extends StatelessWidget {
  // final List<DatabaseNote> notes;
  final Iterable<CloudNote> notes;
  final NoteCallback onDeleteNote;
  final NoteCallback onTapNote;
  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTapNote,
  });

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
        // final note = notes[index];
        final note = notes.elementAt(index);
        return Dismissible(
          // key: Key(note.id.toString()),
          key: Key(note.documentId),
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
              onDeleteNote(notes.elementAt(index));
              return true;
            } else {
              return false;
            }
          },
          child: ListTile(
            title: Text(
              note.text,
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => onTapNote(note),
          ),
        );
      },
    );
  }
}

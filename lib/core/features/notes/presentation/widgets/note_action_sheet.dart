import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/domain/entities/note.dart';
import 'package:notes_app/core/features/notes/presentation/provider/notes_provider.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/note_action_options.dart';
import 'package:provider/provider.dart';

class NoteActionSheet extends StatelessWidget {
  final Note note;

  const NoteActionSheet({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Actions', style: Theme.of(context).textTheme.titleMedium),

            const SizedBox(height: 8),

            NoteActionOptions(
              title: note.isPinned ? 'UnPin Note' : 'Pin Note',
              icon: note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              onTap: () async {
                await context.read<NotesProvider>().togglePin(note);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
            ),
            NoteActionOptions(
              title: 'Archive Note',
              icon: Icons.archive,
              onTap: () async {
                await context.read<NotesProvider>().archiveNote(note);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
            ),
            NoteActionOptions(
              title: 'Delete Note',
              icon: Icons.delete,
              onTap: () async {
                await context.read<NotesProvider>().moveToTrash(note);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
            ),
            NoteActionOptions(
              title: 'Cancel',
              icon: Icons.cancel,
              onTap: () async {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

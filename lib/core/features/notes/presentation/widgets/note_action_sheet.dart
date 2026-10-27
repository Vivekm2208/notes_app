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
    Future<void> performAction(
      Future<void> Function(NotesProvider provider) action,
    ) async {
      final provider = context.read<NotesProvider>();

      await action(provider);

      if (context.mounted) {
        Navigator.pop(context);
      }
    }

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
              onTap: () =>
                  performAction((provider) => provider.togglePin(note)),
            ),
            NoteActionOptions(
              title: 'Archive Note',
              icon: Icons.archive,
              onTap: () =>
                  performAction((provider) => provider.archiveNote(note)),
            ),
            NoteActionOptions(
              title: 'Delete Note',
              icon: Icons.delete,
              onTap: () =>
                  performAction((provider) => provider.moveToTrash(note)),
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

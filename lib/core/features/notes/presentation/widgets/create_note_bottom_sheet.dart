import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/domain/entities/note.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/create_note_option.dart';

class CreateNoteBottomSheet extends StatelessWidget {
  const CreateNoteBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Create New', style: Theme.of(context).textTheme.titleMedium),

            const SizedBox(height: 16),
            CreateNoteOption(
              icon: Icons.note_outlined,
              title: 'Text Note',
              subtitle: 'Write Notes Freely',
              onTap: () {
                Navigator.pop(context, NoteType.text);
              },
            ),
            const SizedBox(height: 16),
            CreateNoteOption(
              icon: Icons.checklist,
              title: 'Checklist',
              subtitle: 'Track tasks with ckeckbox',
              onTap: () {
                Navigator.pop(context, NoteType.checklist);
              },
            ),
          ],
        ),
      ),
    );
  }
}

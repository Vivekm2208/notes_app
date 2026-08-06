import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/domain/entities/note.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/checklist_preview.dart';
import 'package:notes_app/core/utils/date_formatter.dart';
import 'package:notes_app/core/utils/string_formatter.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.trailing,
    this.onTap,
  });

  final Note note;
  final VoidCallback? onTap;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final hasBeenEdited = note.createdAt != note.lastEdited;

    final displayText = hasBeenEdited
        ? 'Last Edited ${DateFormatter.format(note.lastEdited)}'
        : 'Created ${DateFormatter.format(note.createdAt)}';

    return Card(
      color: Color(note.colorValue),
      child: ListTile(
        onTap: onTap,
        title: Text(note.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            (note.type == NoteType.text
                ? Text(
                    note.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                : ChecklistPreview(items: note.checklistItems)),
            const SizedBox(height: 4),
            Text(StringFormatter.capitalize(note.category.name)),
            Text(displayText, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        trailing: trailing,
      ),
    );
  }
}

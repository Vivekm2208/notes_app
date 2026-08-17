import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/domain/entities/note.dart';
import 'package:notes_app/core/theme/app_radius.dart';
import 'package:notes_app/core/theme/app_spacing.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/checklist_preview.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/noted_color_dot.dart';
import 'package:notes_app/core/utils/date_formatter.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:notes_app/core/utils/string_formatter.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    this.trailing,
    this.onTap,
    this.onLongPress,
  });

  final Note note;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final hasBeenEdited = note.createdAt != note.lastEdited;

    final displayText = hasBeenEdited
        ? 'Last Edited ${DateFormatter.format(note.lastEdited)}'
        : 'Created ${DateFormatter.format(note.createdAt)}';

    return DottedBorder(
      options: RoundedRectDottedBorderOptions(
        radius: Radius.circular(NotedRadius.sm),
        color: Theme.of(context).colorScheme.outline,
        strokeWidth: 1,
        dashPattern: [4, 3],
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NotedRadius.sm),
        ),
        margin: EdgeInsets.zero,
        child: InkWell(
          onLongPress: onLongPress,
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(NotedSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    NotedColorDot(color: Color(note.colorValue)),
                    const SizedBox(width: NotedSpacing.xs),
                    Expanded(
                      child: Text(
                        StringFormatter.capitalize(note.title),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    if (note.isPinned == true)
                      Icon(
                        Icons.push_pin,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  ],
                ),
                const SizedBox(height: NotedSpacing.sm),
                note.type == NoteType.text
                    ? Text(
                        note.content,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      )
                    : ChecklistPreview(items: note.checklistItems),

                const SizedBox(height: NotedSpacing.md),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      displayText,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (note.reminderAt != null)
                      Icon(
                        Icons.notifications_none,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    if (trailing != null) trailing!,
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

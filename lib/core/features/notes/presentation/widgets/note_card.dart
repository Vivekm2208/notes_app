import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import 'package:notes_app/core/features/notes/domain/entities/note.dart';
import 'package:notes_app/core/features/notes/presentation/provider/notes_provider.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/checklist_preview.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/noted_color_dot.dart';
import 'package:notes_app/core/services/rich_text_converter.dart';
import 'package:notes_app/core/theme/app_radius.dart';
import 'package:notes_app/core/theme/app_spacing.dart';
import 'package:notes_app/core/utils/date_formatter.dart';
import 'package:notes_app/core/utils/string_formatter.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.viewType,
    this.trailing,
    this.onTap,
    this.onLongPress,
  });

  final Note note;
  final NoteViewType viewType;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Optional actions such as:
  /// Restore / Delete
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final hasBeenEdited = note.createdAt != note.lastEdited;
    debugPrint(
      'Note: ${note.id} | '
      'type: ${note.type} | '
      'format: ${note.contentFormat} | '
      'content: "${note.content}"',
    );

    final previewContent =
        note.contentFormat == NoteContentFormat.richText &&
            note.content.trim().isNotEmpty
        ? RichTextConverter.jsonToPlainText(note.content)
        : note.content;

    final displayText = hasBeenEdited
        ? 'Last Edited ${DateFormatter.format(note.lastEdited)}'
        : 'Created ${DateFormatter.format(note.createdAt)}';

    return DottedBorder(
      options: RoundedRectDottedBorderOptions(
        radius: Radius.circular(NotedRadius.sm),
        color: Theme.of(context).colorScheme.outline,
        strokeWidth: 1,
        dashPattern: const [4, 3],
      ),
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NotedRadius.sm),
        ),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(NotedRadius.sm),
          child: Padding(
            padding: const EdgeInsets.all(NotedSpacing.md),
            child: viewType == NoteViewType.gridView
                ? _buildGridCard(context, previewContent, displayText)
                : _buildListCard(context, previewContent, displayText),
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // GRID CARD
  // ----------------------------------------------------------

  Widget _buildGridCard(
    BuildContext context,
    String previewContent,
    String displayText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        _buildHeader(context),

        const SizedBox(height: NotedSpacing.sm),

        // Content
        Expanded(
          child: ClipRect(
            child: note.type == NoteType.text
                ? Text(
                    previewContent,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                  )
                : ChecklistPreview(items: note.checklistItems),
          ),
        ),

        const SizedBox(height: NotedSpacing.sm),

        // Footer
        _buildFooter(context, displayText),
      ],
    );
  }

  // ----------------------------------------------------------
  // LIST CARD
  // ----------------------------------------------------------

  Widget _buildListCard(
    BuildContext context,
    String previewContent,
    String displayText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        _buildHeader(context),

        const SizedBox(height: NotedSpacing.sm),

        // Content
        note.type == NoteType.text
            ? Text(
                previewContent,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              )
            : ChecklistPreview(items: note.checklistItems),

        const SizedBox(height: NotedSpacing.md),

        // Footer
        _buildFooter(context, displayText),
      ],
    );
  }

  // ----------------------------------------------------------
  // HEADER
  // ----------------------------------------------------------

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // Note color
        NotedColorDot(color: Color(note.colorValue)),

        const SizedBox(width: NotedSpacing.xs),

        // Title
        Expanded(
          child: Text(
            StringFormatter.capitalize(note.title),
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Pin
        if (note.isPinned == true)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Icon(
              Icons.push_pin,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
      ],
    );
  }

  // ----------------------------------------------------------
  // FOOTER
  // ----------------------------------------------------------

  Widget _buildFooter(BuildContext context, String displayText) {
    return Row(
      children: [
        // Date / edited text
        Expanded(
          child: Text(
            displayText,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Reminder
        if (note.reminderAt != null)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Icon(
              Icons.notifications_none,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),

        // Optional actions
        if (trailing != null) trailing!,
      ],
    );
  }
}

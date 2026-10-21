import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/domain/entities/checklist_item.dart';

class ChecklistPreview extends StatelessWidget {
  const ChecklistPreview({super.key, required this.items});

  final List<ChecklistItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const previewLimit = 4;
    final visibleItems = items.take(previewLimit).toList();
    final remainingItems = items.length - visibleItems.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...visibleItems.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  item.isCompleted
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  size: 16,
                  color: item.isCompleted
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      decoration: item.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        if (remainingItems > 0)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '+$remainingItems more',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}

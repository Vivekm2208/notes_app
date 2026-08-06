import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/domain/entities/checklist_item.dart';

class ChecklistPreview extends StatelessWidget {
  const ChecklistPreview({super.key, required this.items});

  final List<ChecklistItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...items.take(3).map((item) {
          return Row(
            children: [
              Icon(
                item.isCompleted
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        }),
        if (items.length > 3)
          Text(
            "+${items.length - 3} more",
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }
}

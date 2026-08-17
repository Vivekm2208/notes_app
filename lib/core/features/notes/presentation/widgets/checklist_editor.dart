import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/domain/entities/checklist_item.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/checklist_item_tile.dart';

class ChecklistEditor extends StatelessWidget {
  const ChecklistEditor({
    super.key,
    required this.items,
    required this.focusedItemId,
    required this.onAdd,
    required this.onRemove,
    required this.onToggle,
    required this.onUpdate,
  });

  final List<ChecklistItem> items;

  final String? focusedItemId;

  final VoidCallback onAdd;
  final ValueChanged<String> onToggle;
  final ValueChanged<ChecklistItem> onUpdate;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];

              return ChecklistItemTile(
                item: item,
                autoFocus: item.id == focusedItemId,
                onRemove: onRemove,
                onToggle: onToggle,
                onUpdate: onUpdate,
              );
            },
          ),
        ),

        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: const Text('Add Item'),
        ),
      ],
    );
  }
}

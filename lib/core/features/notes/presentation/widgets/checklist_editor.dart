import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/domain/entities/checklist_item.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/checklist_item_tile.dart';

class ChecklistEditor extends StatefulWidget {
  const ChecklistEditor({
    super.key,
    required this.items,
    required this.onAdd,
    required this.onRemove,
    required this.onToggle,
    required this.onUpdate,
  });

  final List<ChecklistItem> items;

  final ValueChanged<String> onToggle;

  final ValueChanged<ChecklistItem> onUpdate;

  final ValueChanged<String> onRemove;

  final VoidCallback onAdd;
  @override
  State<StatefulWidget> createState() => _ChecklistEditorState();
}

class _ChecklistEditorState extends State<ChecklistEditor> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.items.length,
          itemBuilder: (context, index) {
            final item = widget.items[index];
            return ChecklistItemTile(
              item: item,
              onRemove: widget.onRemove,
              onToggle: widget.onToggle,
              onUpdate: widget.onUpdate,
            );
          },
        ),

        TextButton.icon(
          onPressed: widget.onAdd,
          icon: const Icon(Icons.add),
          label: const Text('Add Item'),
        ),
      ],
    );
  }
}

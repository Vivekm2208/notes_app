import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/domain/entities/checklist_item.dart';

class ChecklistItemTile extends StatefulWidget {
  const ChecklistItemTile({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onToggle,
    required this.onUpdate,
  });

  final ChecklistItem item;

  final ValueChanged<String> onToggle;

  final ValueChanged<ChecklistItem> onUpdate;

  final ValueChanged<String> onRemove;

  @override
  State<StatefulWidget> createState() => _ChecklistItemTileState();
}

class _ChecklistItemTileState extends State<ChecklistItemTile> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.item.text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ChecklistItemTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.item.text != widget.item.text) {
      _controller.value = TextEditingValue(
        text: widget.item.text,
        selection: TextSelection.collapsed(offset: widget.item.text.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: widget.item.isCompleted,
          onChanged: (_) {
            widget.onToggle(widget.item.id);
          },
        ),

        Expanded(
          child: TextField(
            style: TextStyle(
              decoration: widget.item.isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'List item',
              border: InputBorder.none,
              isDense: true,
            ),
            onChanged: (text) {
              widget.onUpdate(widget.item.copyWith(text: text));
            },
          ),
        ),

        IconButton(
          onPressed: () {
            widget.onRemove(widget.item.id);
          },
          icon: Icon(Icons.delete_outline),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/domain/entities/checklist_item.dart';

class ChecklistItemTile extends StatefulWidget {
  const ChecklistItemTile({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onToggle,
    required this.onUpdate,
    this.autoFocus = false,
  });

  final ChecklistItem item;

  final ValueChanged<String> onToggle;
  final ValueChanged<ChecklistItem> onUpdate;
  final ValueChanged<String> onRemove;

  final bool autoFocus;

  @override
  State<ChecklistItemTile> createState() => _ChecklistItemTileState();
}

class _ChecklistItemTileState extends State<ChecklistItemTile> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.item.text);

    _focusNode = FocusNode();

    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        _focusNode.requestFocus();
      });
    }
  }

  @override
  void didUpdateWidget(covariant ChecklistItemTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.item.text != widget.item.text &&
        _controller.text != widget.item.text) {
      _controller.value = TextEditingValue(
        text: widget.item.text,
        selection: TextSelection.collapsed(offset: widget.item.text.length),
      );
    }

    if (!oldWidget.autoFocus && widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
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
            controller: _controller,
            focusNode: _focusNode,
            style: TextStyle(
              decoration: widget.item.isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
            decoration: const InputDecoration(
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
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    );
  }
}

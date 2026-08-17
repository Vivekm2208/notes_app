import 'package:flutter/material.dart';

class NoteEditorHeader extends StatelessWidget {
  const NoteEditorHeader({
    super.key,
    required this.title,
    required this.onBack,
    required this.onSave,
  });
  final String title;
  final VoidCallback onBack;
  final VoidCallback onSave;
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(title, style: Theme.of(context).textTheme.bodyMedium),
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            onPressed: onSave,
            icon: const Icon(Icons.check_circle),
          ),
        ),
      ],
    );
  }
}

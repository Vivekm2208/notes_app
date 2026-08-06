import 'package:flutter/material.dart';

class NoteSearchfield extends StatelessWidget {
  const NoteSearchfield({
    super.key,
    required this.onChanged,
    this.hintText = 'Search Notes...',
  });

  final ValueChanged<String> onChanged;

  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/domain/entities/note.dart';
import 'package:notes_app/core/utils/string_formatter.dart';

class CategoryFilterbar extends StatelessWidget {
  const CategoryFilterbar({
    super.key,
    required this.selectedCategory,
    required this.onChanged,
  });

  final ValueChanged<NoteCategory?> onChanged;
  final NoteCategory? selectedCategory;

  String capitalize(String text) {
    return StringFormatter.capitalize(text);
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<NoteCategory?>(
      initialValue: selectedCategory,
      items: [
        DropdownMenuItem<NoteCategory?>(value: null, child: Text('All')),
        ...NoteCategory.values.map((category) {
          return DropdownMenuItem<NoteCategory?>(
            value: category,
            child: Text(StringFormatter.capitalize(category.name)),
          );
        }),
      ],
      onChanged: onChanged,
    );
  }
}

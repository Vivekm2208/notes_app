import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/domain/entities/note.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/category_clip.dart';
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,

      child: Row(
        children: [
          CategoryClip(
            label: 'All',
            category: null,
            onSelectedCategory: onChanged,
            selectedCategory: selectedCategory,
          ),
          ...NoteCategory.values.map(
            (category) => CategoryClip(
              label: StringFormatter.capitalize(category.name),
              category: category,
              onSelectedCategory: onChanged,
              selectedCategory: selectedCategory,
            ),
          ),
        ],
      ),
    );
  }
}

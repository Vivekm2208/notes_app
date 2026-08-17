import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/domain/entities/note.dart';

class CategoryClip extends StatelessWidget {
  const CategoryClip({
    super.key,
    required this.label,
    required this.category,
    required this.onSelectedCategory,
    required this.selectedCategory,
  });

  final String label;

  final NoteCategory? category;

  final ValueChanged<NoteCategory?> onSelectedCategory;

  final NoteCategory? selectedCategory;

  @override
  Widget build(BuildContext context) {
    final isSelected = category == selectedCategory;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 9),
      child: ChoiceChip(
        selectedColor: theme.colorScheme.primary,
        label: Text(label, style: theme.textTheme.titleMedium),
        onSelected: (selected) {
          onSelectedCategory(selected ? category : null);
        },
        selected: isSelected,
      ),
    );
  }
}

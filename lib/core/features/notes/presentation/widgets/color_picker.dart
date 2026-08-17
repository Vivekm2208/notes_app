import 'package:flutter/material.dart';
import 'package:notes_app/core/constants/note_colors.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/note_color_option.dart';
import 'package:notes_app/core/theme/app_spacing.dart';

class ColorPicker extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;
  static const List<String> labels = [
    'Default',
    'Amber',
    'Green',
    'Blue',
    'Purple',
    'Red',
  ];
  const ColorPicker({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Note colour', style: Theme.of(context).textTheme.titleMedium),

        const SizedBox(height: NotedSpacing.md),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: NoteColors.colors.asMap().entries.map((entry) {
            return NoteColorOption(
              color: entry.value,
              isSelected: selectedColor == entry.value,
              label: labels[entry.key],
              onTap: () {
                onColorSelected(entry.value);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

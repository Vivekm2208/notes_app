import 'package:flutter/material.dart';
import 'package:notes_app/core/constants/note_colors.dart';

class ColorPicker extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;
  const ColorPicker({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: NoteColors.colors.map((color) {
        return GestureDetector(
          onTap: () {
            onColorSelected(color);
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: selectedColor == color ? Colors.black : Colors.grey,
                width: selectedColor == color ? 3 : 1,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

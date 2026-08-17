import 'package:flutter/material.dart';
import 'package:notes_app/core/theme/app_spacing.dart';

class NoteColorOption extends StatelessWidget {
  const NoteColorOption({
    super.key,
    required this.color,
    required this.isSelected,
    required this.label,
    required this.onTap,
  });

  final String label;

  final VoidCallback onTap;

  final bool isSelected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
                width: isSelected ? 3 : 1,
              ),
            ),
          ),
        ),
        const SizedBox(height: NotedSpacing.xs),
        Text(label),
      ],
    );
  }
}

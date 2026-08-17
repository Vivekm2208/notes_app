import 'package:flutter/material.dart';

class ReminderRecurrenceOption extends StatelessWidget {
  const ReminderRecurrenceOption({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selectedColor: Theme.of(context).colorScheme.primary,
      label: Text(label, style: Theme.of(context).textTheme.titleMedium),
      selected: selected,
      onSelected: (_) {
        onSelected();
      },
    );
  }
}

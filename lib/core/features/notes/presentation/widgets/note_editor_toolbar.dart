import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/color_picker.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/reminder_picker.dart';
import 'package:notes_app/core/theme/app_spacing.dart';
import 'package:notes_app/core/features/notes/domain/entities/note.dart';

class NoteEditorToolbar extends StatelessWidget {
  const NoteEditorToolbar({
    super.key,
    required this.selectedColor,
    required this.onSelectedColor,
    required this.reminder,
    required this.onSelectedReminder,
    required this.onFormat,
    required this.recurrence,
    required this.onSelectedRecurrence,
  });

  final Color selectedColor;

  final ValueChanged<Color> onSelectedColor;

  final DateTime? reminder;

  final ValueChanged<DateTime?> onSelectedReminder;

  final VoidCallback onFormat;
  final ReminderRecurrence recurrence;
  final ValueChanged<ReminderRecurrence> onSelectedRecurrence;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: IconButton(
            onPressed: () {
              showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (context) {
                  return SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(NotedSpacing.md),
                      child: ColorPicker(
                        selectedColor: selectedColor,
                        onColorSelected: (color) {
                          onSelectedColor(color);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  );
                },
              );
            },
            icon: const Icon(Icons.color_lens_outlined),
          ),
        ),

        Expanded(
          child: IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  return SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(NotedSpacing.md),
                      child: ReminderPicker(
                        reminder: reminder,
                        recurrence: recurrence,
                        onReminderChanged: (reminder) {
                          onSelectedReminder(reminder);
                          Navigator.pop(context);
                        },
                        onRecurrenceChanged: onSelectedRecurrence,
                      ),
                    ),
                  );
                },
              );
            },
            icon: const Icon(Icons.notifications_active_outlined),
          ),
        ),
      ],
    );
  }
}

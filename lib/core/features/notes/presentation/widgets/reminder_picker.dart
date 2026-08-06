import 'package:flutter/material.dart';
import 'package:notes_app/core/utils/reminder_formatter.dart';

class ReminderPicker extends StatefulWidget {
  const ReminderPicker({
    super.key,
    required this.reminder,
    required this.onReminderChanged,
  });

  final ValueChanged<DateTime?> onReminderChanged;
  final DateTime? reminder;

  @override
  State<ReminderPicker> createState() => _ReminderPickerState();
}

class _ReminderPickerState extends State<ReminderPicker> {
  Future<void> _pickReminder() async {
    if (!mounted) return;

    final date = await showDatePicker(
      context: context,
      initialDate: widget.reminder ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (!mounted) return;
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: widget.reminder != null
          ? TimeOfDay.fromDateTime(widget.reminder!)
          : TimeOfDay.now(),
    );
    if (!mounted) return;
    if (time == null) return;

    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    if (!mounted) return;
    widget.onReminderChanged(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reminder',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          widget.reminder == null
              ? 'No reminder set'
              : ReminderFormatter.format(widget.reminder!),
        ),
        const SizedBox(height: 12),

        ElevatedButton(
          onPressed: () {
            _pickReminder();
          },
          child: const Text('Select Reminder'),
        ),
        if (widget.reminder != null)
          TextButton(
            onPressed: () {
              widget.onReminderChanged(null);
            },
            child: const Text('Remove Reminder'),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/domain/entities/note.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/reminder_field.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/reminder_picker_controller.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/reminder_recurrence_option.dart';
import 'package:notes_app/core/theme/app_spacing.dart';

class ReminderPicker extends StatefulWidget {
  const ReminderPicker({
    super.key,
    required this.reminder,
    required this.onReminderChanged,
    required this.recurrence,
    required this.onRecurrenceChanged,
  });

  final DateTime? reminder;
  final ValueChanged<DateTime?> onReminderChanged;

  final ReminderRecurrence recurrence;
  final ValueChanged<ReminderRecurrence> onRecurrenceChanged;

  @override
  State<ReminderPicker> createState() => _ReminderPickerState();
}

class _ReminderPickerState extends State<ReminderPicker> {
  late final ReminderPickerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = ReminderPickerController(
      reminder: widget.reminder,
      recurrence: widget.recurrence,
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _controller.selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (!mounted || date == null) return;

    setState(() {
      _controller.setDate(date);
    });
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _controller.selectedTime ?? TimeOfDay.now(),
    );

    if (!mounted || time == null) return;

    setState(() {
      _controller.setTime(time);
    });
  }

  void _selectRecurrence(ReminderRecurrence recurrence) {
    setState(() {
      _controller.setRecurrence(recurrence);
    });

    widget.onRecurrenceChanged(recurrence);
  }

  void _setReminder() {
    final reminder = _controller.buildReminder();

    if (reminder == null) return;

    widget.onReminderChanged(reminder);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'Set reminder',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),

        const SizedBox(height: NotedSpacing.md),

        Wrap(
          spacing: NotedSpacing.sm,
          runSpacing: NotedSpacing.sm,
          children: [
            ReminderRecurrenceOption(
              label: 'Never',
              selected:
                  _controller.selectedRecurrence == ReminderRecurrence.none,
              onSelected: () {
                _selectRecurrence(ReminderRecurrence.none);
              },
            ),

            ReminderRecurrenceOption(
              label: 'EveryDay',
              selected:
                  _controller.selectedRecurrence == ReminderRecurrence.daily,
              onSelected: () {
                _selectRecurrence(ReminderRecurrence.daily);
              },
            ),

            ReminderRecurrenceOption(
              label: 'EveryWeek',
              selected:
                  _controller.selectedRecurrence == ReminderRecurrence.weekly,
              onSelected: () {
                _selectRecurrence(ReminderRecurrence.weekly);
              },
            ),

            ReminderRecurrenceOption(
              label: 'EveryMonth',
              selected:
                  _controller.selectedRecurrence == ReminderRecurrence.monthly,
              onSelected: () {
                _selectRecurrence(ReminderRecurrence.monthly);
              },
            ),

            ReminderRecurrenceOption(
              label: 'EveryYear',
              selected:
                  _controller.selectedRecurrence == ReminderRecurrence.yearly,
              onSelected: () {
                _selectRecurrence(ReminderRecurrence.yearly);
              },
            ),
          ],
        ),

        const SizedBox(height: NotedSpacing.md),

        Row(
          children: [
            ReminderField(
              label: 'DATE',
              value: _controller.selectedDate == null
                  ? 'Select date'
                  : '${_controller.selectedDate!.day.toString().padLeft(2, '0')}/'
                        '${_controller.selectedDate!.month.toString().padLeft(2, '0')}/'
                        '${_controller.selectedDate!.year}',
              onTap: _pickDate,
            ),

            const SizedBox(width: NotedSpacing.sm),

            ReminderField(
              label: 'TIME',
              value: _controller.selectedTime == null
                  ? 'Select time'
                  : _controller.selectedTime!.format(context),
              onTap: _pickTime,
            ),
          ],
        ),

        const SizedBox(height: NotedSpacing.md),

        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _controller.canSetReminder ? _setReminder : null,
            child: Text(
              widget.reminder == null ? 'Set Reminder' : 'Update Reminder',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),

        if (widget.reminder != null) ...[
          const SizedBox(height: NotedSpacing.sm),

          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                widget.onReminderChanged(null);

                widget.onRecurrenceChanged(ReminderRecurrence.none);
              },
              child: Text(
                'Remove Reminder',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

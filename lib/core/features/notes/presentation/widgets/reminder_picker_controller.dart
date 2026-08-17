import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/domain/entities/note.dart';

class ReminderPickerController {
  ReminderPickerController({
    DateTime? reminder,
    required ReminderRecurrence recurrence,
  }) {
    _selectedRecurrence = recurrence;

    if (reminder != null) {
      _selectedDate = DateTime(reminder.year, reminder.month, reminder.day);

      _selectedTime = TimeOfDay.fromDateTime(reminder);
    }
  }

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  late ReminderRecurrence _selectedRecurrence;

  DateTime? get selectedDate => _selectedDate;

  TimeOfDay? get selectedTime => _selectedTime;

  ReminderRecurrence get selectedRecurrence => _selectedRecurrence;

  void setDate(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, date.day);
  }

  void setTime(TimeOfDay time) {
    _selectedTime = time;
  }

  void setRecurrence(ReminderRecurrence recurrence) {
    _selectedRecurrence = recurrence;
  }

  bool get canSetReminder => _selectedDate != null && _selectedTime != null;

  DateTime? buildReminder() {
    if (!canSetReminder) return null;

    return DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
  }
}

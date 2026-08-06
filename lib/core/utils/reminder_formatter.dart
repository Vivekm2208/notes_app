import 'package:intl/intl.dart';
import 'package:notes_app/core/utils/date_formatter.dart';

class ReminderFormatter {
  static String format(DateTime reminder) {
    final now = DateTime.now();

    final tomorrow = now.add(const Duration(days: 1));

    final time = DateFormat('hh:mm a').format(reminder);

    if (reminder.day == tomorrow.day &&
        reminder.month == tomorrow.month &&
        reminder.year == tomorrow.year) {
      return 'Tomorrow • $time';
    }

    final date = DateFormatter.format(reminder);

    return '$date • $time';
  }
}

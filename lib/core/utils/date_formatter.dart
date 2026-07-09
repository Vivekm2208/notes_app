import 'package:intl/intl.dart';

class DateFormatter {
  static String format(DateTime date) {
    final now = DateTime.now();

    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      return 'Today, ${DateFormat('hh:mm a').format(date)}';
    }

    final yesterday = now.subtract(const Duration(days: 1));

    if (date.day == yesterday.day &&
        date.month == yesterday.month &&
        date.year == yesterday.year) {
      return 'Yesterday, ${DateFormat('hh:mm a').format(date)}';
    }

    if (date.year == now.year) {
      return DateFormat('dd MMM, hh:mm a').format(date);
    }

    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }
}

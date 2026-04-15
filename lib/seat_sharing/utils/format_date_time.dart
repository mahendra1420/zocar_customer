import 'package:intl/intl.dart';

String formatDateTime(String dateTimeString) {
  try {
    final dateTime = DateTime.parse(dateTimeString);
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inDays == 0 && dateTime.day == now.day) {
      return 'Today, ${DateFormat('HH:mm').format(dateTime)}';
    } else if (difference.inDays == 1) {
      return 'Tomorrow, ${DateFormat('HH:mm').format(dateTime)}';
    } else if (difference.inDays == -1) {
      return 'Yesterday, ${DateFormat('HH:mm').format(dateTime)}';
    }

    return DateFormat('MMM dd, HH:mm').format(dateTime);
  } catch (e) {
    return dateTimeString;
  }
}
class DateTimeUtils {
  /// Converts a [DateTime] into a friendly time-ago string (e.g. "Just now", "5m ago", "2h ago", "Yesterday", "3d ago").
  static String timeAgo(DateTime? date) {
    if (date == null) return 'Just now';
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 45) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }

  /// Formats time in 12-hour format with AM/PM (e.g. "10:30 AM").
  static String chatMessageTime(DateTime? date) {
    if (date == null) return '';
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final amPm = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $amPm';
  }

  /// Formats a date separator for chat messages (e.g. "Today", "Yesterday", "Jan 15, 2026").
  static String chatDateSeparator(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDate = DateTime(date.year, date.month, date.day);

    if (msgDate == today) {
      return 'Today';
    } else if (msgDate == yesterday) {
      return 'Yesterday';
    } else {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }

  /// Formats time for conversation list items (e.g. "10:30 AM", "Mon", "15/1").
  static String chatListTime(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0 && now.day == date.day) {
      final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
      final amPm = date.hour >= 12 ? 'PM' : 'AM';
      final minute = date.minute.toString().padLeft(2, '0');
      return '$hour:$minute $amPm';
    } else if (diff.inDays < 7) {
      const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[date.weekday - 1];
    } else {
      return '${date.day}/${date.month}';
    }
  }

  /// Checks if two dates fall on the exact same calendar day.
  static bool isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }
}

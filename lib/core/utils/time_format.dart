const _weekdays = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];
const _months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];

/// `21:05`
String formatTime(DateTime dateTime) {
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

/// `sáb 20 sep 2026 · 21:05`
String formatLongDate(DateTime dateTime) {
  final weekday = _weekdays[dateTime.weekday - 1];
  final month = _months[dateTime.month - 1];
  return '$weekday ${dateTime.day} $month ${dateTime.year} · ${formatTime(dateTime)}';
}

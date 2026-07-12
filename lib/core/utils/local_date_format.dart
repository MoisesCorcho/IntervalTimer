/// Helpers for calendar-local dates (`yyyy-MM-dd`) used by F04 SessionLog.
abstract final class LocalDateFormat {
  static String fromDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static DateTime parse(String yyyyMmDd) {
    final parts = yyyyMmDd.split('-');
    if (parts.length != 3) {
      throw FormatException('Invalid local date: $yyyyMmDd');
    }
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  static String monthStart(DateTime focusedMonth) {
    final d = DateTime(focusedMonth.year, focusedMonth.month, 1);
    return fromDateTime(d);
  }

  static String monthEnd(DateTime focusedMonth) {
    final d = DateTime(focusedMonth.year, focusedMonth.month + 1, 0);
    return fromDateTime(d);
  }
}

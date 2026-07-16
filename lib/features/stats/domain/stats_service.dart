import 'package:interval_timer/core/utils/local_date_format.dart';
import 'package:interval_timer/data/models/session_log.dart';
import 'package:interval_timer/features/stats/domain/stats_models.dart';

/// Pure aggregation of [SessionLog] into progress metrics and chart series (F12).
///
/// No I/O — injectable [now] for streak tests. Reuse this service from F13/F16
/// so streak and kcal rules stay consistent.
class StatsService {
  const StatsService({this.met = kDefaultMet});

  final double met;

  /// Estimated kcal for a single session.
  double estimatedKcalForSession(
    SessionLog log, {
    required double weightKg,
  }) {
    return met * weightKg * (log.totalDurationSeconds / 3600.0);
  }

  StatsSummary summarize(
    List<SessionLog> logs, {
    required DateTime focusedMonth,
    required DateTime now,
    required double weightKg,
    required bool isWeightEstimated,
  }) {
    if (logs.isEmpty) {
      return StatsSummary(
        currentStreakDays: 0,
        weekMinutes: 0,
        monthSessionCount: 0,
        totalMinutes: 0,
        totalSessionCount: 0,
        totalEstimatedKcal: 0,
        isWeightEstimated: isWeightEstimated,
        weightKgUsed: weightKg,
      );
    }

    final localNow = DateTime(now.year, now.month, now.day);
    final weekStart = _mondayOfIsoWeek(localNow);
    final weekEnd = weekStart.add(const Duration(days: 6));
    final weekStartStr = LocalDateFormat.fromDateTime(weekStart);
    final weekEndStr = LocalDateFormat.fromDateTime(weekEnd);

    final monthStart = LocalDateFormat.monthStart(focusedMonth);
    final monthEnd = LocalDateFormat.monthEnd(focusedMonth);

    var totalSeconds = 0;
    var weekSeconds = 0;
    var monthSessionCount = 0;
    var totalKcal = 0.0;

    for (final log in logs) {
      totalSeconds += log.totalDurationSeconds;
      totalKcal += estimatedKcalForSession(log, weightKg: weightKg);

      final d = log.localDate;
      if (d.compareTo(weekStartStr) >= 0 && d.compareTo(weekEndStr) <= 0) {
        weekSeconds += log.totalDurationSeconds;
      }
      if (d.compareTo(monthStart) >= 0 && d.compareTo(monthEnd) <= 0) {
        monthSessionCount++;
      }
    }

    return StatsSummary(
      currentStreakDays: currentStreak(logs, now: now),
      weekMinutes: totalSecondsToMinutes(weekSeconds),
      monthSessionCount: monthSessionCount,
      totalMinutes: totalSecondsToMinutes(totalSeconds),
      totalSessionCount: logs.length,
      totalEstimatedKcal: totalKcal.round(),
      isWeightEstimated: isWeightEstimated,
      weightKgUsed: weightKg,
    );
  }

  /// Current consecutive activity days (R6).
  int currentStreak(List<SessionLog> logs, {required DateTime now}) {
    if (logs.isEmpty) return 0;

    final activeDays = <String>{};
    for (final log in logs) {
      activeDays.add(log.localDate);
    }

    final today = DateTime(now.year, now.month, now.day);
    final todayStr = LocalDateFormat.fromDateTime(today);
    final yesterday = today.subtract(const Duration(days: 1));
    final yesterdayStr = LocalDateFormat.fromDateTime(yesterday);

    late final DateTime anchor;
    if (activeDays.contains(todayStr)) {
      anchor = today;
    } else if (activeDays.contains(yesterdayStr)) {
      anchor = yesterday;
    } else {
      return 0;
    }

    var streak = 0;
    var cursor = anchor;
    while (true) {
      final key = LocalDateFormat.fromDateTime(cursor);
      if (!activeDays.contains(key)) break;
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// Seven bars Mon–Sun of the ISO week containing [now].
  List<DayMinutes> weekSeries(
    List<SessionLog> logs, {
    required DateTime now,
  }) {
    final localNow = DateTime(now.year, now.month, now.day);
    final monday = _mondayOfIsoWeek(localNow);
    final byDay = _minutesByLocalDate(logs);

    return List.generate(7, (i) {
      final day = monday.add(Duration(days: i));
      final key = LocalDateFormat.fromDateTime(day);
      return DayMinutes(localDate: key, minutes: byDay[key] ?? 0);
    });
  }

  /// One bar per day of [focusedMonth].
  List<DayMinutes> monthSeries(
    List<SessionLog> logs, {
    required DateTime focusedMonth,
  }) {
    final year = focusedMonth.year;
    final month = focusedMonth.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final byDay = _minutesByLocalDate(logs);

    return List.generate(daysInMonth, (i) {
      final day = DateTime(year, month, i + 1);
      final key = LocalDateFormat.fromDateTime(day);
      return DayMinutes(localDate: key, minutes: byDay[key] ?? 0);
    });
  }

  static int totalSecondsToMinutes(int totalSeconds) =>
      (totalSeconds / 60).floor();

  Map<String, int> _minutesByLocalDate(List<SessionLog> logs) {
    final secondsByDay = <String, int>{};
    for (final log in logs) {
      secondsByDay.update(
        log.localDate,
        (v) => v + log.totalDurationSeconds,
        ifAbsent: () => log.totalDurationSeconds,
      );
    }
    return secondsByDay.map(
      (k, v) => MapEntry(k, totalSecondsToMinutes(v)),
    );
  }

  /// Monday of the ISO week containing [date] (local date, time zeroed).
  static DateTime _mondayOfIsoWeek(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return d.subtract(Duration(days: d.weekday - DateTime.monday));
  }
}

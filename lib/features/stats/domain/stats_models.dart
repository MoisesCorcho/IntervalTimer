/// Chart period for activity bars (F12).
enum ChartPeriod { week, month }

/// Minutes trained on a single local calendar day (`yyyy-MM-dd`).
class DayMinutes {
  const DayMinutes({
    required this.localDate,
    required this.minutes,
  });

  final String localDate;
  final int minutes;
}

/// Aggregated progress metrics derived from [SessionLog] (not persisted).
class StatsSummary {
  const StatsSummary({
    required this.currentStreakDays,
    required this.weekMinutes,
    required this.monthSessionCount,
    required this.totalMinutes,
    required this.totalSessionCount,
    required this.totalEstimatedKcal,
    required this.isWeightEstimated,
    required this.weightKgUsed,
  });

  final int currentStreakDays;
  final int weekMinutes;
  final int monthSessionCount;
  final int totalMinutes;
  final int totalSessionCount;
  final int totalEstimatedKcal;
  final bool isWeightEstimated;
  final double weightKgUsed;

  static const empty = StatsSummary(
    currentStreakDays: 0,
    weekMinutes: 0,
    monthSessionCount: 0,
    totalMinutes: 0,
    totalSessionCount: 0,
    totalEstimatedKcal: 0,
    isWeightEstimated: true,
    weightKgUsed: kDefaultWeightKg,
  );
}

/// Default MET for interval/HIIT until F03 category metadata exists on logs.
const double kDefaultMet = 8.0;

/// Default body weight (kg) when F15 has no registered weight.
const double kDefaultWeightKg = 70.0;

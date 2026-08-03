import 'package:interval_timer/features/achievements/domain/achievement_def.dart';

/// UI-facing progress row for one catalog achievement (F13 R3).
class AchievementProgressView {
  const AchievementProgressView({
    required this.def,
    required this.current,
    required this.target,
    required this.isUnlocked,
    this.unlockedAt,
  });

  final AchievementDef def;
  final int current;
  final int target;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  /// Progress ratio clamped to [0, 1] for bars.
  double get progressFraction {
    if (target <= 0) return isUnlocked ? 1 : 0;
    final ratio = current / target;
    if (ratio < 0) return 0;
    if (ratio > 1) return 1;
    return ratio;
  }
}

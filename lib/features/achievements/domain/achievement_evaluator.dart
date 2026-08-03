import 'package:interval_timer/data/models/session_log.dart';
import 'package:interval_timer/data/models/session_log_status.dart';
import 'package:interval_timer/features/achievements/domain/achievement_catalog.dart';
import 'package:interval_timer/features/achievements/domain/achievement_def.dart';
import 'package:interval_timer/features/achievements/domain/achievement_progress_view.dart';
import 'package:interval_timer/features/achievements/domain/unlocked_achievement.dart';
import 'package:interval_timer/features/stats/domain/stats_service.dart';

/// Pure achievement evaluation (F13 R4–R6, R11).
///
/// Session counts and minutes use only `completed` logs.
/// Streak reuses [StatsService.currentStreak] (F12 R6 — any log day).
class AchievementEvaluator {
  const AchievementEvaluator({
    this.statsService = const StatsService(),
    this.catalog = kAchievementCatalog,
  });

  final StatsService statsService;
  final List<AchievementDef> catalog;

  /// Returns catalog defs whose threshold is met and not yet unlocked.
  List<AchievementDef> evaluate(
    List<SessionLog> logs,
    Set<String> unlockedIds, {
    required DateTime now,
  }) {
    final metrics = _metrics(logs, now: now);
    final newly = <AchievementDef>[];
    for (final def in catalog) {
      if (unlockedIds.contains(def.id)) continue;
      if (metrics.valueOf(def.kind) >= def.threshold) {
        newly.add(def);
      }
    }
    return newly;
  }

  /// Progress for every catalog entry. Never revokes unlocks (R6, R9).
  List<AchievementProgressView> buildProgress(
    List<SessionLog> logs,
    List<UnlockedAchievement> unlocks, {
    required DateTime now,
  }) {
    final byId = {for (final u in unlocks) u.achievementId: u};
    final metrics = _metrics(logs, now: now);

    return catalog.map((def) {
      final unlock = byId[def.id];
      final isUnlocked = unlock != null;
      final raw = metrics.valueOf(def.kind);
      // Unlocked rows always read as complete even if logs were deleted (R6).
      final current = isUnlocked ? def.threshold : raw;
      return AchievementProgressView(
        def: def,
        current: current,
        target: def.threshold,
        isUnlocked: isUnlocked,
        unlockedAt: unlock?.unlockedAt,
      );
    }).toList();
  }

  /// Current metric for a kind without clamping (for progress text like 5/10).
  int currentMetric(
    List<SessionLog> logs,
    AchievementMetricKind kind, {
    required DateTime now,
  }) {
    return _metrics(logs, now: now).valueOf(kind);
  }

  _AchievementMetrics _metrics(
    List<SessionLog> logs, {
    required DateTime now,
  }) {
    final completed =
        logs.where((l) => l.status == SessionLogStatus.completed).toList();
    var totalSeconds = 0;
    for (final log in completed) {
      totalSeconds += log.totalDurationSeconds;
    }
    return _AchievementMetrics(
      completedSessionCount: completed.length,
      completedTotalMinutes: StatsService.totalSecondsToMinutes(totalSeconds),
      currentStreakDays: statsService.currentStreak(logs, now: now),
    );
  }
}

class _AchievementMetrics {
  const _AchievementMetrics({
    required this.completedSessionCount,
    required this.completedTotalMinutes,
    required this.currentStreakDays,
  });

  final int completedSessionCount;
  final int completedTotalMinutes;
  final int currentStreakDays;

  int valueOf(AchievementMetricKind kind) {
    return switch (kind) {
      AchievementMetricKind.completedSessionCount => completedSessionCount,
      AchievementMetricKind.currentStreakDays => currentStreakDays,
      AchievementMetricKind.completedTotalMinutes => completedTotalMinutes,
    };
  }
}

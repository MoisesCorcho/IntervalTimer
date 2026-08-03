import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/data/repositories/unlocked_achievement_repository.dart';
import 'package:interval_timer/features/achievements/domain/achievement_catalog.dart';
import 'package:interval_timer/features/achievements/domain/achievement_def.dart';
import 'package:interval_timer/features/achievements/domain/achievement_evaluator.dart';
import 'package:interval_timer/features/achievements/domain/achievement_progress_view.dart';
import 'package:interval_timer/features/achievements/domain/unlocked_achievement.dart';
import 'package:interval_timer/features/calendar_history/application/calendar_history_providers.dart';
import 'package:interval_timer/features/stats/application/stats_providers.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';

final unlockedAchievementRepositoryProvider =
    Provider<UnlockedAchievementRepository>((ref) {
  return UnlockedAchievementRepository(ref.watch(databaseProvider));
});

final achievementCatalogProvider = Provider<List<AchievementDef>>((ref) {
  return kAchievementCatalog;
});

final achievementEvaluatorProvider = Provider<AchievementEvaluator>((ref) {
  return AchievementEvaluator(
    statsService: ref.watch(statsServiceProvider),
    catalog: ref.watch(achievementCatalogProvider),
  );
});

final unlockedAchievementsProvider =
    StreamProvider.autoDispose<List<UnlockedAchievement>>((ref) {
  return ref.watch(unlockedAchievementRepositoryProvider).watchAll();
});

/// Progress list for AchievementsScreen — refreshes with logs/unlocks (R3, R9).
final achievementProgressProvider =
    Provider.autoDispose<AsyncValue<List<AchievementProgressView>>>((ref) {
  final logsAsync = ref.watch(sessionLogsForStatsProvider);
  final unlocksAsync = ref.watch(unlockedAchievementsProvider);
  final evaluator = ref.watch(achievementEvaluatorProvider);

  if (logsAsync.hasError) {
    return AsyncValue.error(logsAsync.error!, logsAsync.stackTrace!);
  }
  if (unlocksAsync.hasError) {
    return AsyncValue.error(unlocksAsync.error!, unlocksAsync.stackTrace!);
  }
  if (!logsAsync.hasValue || !unlocksAsync.hasValue) {
    return const AsyncValue.loading();
  }

  return AsyncValue.data(
    evaluator.buildProgress(
      logsAsync.requireValue,
      unlocksAsync.requireValue,
      now: DateTime.now(),
    ),
  );
});

/// Newly unlocked defs waiting for celebration UI (F16 chip / sheet).
class PendingUnlockCelebrationNotifier extends Notifier<List<AchievementDef>> {
  @override
  List<AchievementDef> build() => const [];

  void setPending(List<AchievementDef> unlocked) {
    state = List.unmodifiable(unlocked);
  }

  void clear() {
    state = const [];
  }
}

final pendingUnlockCelebrationProvider =
    NotifierProvider<PendingUnlockCelebrationNotifier, List<AchievementDef>>(
  PendingUnlockCelebrationNotifier.new,
);

/// Evaluates catalog after a completed session is persisted (R4, R7).
class AchievementsController extends Notifier<void> {
  @override
  void build() {}

  Future<List<AchievementDef>> evaluateAfterCompletedSession({
    DateTime? now,
  }) async {
    final repo = ref.read(unlockedAchievementRepositoryProvider);
    final sessionRepo = ref.read(sessionLogRepositoryProvider);
    final evaluator = ref.read(achievementEvaluatorProvider);

    try {
      final logs = await sessionRepo.getAll();
      final unlockedIds = await repo.getUnlockedIds();
      final candidates = evaluator.evaluate(
        logs,
        unlockedIds,
        now: now ?? DateTime.now(),
      );

      if (candidates.isEmpty) return const [];

      final unlockedAt = (now ?? DateTime.now()).toUtc();
      final newlyInserted = <AchievementDef>[];
      for (final def in candidates) {
        final inserted = await repo.insertIgnore(
          achievementId: def.id,
          unlockedAt: unlockedAt,
        );
        if (inserted) {
          newlyInserted.add(def);
        }
      }

      if (newlyInserted.isNotEmpty) {
        ref
            .read(pendingUnlockCelebrationProvider.notifier)
            .setPending(newlyInserted);
      }
      return newlyInserted;
    } catch (e, st) {
      // R10: do not crash; unlocks only if insert succeeded (handled above).
      debugPrint('AchievementsController evaluate failed: $e\n$st');
      return const [];
    }
  }

  void clearPendingCelebration() {
    ref.read(pendingUnlockCelebrationProvider.notifier).clear();
  }
}

final achievementsControllerProvider =
    NotifierProvider<AchievementsController, void>(AchievementsController.new);

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/data/models/session_log_status.dart';
import 'package:interval_timer/data/repositories/session_log_repository.dart';
import 'package:interval_timer/features/achievements/application/achievements_providers.dart';
import 'package:interval_timer/features/calendar_history/application/calendar_history_providers.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';
import 'package:interval_timer/features/timer/application/timer_session_events.dart';

/// Subscribes once to F01 session streams and persists [SessionLog]s (R1, R2, R18).
///
/// Watch [sessionHistoryBootstrapProvider] from [App] so the subscription is
/// created once at app bootstrap.
final sessionHistoryBootstrapProvider = Provider<void>((ref) {
  final repo = ref.watch(sessionLogRepositoryProvider);
  final timer = ref.read(timerControllerProvider.notifier);

  StreamSubscription<SessionCompletedEvent>? completedSub;
  StreamSubscription<SessionCancelledEvent>? cancelledSub;

  completedSub = timer.sessionCompletedStream.listen((event) async {
    final displayName =
        ref.read(timerControllerProvider).routine?.name ?? '';
    try {
      await repo.insert(
        sourceId: event.routineId,
        displayName: displayName,
        endedAt: event.completedAt,
        status: SessionLogStatus.completed,
        totalDurationSeconds: event.totalElapsedSeconds,
        itemCount: event.intervalCount,
      );
    } catch (e, st) {
      debugPrint('SessionHistoryListener completed insert failed: $e\n$st');
      return;
    }
    // F13: evaluate only after completed log is persisted (R4).
    try {
      await ref
          .read(achievementsControllerProvider.notifier)
          .evaluateAfterCompletedSession(now: event.completedAt);
    } catch (e, st) {
      debugPrint('SessionHistoryListener achievements evaluate failed: $e\n$st');
    }
  });

  cancelledSub = timer.sessionCancelledStream.listen((event) async {
    if (event.elapsedSeconds <= 0) return;
    final displayName =
        ref.read(timerControllerProvider).routine?.name ?? '';
    try {
      await repo.insert(
        sourceId: event.routineId,
        displayName: displayName,
        endedAt: event.cancelledAt,
        status: SessionLogStatus.aborted,
        totalDurationSeconds: event.elapsedSeconds,
        itemCount: event.completedIntervalCount,
      );
    } catch (e, st) {
      debugPrint('SessionHistoryListener cancelled insert failed: $e\n$st');
    }
  });

  ref.onDispose(() {
    completedSub?.cancel();
    cancelledSub?.cancel();
  });
});

/// Test helper: process events without streams (unit tests of mapping rules).
class SessionHistoryMapper {
  SessionHistoryMapper(this._repo);

  final SessionLogRepository _repo;

  Future<void> onCompleted(
    SessionCompletedEvent event, {
    required String displayName,
  }) {
    return _repo.insert(
      sourceId: event.routineId,
      displayName: displayName,
      endedAt: event.completedAt,
      status: SessionLogStatus.completed,
      totalDurationSeconds: event.totalElapsedSeconds,
      itemCount: event.intervalCount,
    );
  }

  Future<void> onCancelled(
    SessionCancelledEvent event, {
    required String displayName,
  }) async {
    if (event.elapsedSeconds <= 0) return;
    await _repo.insert(
      sourceId: event.routineId,
      displayName: displayName,
      endedAt: event.cancelledAt,
      status: SessionLogStatus.aborted,
      totalDurationSeconds: event.elapsedSeconds,
      itemCount: event.completedIntervalCount,
    );
  }
}

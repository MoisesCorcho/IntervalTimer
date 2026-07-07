import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/data/models/interval.dart';
import 'package:interval_timer/data/models/routine.dart';
import 'package:interval_timer/data/models/routine_item.dart';
import 'package:interval_timer/features/timer/application/timer_session_events.dart';
import 'package:interval_timer/features/timer/application/timer_state.dart';

typedef NowProvider = DateTime Function();

class TimerController extends Notifier<TimerState> {
  TimerController({NowProvider? now}) : _now = now ?? DateTime.now;

  final NowProvider _now;
  Timer? _uiTicker;
  final _sessionCompletedController =
      StreamController<SessionCompletedEvent>.broadcast(sync: true);
  final _sessionCancelledController =
      StreamController<SessionCancelledEvent>.broadcast(sync: true);

  Stream<SessionCompletedEvent> get sessionCompletedStream =>
      _sessionCompletedController.stream;

  Stream<SessionCancelledEvent> get sessionCancelledStream =>
      _sessionCancelledController.stream;

  @override
  TimerState build() {
    ref.onDispose(() {
      _uiTicker?.cancel();
      _sessionCompletedController.close();
      _sessionCancelledController.close();
    });
    return const TimerState();
  }

  void bindRoutine(Routine routine) {
    if (state.status != TimerStatus.idle) return;
    state = state.copyWith(routine: routine);
  }

  /// Loads a flattened F32 workout into memory without persisting intervals.
  ///
  /// [workoutId] is used as [SessionCompletedEvent.routineId] and
  /// [SessionCancelledEvent.routineId] when the session originates from F32.
  void loadFlattenedWorkout({
    required String workoutId,
    required String workoutName,
    required List<Interval> flattened,
  }) {
    if (state.status != TimerStatus.idle) return;

    final routine = Routine(
      id: workoutId,
      name: workoutName,
      createdAt: DateTime.now().toUtc(),
      items: [
        for (final interval in flattened) RoutineItem.interval(interval),
      ],
    );
    state = state.copyWith(routine: routine);
  }

  bool start() {
    final routine = state.routine;
    if (routine == null || routine.items.isEmpty) return false;
    if (state.status != TimerStatus.idle) return false;

    final first = _intervalAt(routine, 0);
    if (first == null) return false;

    final now = _now();
    final durationMs = first.durationSeconds * 1000;

    state = state.copyWith(
      status: TimerStatus.running,
      currentIndex: 0,
      remainingMs: durationMs,
      currentIntervalDurationMs: durationMs,
      segmentStartTimestamp: now,
      pausedAccumulatedMs: 0,
      sessionStartTimestamp: now,
      isPausePending: false,
      tick: 0,
    );
    _startUiTicker();
    return true;
  }

  void pause() {
    if (state.status != TimerStatus.running) return;

    // R16: set flag first so domain tick cannot advance interval.
    state = state.copyWith(isPausePending: true);

    final remaining = _calculateRemainingMs();
    state = state.copyWith(
      status: TimerStatus.paused,
      remainingMs: remaining,
    );
    _stopUiTicker();
  }

  void resume() {
    if (state.status != TimerStatus.paused) return;

    final now = _now();
    state = state.copyWith(
      status: TimerStatus.running,
      segmentStartTimestamp: now,
      pausedAccumulatedMs: 0,
      isPausePending: false,
    );
    _startUiTicker();
  }

  void skip() {
    if (state.status != TimerStatus.running &&
        state.status != TimerStatus.paused) {
      return;
    }

    final routine = state.routine;
    if (routine == null) return;

    if (state.currentIndex >= routine.items.length - 1) {
      _completeSession();
      return;
    }

    _advanceToIndex(state.currentIndex + 1, keepRunning: true);
  }

  void cancel() {
    if (state.status != TimerStatus.running &&
        state.status != TimerStatus.paused) {
      return;
    }

    final routine = state.routine;
    if (routine == null) return;

    final elapsedSeconds = _elapsedSessionSeconds();
    final completedCount = state.currentIndex;

    _stopUiTicker();
    state = TimerState(routine: routine);

    final event = SessionCancelledEvent(
      routineId: routine.id,
      cancelledAt: _now(),
      elapsedSeconds: elapsedSeconds,
      completedIntervalCount: completedCount,
    );

    _sessionCancelledController.add(event);
  }

  void resetToIdle() {
    _stopUiTicker();
    final routine = state.routine;
    state = TimerState(routine: routine);
  }

  void onAppLifecyclePaused() {
    if (state.status != TimerStatus.running) return;
    _recalculateFromTimestamps();
  }

  void onAppLifecycleResumed() {
    if (state.status != TimerStatus.running) return;
    _recalculateFromTimestamps();
    _processDomainTick();
  }

  void _startUiTicker() {
    _uiTicker?.cancel();
    _uiTicker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _processDomainTick();
    });
  }

  void _stopUiTicker() {
    _uiTicker?.cancel();
    _uiTicker = null;
  }

  void _processDomainTick() {
    if (state.status != TimerStatus.running) return;

    _recalculateFromTimestamps();

    if (state.isPausePending) return;

    if (state.remainingMs <= 0) {
      _onIntervalCompleted();
    } else {
      state = state.copyWith(tick: state.tick + 1);
    }
  }

  void _recalculateFromTimestamps() {
    if (state.status != TimerStatus.running) return;
    final remaining = _calculateRemainingMs();
    state = state.copyWith(remainingMs: remaining);
  }

  int _calculateRemainingMs() {
    final segmentStart = state.segmentStartTimestamp;
    if (segmentStart == null) return state.remainingMs;

    final elapsed =
        _now().difference(segmentStart).inMilliseconds - state.pausedAccumulatedMs;
    return (state.currentIntervalDurationMs - elapsed).clamp(0, 999999999);
  }

  void _onIntervalCompleted() {
    if (state.isPausePending) return;

    final routine = state.routine;
    if (routine == null) return;

    if (state.currentIndex >= routine.items.length - 1) {
      _completeSession();
      return;
    }

    _advanceToIndex(state.currentIndex + 1, keepRunning: true);
  }

  void _advanceToIndex(int index, {required bool keepRunning}) {
    final routine = state.routine;
    if (routine == null) return;

    final interval = _intervalAt(routine, index);
    if (interval == null) return;

    final durationMs = interval.durationSeconds * 1000;
    final now = _now();

    state = state.copyWith(
      status: keepRunning ? TimerStatus.running : state.status,
      currentIndex: index,
      remainingMs: durationMs,
      currentIntervalDurationMs: durationMs,
      segmentStartTimestamp: now,
      pausedAccumulatedMs: 0,
      isPausePending: false,
      tick: state.tick + 1,
    );

    if (keepRunning && _uiTicker == null) {
      _startUiTicker();
    }
  }

  void _completeSession() {
    final routine = state.routine;
    if (routine == null) return;

    _stopUiTicker();

    final totalElapsed = _elapsedSessionSeconds();
    final intervalCount = routine.items.length;

    final event = SessionCompletedEvent(
      routineId: routine.id,
      completedAt: _now(),
      totalElapsedSeconds: totalElapsed,
      intervalCount: intervalCount,
    );

    _sessionCompletedController.add(event);

    state = state.copyWith(
      status: TimerStatus.completed,
      remainingMs: 0,
      isPausePending: false,
    );
  }

  int _elapsedSessionSeconds() {
    final sessionStart = state.sessionStartTimestamp;
    if (sessionStart == null) return 0;
    return _now().difference(sessionStart).inSeconds;
  }

  Interval? _intervalAt(Routine routine, int index) {
    if (index < 0 || index >= routine.items.length) return null;
    final item = routine.items[index];
    return switch (item) {
      IntervalRoutineItem(:final interval) => interval,
    };
  }

  @visibleForTesting
  int calculateRemainingMsForTest() => _calculateRemainingMs();

  @visibleForTesting
  void processDomainTickForTest() => _processDomainTick();
}
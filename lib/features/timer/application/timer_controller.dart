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
  final _intervalStartedController =
      StreamController<IntervalStartedEvent>.broadcast(sync: true);

  Stream<SessionCompletedEvent> get sessionCompletedStream =>
      _sessionCompletedController.stream;

  Stream<SessionCancelledEvent> get sessionCancelledStream =>
      _sessionCancelledController.stream;

  Stream<IntervalStartedEvent> get intervalStartedStream =>
      _intervalStartedController.stream;

  @override
  TimerState build() {
    ref.onDispose(() {
      _uiTicker?.cancel();
      _sessionCompletedController.close();
      _sessionCancelledController.close();
      _intervalStartedController.close();
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

  /// Loads an ephemeral session into memory.
  void loadSession({
    required String sessionId,
    required String sessionName,
    required List<Interval> intervals,
  }) {
    loadFlattenedWorkout(
      workoutId: sessionId,
      workoutName: sessionName,
      flattened: intervals,
    );
  }


  /// Starts a session. [prepSeconds] is snapshotted once (R20); default 0
  /// preserves F01 unit-test behavior (prep comes from Settings in the UI).
  bool start({int prepSeconds = 0}) {
    final routine = state.routine;
    if (routine == null || routine.items.isEmpty) return false;
    if (state.status != TimerStatus.idle) return false;

    final first = _intervalAt(routine, 0);
    if (first == null) return false;

    final now = _now();
    final sessionPrep = prepSeconds.clamp(0, 60);

    if (sessionPrep > 0) {
      final prepMs = sessionPrep * 1000;
      state = state.copyWith(
        status: TimerStatus.preparing,
        segmentKind: SegmentKind.preparation,
        sessionPrepSeconds: sessionPrep,
        currentIndex: 0,
        remainingMs: prepMs,
        currentIntervalDurationMs: prepMs,
        segmentStartTimestamp: now,
        pausedAccumulatedMs: 0,
        sessionStartTimestamp: now,
        isPausePending: false,
        tick: 0,
      );
      _startUiTicker();
      return true;
    }

    final durationMs = first.durationSeconds * 1000;
    state = state.copyWith(
      status: TimerStatus.running,
      segmentKind: SegmentKind.interval,
      sessionPrepSeconds: 0,
      currentIndex: 0,
      remainingMs: durationMs,
      currentIntervalDurationMs: durationMs,
      segmentStartTimestamp: now,
      pausedAccumulatedMs: 0,
      sessionStartTimestamp: now,
      isPausePending: false,
      tick: 0,
    );
    _emitIntervalStarted(first, 0);
    _startUiTicker();
    return true;
  }

  void pause() {
    if (state.status != TimerStatus.running &&
        state.status != TimerStatus.preparing) {
      return;
    }

    // R16/R19: set flag first so domain tick cannot advance segment.
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
    final nextStatus = state.segmentKind == SegmentKind.preparation
        ? TimerStatus.preparing
        : TimerStatus.running;

    // Reconstruct segmentStart so remaining keeps the frozen value from pause.
    // Setting start=now with full currentIntervalDurationMs would reset the
    // segment to its full length on the next tick (wrong).
    final durationMs = state.currentIntervalDurationMs;
    final remainingMs = state.remainingMs.clamp(0, durationMs);
    final elapsedSoFar = (durationMs - remainingMs).clamp(0, durationMs);

    state = state.copyWith(
      status: nextStatus,
      segmentStartTimestamp:
          now.subtract(Duration(milliseconds: elapsedSoFar)),
      pausedAccumulatedMs: 0,
      isPausePending: false,
      remainingMs: remainingMs,
    );
    _startUiTicker();
  }

  /// Advances to the next section (R1) or ends prep (R13).
  void skipForward() {
    if (!state.isSessionActive) return;

    final routine = state.routine;
    if (routine == null) return;

    if (state.isInPreparation) {
      _beginIntervalAt(0);
      return;
    }

    if (state.currentIndex >= routine.items.length - 1) {
      _completeSession();
      return;
    }

    _beginIntervalAt(state.currentIndex + 1);
  }

  /// Backward-compatible alias for [skipForward].
  void skip() => skipForward();

  /// Goes to previous interval full, or restarts index 0 (R2/R3). No-op in prep.
  void skipBack() {
    if (!state.canSkipBack) return;

    final routine = state.routine;
    if (routine == null) return;

    if (state.currentIndex <= 0) {
      _beginIntervalAt(0);
      return;
    }

    _beginIntervalAt(state.currentIndex - 1);
  }

  void cancel() {
    if (!state.isSessionActive) return;

    final routine = state.routine;
    if (routine == null) return;

    final elapsedSeconds = _elapsedSessionSeconds();
    final completedCount =
        state.isInPreparation ? 0 : state.currentIndex;

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
    if (state.status != TimerStatus.running &&
        state.status != TimerStatus.preparing) {
      return;
    }
    _recalculateFromTimestamps();
  }

  void onAppLifecycleResumed() {
    if (state.status != TimerStatus.running &&
        state.status != TimerStatus.preparing) {
      return;
    }
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
    if (state.status != TimerStatus.running &&
        state.status != TimerStatus.preparing) {
      return;
    }

    _recalculateFromTimestamps();

    if (state.isPausePending) return;

    if (state.remainingMs <= 0) {
      if (state.segmentKind == SegmentKind.preparation) {
        _beginIntervalAt(0);
      } else {
        _onIntervalCompleted();
      }
    } else {
      state = state.copyWith(tick: state.tick + 1);
    }
  }

  void _recalculateFromTimestamps() {
    if (state.status != TimerStatus.running &&
        state.status != TimerStatus.preparing) {
      return;
    }
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

    _beginIntervalAt(state.currentIndex + 1);
  }

  void _beginIntervalAt(int index) {
    final routine = state.routine;
    if (routine == null) return;

    final interval = _intervalAt(routine, index);
    if (interval == null) return;

    final durationMs = interval.durationSeconds * 1000;
    final now = _now();

    state = state.copyWith(
      status: TimerStatus.running,
      segmentKind: SegmentKind.interval,
      currentIndex: index,
      remainingMs: durationMs,
      currentIntervalDurationMs: durationMs,
      segmentStartTimestamp: now,
      pausedAccumulatedMs: 0,
      isPausePending: false,
      tick: state.tick + 1,
    );

    _emitIntervalStarted(interval, index);

    if (_uiTicker == null) {
      _startUiTicker();
    }
  }

  void _emitIntervalStarted(Interval interval, int index) {
    if (_intervalStartedController.isClosed) return;
    _intervalStartedController.add(
      IntervalStartedEvent(
        intervalId: interval.id,
        name: interval.name,
        announceText: interval.announceText,
        durationSeconds: interval.durationSeconds,
        index: index,
        type: interval.type,
      ),
    );
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
      segmentKind: SegmentKind.interval,
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

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:interval_timer/data/models/interval.dart';
import 'package:interval_timer/data/models/routine.dart';
import 'package:interval_timer/data/models/routine_item.dart';

part 'timer_state.freezed.dart';

enum TimerStatus { idle, preparing, running, paused, completed }

/// Which segment the remaining/timestamps apply to.
enum SegmentKind { preparation, interval }

@freezed
abstract class TimerState with _$TimerState {
  const factory TimerState({
    @Default(TimerStatus.idle) TimerStatus status,
    Routine? routine,
    @Default(0) int currentIndex,
    @Default(0) int remainingMs,
    @Default(0) int currentIntervalDurationMs,
    @Default(false) bool isPausePending,
    DateTime? segmentStartTimestamp,
    @Default(0) int pausedAccumulatedMs,
    DateTime? sessionStartTimestamp,
    @Default(0) int tick,
    /// Snapshot of prep seconds taken at [TimerController.start] (R20).
    @Default(0) int sessionPrepSeconds,
    @Default(SegmentKind.interval) SegmentKind segmentKind,
  }) = _TimerState;

  const TimerState._();

  /// True while counting down prep, including pause that started from prep.
  bool get isInPreparation =>
      status == TimerStatus.preparing ||
      (status == TimerStatus.paused &&
          segmentKind == SegmentKind.preparation);

  /// Active session (prep, running, or paused mid-session).
  bool get isSessionActive =>
      status == TimerStatus.preparing ||
      status == TimerStatus.running ||
      status == TimerStatus.paused;

  Interval? get currentInterval {
    if (isInPreparation) return null;
    final items = routine?.items;
    if (items == null || currentIndex >= items.length) return null;
    final item = items[currentIndex];
    return switch (item) {
      IntervalRoutineItem(:final interval) => interval,
    };
  }

  /// Next segment preview: during prep → first interval; otherwise next after current.
  Interval? get nextInterval {
    final items = routine?.items;
    if (items == null || items.isEmpty) return null;
    final nextIndex = isInPreparation ? 0 : currentIndex + 1;
    if (nextIndex >= items.length) return null;
    final item = items[nextIndex];
    return switch (item) {
      IntervalRoutineItem(:final interval) => interval,
    };
  }

  bool get hasNextInterval => nextInterval != null;

  double get remainingFraction {
    if (currentIntervalDurationMs <= 0) return 0;
    return (remainingMs / currentIntervalDurationMs).clamp(0.0, 1.0);
  }

  int get intervalCount => routine?.items.length ?? 0;

  /// Total remaining session time (R8). Frozen when [status] is paused.
  int get totalRemainingMs {
    final items = routine?.items;
    if (items == null || items.isEmpty) return remainingMs.clamp(0, 999999999);

    int sumMs = remainingMs.clamp(0, 999999999);
    if (isInPreparation) {
      for (final item in items) {
        sumMs += _intervalDurationMs(item);
      }
      return sumMs;
    }

    for (var i = currentIndex + 1; i < items.length; i++) {
      sumMs += _intervalDurationMs(items[i]);
    }
    return sumMs;
  }

  /// Skip-back is a no-op during preparation (R13, R18).
  bool get canSkipBack =>
      (status == TimerStatus.running || status == TimerStatus.paused) &&
      !isInPreparation;

  bool get canSkipForward => isSessionActive;

  static int _intervalDurationMs(RoutineItem item) {
    return switch (item) {
      IntervalRoutineItem(:final interval) => interval.durationSeconds * 1000,
    };
  }
}

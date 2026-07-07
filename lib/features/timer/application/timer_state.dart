import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:interval_timer/data/models/interval.dart';
import 'package:interval_timer/data/models/routine.dart';
import 'package:interval_timer/data/models/routine_item.dart';

part 'timer_state.freezed.dart';

enum TimerStatus { idle, running, paused, completed }

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
  }) = _TimerState;

  const TimerState._();

  Interval? get currentInterval {
    final items = routine?.items;
    if (items == null || currentIndex >= items.length) return null;
    final item = items[currentIndex];
    return switch (item) {
      IntervalRoutineItem(:final interval) => interval,
    };
  }

  Interval? get nextInterval {
    final items = routine?.items;
    if (items == null || currentIndex + 1 >= items.length) return null;
    final item = items[currentIndex + 1];
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
}
import 'package:interval_timer/features/timer/application/timer_state.dart';

/// Pure policy: whether the screen wakelock should be active (F19).
abstract final class KeepScreenOnPolicy {
  /// Returns true when status is [TimerStatus.running] or [TimerStatus.preparing],
  /// pref is on, and the execution host screen is mounted.
  static bool shouldKeepScreenOn({
    required TimerStatus sessionStatus,
    required bool keepScreenOnEnabled,
    required bool executionHostMounted,
  }) {
    if (!keepScreenOnEnabled) return false;
    if (!executionHostMounted) return false;
    return sessionStatus == TimerStatus.running ||
        sessionStatus == TimerStatus.preparing;
  }
}

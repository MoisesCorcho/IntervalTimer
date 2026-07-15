import 'package:interval_timer/features/timer/application/timer_state.dart';

/// Pure policy: whether the external session surface should be visible (F20).
abstract final class SessionSurfacePolicy {
  /// Returns true for preparing/running/paused when pref is on and permission
  /// is granted. Idle/completed never show a surface (R1, R14, R17).
  static bool shouldShowSessionSurface({
    required TimerStatus sessionStatus,
    required bool sessionLockScreenEnabled,
    required bool notificationPermissionGranted,
  }) {
    if (!sessionLockScreenEnabled) return false;
    if (!notificationPermissionGranted) return false;
    return sessionStatus == TimerStatus.running ||
        sessionStatus == TimerStatus.paused ||
        sessionStatus == TimerStatus.preparing;
  }
}

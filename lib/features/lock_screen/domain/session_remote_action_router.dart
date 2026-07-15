import 'package:interval_timer/features/lock_screen/domain/session_remote_action.dart';
import 'package:interval_timer/features/timer/application/timer_controller.dart';

/// Dispatches [SessionRemoteAction] to F01 public API (no internal mutation).
abstract final class SessionRemoteActionRouter {
  static void dispatch(SessionRemoteAction action, TimerController timer) {
    switch (action) {
      case SessionRemoteAction.pause:
        timer.pause();
      case SessionRemoteAction.resume:
        timer.resume();
      case SessionRemoteAction.skip:
        timer.skip();
      case SessionRemoteAction.openApp:
        // Bringing the app to foreground is handled by the OS / notification
        // payload; router already redirects to /execute when session is active.
        break;
    }
  }
}

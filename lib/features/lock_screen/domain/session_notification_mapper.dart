import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/features/lock_screen/domain/session_notification_snapshot.dart';
import 'package:interval_timer/features/timer/application/timer_state.dart';

/// Maps F01 [TimerState] → presentation snapshot for F20 surfaces.
abstract final class SessionNotificationMapper {
  static SessionNotificationSnapshot fromTimerState(TimerState state) {
    final status = _statusLabel(state.status);
    final title = _titleFor(state);
    final showPause = state.status == TimerStatus.running ||
        state.status == TimerStatus.preparing;
    final showResume = state.status == TimerStatus.paused;
    final showSkip = state.status == TimerStatus.running ||
        state.status == TimerStatus.paused ||
        state.status == TimerStatus.preparing;

    return SessionNotificationSnapshot(
      status: status,
      title: title,
      remainingMs: state.remainingMs,
      showPause: showPause,
      showResume: showResume,
      showSkip: showSkip,
    );
  }

  static String _statusLabel(TimerStatus status) {
    return switch (status) {
      TimerStatus.preparing => 'preparing',
      TimerStatus.running => 'running',
      TimerStatus.paused => 'paused',
      TimerStatus.idle => 'idle',
      TimerStatus.completed => 'completed',
    };
  }

  static String _titleFor(TimerState state) {
    if (state.isInPreparation || state.status == TimerStatus.preparing) {
      return UiStrings.preparation;
    }
    final name = state.currentInterval?.name;
    if (name != null && name.trim().isNotEmpty) return name.trim();
    return UiStrings.sessionSurfaceFallbackTitle;
  }
}

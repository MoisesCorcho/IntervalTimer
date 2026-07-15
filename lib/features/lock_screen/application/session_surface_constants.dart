/// Shared IDs for F20 session surface (must not collide with F14 reminders).
abstract final class SessionSurfaceConstants {
  /// Android notification channel for ongoing session (distinct from F14).
  ///
  /// Suffix `_v2`: prior installs used importance=low (hides actions). New id
  /// forces a channel with default importance so Pausar/Reanudar/Saltar show.
  static const channelId = 'session_timer_ongoing_v2';

  static const channelName = 'Sesión de entrenamiento';

  static const channelDescription =
      'Notificación persistente del temporizador de intervalos.';

  /// Fixed notification id for in-place updates.
  static const notificationId = 888;

  static const actionPause = 'session_pause';
  static const actionResume = 'session_resume';
  static const actionSkip = 'session_skip';
  static const actionOpenApp = 'session_open';

  /// IsolateNameServer port for notification actions (background → UI).
  static const actionPortName = 'interval_timer_session_lock_actions';

  /// App Group for Live Activities (phase B). Must match Xcode capability.
  static const liveActivitiesAppGroupId = 'group.com.example.interval_timer';

  static const liveActivityId = 'interval_timer_session';
}

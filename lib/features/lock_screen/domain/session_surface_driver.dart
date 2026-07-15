import 'package:interval_timer/features/lock_screen/domain/session_notification_snapshot.dart';
import 'package:interval_timer/features/lock_screen/domain/session_remote_action.dart';

/// Abstraction over notification / FGS / Live Activity surface (F20).
///
/// Testable without platform plugins. Failures must not throw into the timer.
abstract class SessionSurfaceDriver {
  /// Whether notification (or equivalent) permission is currently granted.
  Future<bool> isPermissionGranted();

  /// Contextual permission request (not cold-start spam).
  Future<bool> requestPermission();

  /// Show or update the ongoing session surface with [snapshot].
  Future<void> showOrUpdate(SessionNotificationSnapshot snapshot);

  /// Remove notification / end Live Activity / stop FGS as needed.
  Future<void> hide();

  /// Open system notification / app settings (R14).
  Future<void> openSystemSettings();

  /// Remote actions from the surface (pause/resume/skip/openApp).
  Stream<SessionRemoteAction> get remoteActions;
}

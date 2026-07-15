import 'dart:async';

import 'package:interval_timer/features/lock_screen/domain/session_notification_snapshot.dart';
import 'package:interval_timer/features/lock_screen/domain/session_remote_action.dart';
import 'package:interval_timer/features/lock_screen/domain/session_surface_driver.dart';

/// No-op driver for tests and platforms without session surface support.
class NoOpSessionSurfaceDriver implements SessionSurfaceDriver {
  NoOpSessionSurfaceDriver({this.permissionGranted = true});

  bool permissionGranted;
  int showCount = 0;
  int hideCount = 0;
  SessionNotificationSnapshot? lastSnapshot;
  bool throwOnShow = false;
  bool throwOnHide = false;

  final _actions = StreamController<SessionRemoteAction>.broadcast();

  void emitAction(SessionRemoteAction action) => _actions.add(action);

  @override
  Stream<SessionRemoteAction> get remoteActions => _actions.stream;

  @override
  Future<bool> isPermissionGranted() async => permissionGranted;

  @override
  Future<bool> requestPermission() async {
    permissionGranted = true;
    return permissionGranted;
  }

  @override
  Future<void> showOrUpdate(SessionNotificationSnapshot snapshot) async {
    if (throwOnShow) throw Exception('show failed');
    showCount++;
    lastSnapshot = snapshot;
  }

  @override
  Future<void> hide() async {
    if (throwOnHide) throw Exception('hide failed');
    hideCount++;
    lastSnapshot = null;
  }

  @override
  Future<void> openSystemSettings() async {}

  void dispose() {
    unawaited(_actions.close());
  }
}

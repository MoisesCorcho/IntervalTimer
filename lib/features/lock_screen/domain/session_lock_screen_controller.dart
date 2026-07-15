import 'package:flutter/foundation.dart';
import 'package:interval_timer/features/lock_screen/domain/session_notification_mapper.dart';
import 'package:interval_timer/features/lock_screen/domain/session_notification_snapshot.dart';
import 'package:interval_timer/features/lock_screen/domain/session_surface_driver.dart';
import 'package:interval_timer/features/lock_screen/domain/session_surface_policy.dart';
import 'package:interval_timer/features/timer/application/timer_state.dart';

/// Orchestrates session surface show/update/hide from F01 + prefs (F20).
///
/// Never mutates timer state. Driver failures are swallowed (R15).
class SessionLockScreenController {
  SessionLockScreenController(
    this._driver, {
    bool sessionLockScreenEnabled = true,
    bool permissionGranted = false,
    TimerState? initialState,
  })  : _sessionLockScreenEnabled = sessionLockScreenEnabled,
        _permissionGranted = permissionGranted,
        _state = initialState ?? const TimerState();

  final SessionSurfaceDriver _driver;

  bool _sessionLockScreenEnabled;
  bool _permissionGranted;
  TimerState _state;

  /// Whether a contextual permission request already ran this process.
  bool _permissionRequested = false;

  /// Surface currently expected to be visible (idempotency).
  bool _surfaceVisible = false;

  SessionNotificationSnapshot? _lastSnapshot;
  int? _lastDisplayedSecond;

  bool get sessionLockScreenEnabled => _sessionLockScreenEnabled;
  bool get permissionGranted => _permissionGranted;
  bool get surfaceVisible => _surfaceVisible;
  SessionNotificationSnapshot? get lastSnapshot => _lastSnapshot;

  bool get desired => SessionSurfacePolicy.shouldShowSessionSurface(
        sessionStatus: _state.status,
        sessionLockScreenEnabled: _sessionLockScreenEnabled,
        notificationPermissionGranted: _permissionGranted,
      );

  Future<void> setSessionLockScreenEnabled(bool value) async {
    if (_sessionLockScreenEnabled == value) return;
    _sessionLockScreenEnabled = value;
    await sync();
  }

  Future<void> setPermissionGranted(bool value) async {
    if (_permissionGranted == value) return;
    _permissionGranted = value;
    await sync();
  }

  /// Refresh permission flag from the driver (settings UI / resume).
  Future<void> refreshPermission() async {
    try {
      _permissionGranted = await _driver.isPermissionGranted();
    } catch (e, st) {
      debugPrint('SessionLockScreenController.refreshPermission: $e\n$st');
    }
    await sync();
  }

  Future<void> onTimerState(TimerState state) async {
    _state = state;
    await sync();
  }

  /// R7: session ended → ensure hide.
  Future<void> onSessionEnded() async {
    if (_state.status != TimerStatus.idle &&
        _state.status != TimerStatus.completed) {
      _state = _state.copyWith(status: TimerStatus.idle);
    }
    await sync();
  }

  /// Applies show/update/hide according to policy + snapshot (R1–R3, R7, R9).
  Future<void> sync() async {
    try {
      if (!_sessionLockScreenEnabled || !_isActiveStatus(_state.status)) {
        await _hideIfNeeded();
        return;
      }

      if (!_permissionGranted) {
        if (!_permissionRequested) {
          _permissionRequested = true;
          try {
            _permissionGranted = await _driver.requestPermission();
          } catch (e, st) {
            debugPrint(
              'SessionLockScreenController.requestPermission: $e\n$st',
            );
            _permissionGranted = false;
          }
        }
        if (!_permissionGranted) {
          await _hideIfNeeded();
          return;
        }
      }

      if (!desired) {
        await _hideIfNeeded();
        return;
      }

      final snapshot = SessionNotificationMapper.fromTimerState(_state);
      final second = snapshot.remainingMs ~/ 1000;
      final metadataChanged = _lastSnapshot == null ||
          _lastSnapshot!.status != snapshot.status ||
          _lastSnapshot!.title != snapshot.title ||
          _lastSnapshot!.showPause != snapshot.showPause ||
          _lastSnapshot!.showResume != snapshot.showResume ||
          _lastSnapshot!.showSkip != snapshot.showSkip;

      final runningTick = (snapshot.status == 'running' ||
              snapshot.status == 'preparing') &&
          _lastDisplayedSecond != second;

      if (!_surfaceVisible || metadataChanged || runningTick) {
        await _driver.showOrUpdate(snapshot);
        _surfaceVisible = true;
        _lastSnapshot = snapshot;
        _lastDisplayedSecond = second;
      }
    } catch (e, st) {
      // R15: never affect timer.
      debugPrint('SessionLockScreenController.sync failed: $e\n$st');
    }
  }

  Future<void> _hideIfNeeded() async {
    if (!_surfaceVisible && _lastSnapshot == null) return;
    try {
      await _driver.hide();
    } catch (e, st) {
      debugPrint('SessionLockScreenController.hide failed: $e\n$st');
    }
    _surfaceVisible = false;
    _lastSnapshot = null;
    _lastDisplayedSecond = null;
  }

  static bool _isActiveStatus(TimerStatus status) {
    return status == TimerStatus.running ||
        status == TimerStatus.paused ||
        status == TimerStatus.preparing;
  }
}

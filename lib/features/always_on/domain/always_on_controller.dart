import 'package:interval_timer/features/always_on/domain/keep_screen_on_policy.dart';
import 'package:interval_timer/features/always_on/domain/wakelock_driver.dart';
import 'package:interval_timer/features/timer/application/timer_state.dart';

/// Applies screen wakelock policy from F01 status + prefs + execution host (F19).
///
/// Does not mutate timer state. Safe if [WakelockDriver] throws (R11).
class AlwaysOnController {
  AlwaysOnController(
    this._driver, {
    bool keepScreenOnEnabled = true,
    bool executionHostMounted = false,
    TimerStatus status = TimerStatus.idle,
  })  : _keepScreenOnEnabled = keepScreenOnEnabled,
        _executionHostMounted = executionHostMounted,
        _status = status;

  final WakelockDriver _driver;

  bool _keepScreenOnEnabled;
  bool _executionHostMounted;
  TimerStatus _status;

  /// Last desired state successfully applied (idempotency).
  bool? _lastApplied;

  bool get keepScreenOnEnabled => _keepScreenOnEnabled;
  bool get executionHostMounted => _executionHostMounted;
  TimerStatus get status => _status;
  bool? get lastApplied => _lastApplied;

  bool get desired => KeepScreenOnPolicy.shouldKeepScreenOn(
        sessionStatus: _status,
        keepScreenOnEnabled: _keepScreenOnEnabled,
        executionHostMounted: _executionHostMounted,
      );

  Future<void> setKeepScreenOnEnabled(bool value) async {
    if (_keepScreenOnEnabled == value) return;
    _keepScreenOnEnabled = value;
    await apply();
  }

  Future<void> setExecutionHostMounted(bool value) async {
    if (_executionHostMounted == value) return;
    _executionHostMounted = value;
    await apply();
  }

  Future<void> onTimerState(TimerState state) async {
    if (_status == state.status) return;
    _status = state.status;
    await apply();
  }

  /// R3: session ended → ensure disable (status may already be idle/completed).
  Future<void> onSessionEnded() async {
    if (_status != TimerStatus.idle && _status != TimerStatus.completed) {
      _status = TimerStatus.idle;
    }
    await apply();
  }

  /// R9: OS may have released wakelock; re-request if policy still true.
  Future<void> onAppLifecycleResumed() async {
    if (!desired) {
      await apply();
      return;
    }
    await _forceEnable();
  }

  /// Applies enable/disable when [desired] differs from [_lastApplied].
  Future<void> apply() async {
    final want = desired;
    if (_lastApplied == want) return;
    // Never enabled: skip platform disable (screen already uses default timeout).
    if (_lastApplied == null && !want) {
      _lastApplied = false;
      return;
    }
    try {
      if (want) {
        await _driver.enable();
      } else {
        await _driver.disable();
      }
      _lastApplied = want;
    } catch (_) {
      // R11: never affect timer; leave _lastApplied unchanged so we can retry.
    }
  }

  Future<void> _forceEnable() async {
    try {
      await _driver.enable();
      _lastApplied = true;
    } catch (_) {
      // R11
    }
  }
}

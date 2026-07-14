import 'package:interval_timer/features/timer/application/timer_session_events.dart';
import 'package:interval_timer/features/timer/application/timer_state.dart';
import 'package:interval_timer/features/vibration/domain/remaining_seconds.dart';
import 'package:interval_timer/features/vibration/domain/vibration_driver.dart';
import 'package:interval_timer/features/vibration/domain/vibration_pattern_resolver.dart';
import 'package:interval_timer/features/vibration/domain/vibration_settings.dart';

/// Domain service: reacts to F01 timer events/state and drives [VibrationDriver].
///
/// Does not mutate timer state or voice prefs. Safe if vibration fails (R7).
/// Independent of voice mute (R14).
class VibrationFeedbackController {
  VibrationFeedbackController(
    this._driver, {
    VibrationSettings settings = VibrationSettings.defaults,
    VibrationPatternResolver patternResolver =
        const VibrationPatternResolver(),
  })  : _settings = settings,
        _patterns = patternResolver;

  final VibrationDriver _driver;
  final VibrationPatternResolver _patterns;
  VibrationSettings _settings;

  final Set<int> _vibratedSecondsForInterval = <int>{};
  TimerStatus _lastStatus = TimerStatus.idle;

  VibrationSettings get settings => _settings;

  void updateSettings(VibrationSettings settings) {
    final wasEnabled = _settings.vibrationEnabled;
    _settings = settings;
    if (wasEnabled && !settings.vibrationEnabled) {
      // Fire-and-forget cancel on master mute.
      _cancel();
    }
  }

  Future<void> onIntervalStarted(IntervalStartedEvent event) async {
    _vibratedSecondsForInterval.clear();

    if (!_settings.vibrationEnabled) return;
    if (!_settings.vibrationOnIntervalStart) return;

    await _emit(_patterns.intervalStart);
  }

  /// Called on every [TimerState] change (remainingMs / status).
  Future<void> onTimerState(TimerState state) async {
    final status = state.status;

    if (status == TimerStatus.paused && _lastStatus != TimerStatus.paused) {
      await _cancel();
      _lastStatus = status;
      return;
    }

    if (status == TimerStatus.idle || status == TimerStatus.completed) {
      if (_lastStatus != status) {
        await _cancel();
        _vibratedSecondsForInterval.clear();
      }
      _lastStatus = status;
      return;
    }

    _lastStatus = status;

    if (status != TimerStatus.running) return;
    if (state.segmentKind != SegmentKind.interval) return;
    if (!_settings.vibrationEnabled) return;
    if (!_settings.vibrationOnCountdown) return;
    if (_settings.vibrationCountdownSeconds <= 0) return;

    final s = remainingSecondsCeil(state.remainingMs);
    if (s < 1 || s > _settings.vibrationCountdownSeconds) return;
    if (_vibratedSecondsForInterval.contains(s)) return;

    _vibratedSecondsForInterval.add(s);
    await _emit(_patterns.countdownTick);
  }

  Future<void> onSessionEnded() async {
    await _cancel();
    _vibratedSecondsForInterval.clear();
    _lastStatus = TimerStatus.idle;
  }

  Future<void> _emit(VibrationPattern pattern) async {
    try {
      await _driver.vibrate(
        durationMs: pattern.durationMs,
        pattern: pattern.pattern,
      );
    } catch (_) {
      // R7: never affect timer; swallow vibration errors.
    }
  }

  Future<void> _cancel() async {
    try {
      await _driver.cancel();
    } catch (_) {}
  }
}

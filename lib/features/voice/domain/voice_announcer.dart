import 'package:interval_timer/features/timer/application/timer_session_events.dart';
import 'package:interval_timer/features/timer/application/timer_state.dart';
import 'package:interval_timer/features/voice/domain/announce_text.dart';
import 'package:interval_timer/features/voice/domain/tts_engine.dart';
import 'package:interval_timer/features/voice/domain/voice_settings.dart';

/// Domain service: reacts to F01 timer events/state and drives [TtsEngine].
///
/// Does not mutate timer state. Safe if TTS fails (R8).
class VoiceAnnouncer {
  VoiceAnnouncer(
    this._engine, {
    VoiceSettings settings = VoiceSettings.defaults,
  }) : _settings = settings;

  final TtsEngine _engine;
  VoiceSettings _settings;

  final Set<int> _spokenSecondsForInterval = <int>{};
  TimerStatus _lastStatus = TimerStatus.idle;

  VoiceSettings get settings => _settings;

  void updateSettings(VoiceSettings settings) {
    final wasEnabled = _settings.voiceEnabled;
    _settings = settings;
    if (wasEnabled && !settings.voiceEnabled) {
      // Fire-and-forget stop on mute.
      _engine.stop();
    }
  }

  Future<void> onIntervalStarted(IntervalStartedEvent event) async {
    _spokenSecondsForInterval.clear();

    if (!_settings.voiceEnabled) return;
    if (!_settings.announceIntervalName) return;

    final text = resolveAnnounceText(
      name: event.name,
      announceText: event.announceText,
    );
    await _speakInterrupt(text);
  }

  /// Called on every [TimerState] change (remainingMs / status).
  Future<void> onTimerState(TimerState state) async {
    final status = state.status;

    if (status == TimerStatus.paused &&
        _lastStatus != TimerStatus.paused) {
      await _stop();
      _lastStatus = status;
      return;
    }

    if (status == TimerStatus.idle || status == TimerStatus.completed) {
      if (_lastStatus != status) {
        await _stop();
        _spokenSecondsForInterval.clear();
      }
      _lastStatus = status;
      return;
    }

    _lastStatus = status;

    if (status != TimerStatus.running) return;
    if (state.segmentKind != SegmentKind.interval) return;
    if (!_settings.voiceEnabled) return;
    if (_settings.countdownSeconds <= 0) return;

    final s = remainingSecondsCeil(state.remainingMs);
    if (s < 1 || s > _settings.countdownSeconds) return;
    if (_spokenSecondsForInterval.contains(s)) return;

    _spokenSecondsForInterval.add(s);
    await _speakInterrupt('$s');
  }

  Future<void> onSessionEnded() async {
    await _stop();
    _spokenSecondsForInterval.clear();
    _lastStatus = TimerStatus.idle;
  }

  Future<void> _speakInterrupt(String text) async {
    try {
      await _engine.stop();
      await _engine.speak(text);
    } catch (_) {
      // R8: never affect timer; swallow TTS errors.
    }
  }

  Future<void> _stop() async {
    try {
      await _engine.stop();
    } catch (_) {}
  }
}

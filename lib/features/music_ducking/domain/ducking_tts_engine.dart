import 'dart:async';

import 'package:interval_timer/features/music_ducking/domain/audio_session_manager.dart';
import 'package:interval_timer/features/voice/domain/tts_engine.dart';

/// Decorator for [TtsEngine] that coordinates background music ducking (F17).
///
/// If ducking is enabled:
/// - Activates ducking before speaking.
/// - Starts a 5-second fail-safe timer.
/// - Deactivates ducking when speaking completes or errors.
/// - Cancels ducking immediately on [stop].
class DuckingTtsEngine implements TtsEngine {
  DuckingTtsEngine({
    required TtsEngine inner,
    required AudioSessionManager audioSessionManager,
    required bool Function() isDuckingEnabled,
    Duration failSafeTimeout = const Duration(seconds: 5),
  })  : _inner = inner,
        _audioSessionManager = audioSessionManager,
        _isDuckingEnabled = isDuckingEnabled,
        _failSafeTimeout = failSafeTimeout;

  final TtsEngine _inner;
  final AudioSessionManager _audioSessionManager;
  final bool Function() _isDuckingEnabled;
  final Duration _failSafeTimeout;

  final List<Timer> _activeTimers = <Timer>[];
  int _activeDuckings = 0;

  @override
  Future<bool> isAvailable() => _inner.isAvailable();

  @override
  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;

    final shouldDuck = _isDuckingEnabled();
    Timer? failSafeTimer;

    if (shouldDuck) {
      _activeDuckings++;
      await _audioSessionManager.activateDucking();

      failSafeTimer = Timer(_failSafeTimeout, () async {
        _activeTimers.remove(failSafeTimer);
        if (_activeDuckings > 0) {
          _activeDuckings--;
          await _audioSessionManager.deactivateDucking();
        }
      });
      _activeTimers.add(failSafeTimer);
    }

    try {
      await _inner.speak(text);
    } finally {
      if (shouldDuck &&
          failSafeTimer != null &&
          _activeTimers.remove(failSafeTimer)) {
        failSafeTimer.cancel();
        if (_activeDuckings > 0) {
          _activeDuckings--;
          await _audioSessionManager.deactivateDucking();
        }
      }
    }
  }

  @override
  Future<void> stop() async {
    for (final timer in _activeTimers) {
      timer.cancel();
    }
    _activeTimers.clear();

    while (_activeDuckings > 0) {
      _activeDuckings--;
      await _audioSessionManager.deactivateDucking();
    }

    await _inner.stop();
  }
}

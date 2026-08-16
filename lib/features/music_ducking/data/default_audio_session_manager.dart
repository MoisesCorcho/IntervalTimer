import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:interval_timer/features/music_ducking/domain/audio_session_manager.dart';

/// Default implementation of [AudioSessionManager] using [AudioSession].
class DefaultAudioSessionManager implements AudioSessionManager {
  DefaultAudioSessionManager({AudioSession? session}) : _session = session;

  AudioSession? _session;
  int _activeDuckingCount = 0;
  bool _configured = false;

  @override
  bool get isDuckingActive => _activeDuckingCount > 0;

  @visibleForTesting
  int get activeDuckingCount => _activeDuckingCount;

  @override
  Future<void> initialize() async {
    if (_configured) return;
    try {
      _session ??= await AudioSession.instance;
      await _session?.configure(AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers |
            AVAudioSessionCategoryOptions.duckOthers,
        avAudioSessionMode: AVAudioSessionMode.spokenAudio,
        androidAudioAttributes: const AndroidAudioAttributes(
          contentType: AndroidAudioContentType.speech,
          usage: AndroidAudioUsage.assistanceNavigationGuidance,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransientMayDuck,
      ));
      _configured = true;
    } catch (e, st) {
      debugPrint('DefaultAudioSessionManager.initialize error: $e\n$st');
    }
  }

  @override
  Future<void> activateDucking() async {
    _activeDuckingCount++;
    if (_activeDuckingCount == 1) {
      try {
        await initialize();
        await _session?.setActive(true);
      } catch (e, st) {
        debugPrint('DefaultAudioSessionManager.activateDucking error: $e\n$st');
      }
    }
  }

  @override
  Future<void> deactivateDucking() async {
    if (_activeDuckingCount > 0) {
      _activeDuckingCount--;
    }
    if (_activeDuckingCount == 0) {
      try {
        await _session?.setActive(false);
      } catch (e, st) {
        debugPrint('DefaultAudioSessionManager.deactivateDucking error: $e\n$st');
      }
    }
  }
}

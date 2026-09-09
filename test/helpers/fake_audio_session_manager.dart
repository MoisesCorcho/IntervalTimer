import 'package:interval_timer/features/music_ducking/domain/audio_session_manager.dart';

class FakeAudioSessionManager implements AudioSessionManager {
  int initializeCount = 0;
  int activateCount = 0;
  int deactivateCount = 0;
  int _activeCount = 0;

  bool shouldThrowOnActivate = false;
  bool shouldThrowOnDeactivate = false;

  @override
  bool get isDuckingActive => _activeCount > 0;

  int get activeDuckingCount => _activeCount;

  @override
  Future<void> initialize() async {
    initializeCount++;
  }

  @override
  Future<void> activateDucking() async {
    activateCount++;
    if (shouldThrowOnActivate) {
      throw Exception('AudioSession activate failure');
    }
    _activeCount++;
  }

  @override
  Future<void> deactivateDucking() async {
    deactivateCount++;
    if (shouldThrowOnDeactivate) {
      throw Exception('AudioSession deactivate failure');
    }
    if (_activeCount > 0) {
      _activeCount--;
    }
  }

  void reset() {
    initializeCount = 0;
    activateCount = 0;
    deactivateCount = 0;
    _activeCount = 0;
    shouldThrowOnActivate = false;
    shouldThrowOnDeactivate = false;
  }
}

/// Interface for platform audio session management and ducking (F17).
abstract class AudioSessionManager {
  /// Configures global audio session for playback and background mixing.
  Future<void> initialize();

  /// Requests transient audio focus with ducking of external background music.
  Future<void> activateDucking();

  /// Releases transient audio focus, restoring normal external music volume.
  Future<void> deactivateDucking();

  /// Whether audio ducking is currently active.
  bool get isDuckingActive;
}

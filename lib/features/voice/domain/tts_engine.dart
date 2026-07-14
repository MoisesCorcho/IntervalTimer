/// Abstraction over TTS backends (F02 system; F07 adds premium).
abstract class TtsEngine {
  Future<void> speak(String text);

  Future<void> stop();

  Future<bool> isAvailable();
}

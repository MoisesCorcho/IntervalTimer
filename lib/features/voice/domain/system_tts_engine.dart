import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:interval_timer/features/voice/domain/tts_engine.dart';

/// System TTS via [flutter_tts] (native Android/iOS engines).
class SystemTtsEngine implements TtsEngine {
  SystemTtsEngine({FlutterTts? flutterTts})
      : _tts = flutterTts ?? FlutterTts() {
    _tts.setErrorHandler((msg) {
      debugPrint('SystemTtsEngine error: $msg');
    });
    _ensureConfigured();
  }

  final FlutterTts _tts;
  bool _configured = false;

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    try {
      await _tts.setVolume(1.0);
      await _tts.awaitSpeakCompletion(true);
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        await _tts.setAudioAttributesForNavigation();
      } else if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        await _tts.setSharedInstance(true);
        await _tts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
            IosTextToSpeechAudioCategoryOptions.duckOthers,
          ],
          IosTextToSpeechAudioMode.voicePrompt,
        );
      }
      final locale = PlatformDispatcher.instance.locale;
      final languageTag = locale.toLanguageTag();
      final available = await _tts.isLanguageAvailable(languageTag);
      if (available == true) {
        await _tts.setLanguage(languageTag);
      } else {
        final fallback = '${locale.languageCode}-${locale.countryCode ?? locale.languageCode.toUpperCase()}';
        final ok = await _tts.isLanguageAvailable(fallback);
        if (ok == true) {
          await _tts.setLanguage(fallback);
        }
      }
    } catch (e, st) {
      debugPrint('SystemTtsEngine configure failed: $e\n$st');
    }
    _configured = true;
  }

  @override
  Future<bool> isAvailable() async {
    try {
      await _ensureConfigured();
      final languages = await _tts.getLanguages;
      return languages != null;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    try {
      await _ensureConfigured();
      await _tts.speak(text);
    } catch (e, st) {
      debugPrint('SystemTtsEngine.speak failed: $e\n$st');
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (e, st) {
      debugPrint('SystemTtsEngine.stop failed: $e\n$st');
    }
  }
}

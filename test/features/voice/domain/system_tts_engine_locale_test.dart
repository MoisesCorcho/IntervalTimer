import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:interval_timer/features/voice/domain/system_tts_engine.dart';

class MockFlutterTts extends FlutterTts {
  final List<String> setLanguages = [];
  final List<String> spokenTexts = [];
  final Set<String> availableLanguages = {'en-US', 'en', 'es-ES', 'es'};

  @override
  void setErrorHandler(ErrorHandler handler) {}

  @override
  Future<dynamic> setVolume(double volume) async => 1;

  @override
  Future<dynamic> awaitSpeakCompletion(bool awaitCompletion) async => 1;

  @override
  Future<dynamic> setAudioAttributesForNavigation() async => 1;

  @override
  Future<dynamic> isLanguageAvailable(String language) async {
    return availableLanguages.contains(language);
  }

  @override
  Future<dynamic> setLanguage(String language) async {
    setLanguages.add(language);
    return 1;
  }

  @override
  Future<dynamic> speak(String text, {bool focus = false}) async {
    spokenTexts.add(text);
    return 1;
  }

  @override
  Future<dynamic> stop() async => 1;

  @override
  Future<dynamic> get getLanguages async => availableLanguages.toList();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SystemTtsEngine locale synchronization and fallback (R5, R11)', () {
    test('initializes with specified locale', () async {
      final mock = MockFlutterTts();
      final engine = SystemTtsEngine(
        flutterTts: mock,
        initialLocale: const Locale('es'),
      );

      // Trigger initialization by checking availability or speaking
      await engine.isAvailable();

      expect(mock.setLanguages, contains('es'));
    });

    test('dynamically updates locale on setLocale (R5)', () async {
      final mock = MockFlutterTts();
      final engine = SystemTtsEngine(
        flutterTts: mock,
        initialLocale: const Locale('es'),
      );

      await engine.setLocale(const Locale('en'));

      expect(mock.setLanguages.last, equals('en'));
    });

    test('falls back to base language when full tag not available (R11)', () async {
      final mock = MockFlutterTts();
      // 'es-CO' is not in availableLanguages, but 'es' is
      mock.availableLanguages.clear();
      mock.availableLanguages.add('es');

      final engine = SystemTtsEngine(flutterTts: mock);
      await engine.setLocale(const Locale('es', 'CO'));

      expect(mock.setLanguages.last, equals('es'));
    });
  });
}

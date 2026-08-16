import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/features/music_ducking/domain/ducking_tts_engine.dart';
import 'package:interval_timer/features/voice/domain/tts_engine.dart';

import '../../../helpers/fake_audio_session_manager.dart';

class StubTtsEngine implements TtsEngine {
  final List<String> speaks = <String>[];
  int stopCount = 0;
  final Map<String, Completer<void>> completers = {};
  bool shouldThrowOnSpeak = false;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<void> speak(String text) async {
    speaks.add(text);
    if (shouldThrowOnSpeak) {
      throw Exception('TTS engine speak error');
    }
    if (completers.containsKey(text)) {
      await completers[text]!.future;
    }
  }

  @override
  Future<void> stop() async {
    stopCount++;
  }
}

void main() {
  group('DuckingTtsEngine (F17)', () {
    late StubTtsEngine inner;
    late FakeAudioSessionManager audioSession;
    late bool duckingEnabled;
    late DuckingTtsEngine engine;

    setUp(() {
      inner = StubTtsEngine();
      audioSession = FakeAudioSessionManager();
      duckingEnabled = true;
      engine = DuckingTtsEngine(
        inner: inner,
        audioSessionManager: audioSession,
        isDuckingEnabled: () => duckingEnabled,
        failSafeTimeout: const Duration(seconds: 5),
      );
    });

    test('R2 & R3: activates ducking before speaking and deactivates upon completion', () async {
      expect(audioSession.activeDuckingCount, 0);
      expect(audioSession.isDuckingActive, false);

      await engine.speak('3');

      expect(inner.speaks, ['3']);
      expect(audioSession.activateCount, 1);
      expect(audioSession.deactivateCount, 1);
      expect(audioSession.activeDuckingCount, 0);
      expect(audioSession.isDuckingActive, false);
    });

    test('R6: bypasses ducking when isDuckingEnabled is false', () async {
      duckingEnabled = false;

      await engine.speak('Descanso');

      expect(inner.speaks, ['Descanso']);
      expect(audioSession.activateCount, 0);
      expect(audioSession.deactivateCount, 0);
      expect(audioSession.isDuckingActive, false);
    });

    test('empty or whitespace text does not trigger ducking or speak', () async {
      await engine.speak('');
      await engine.speak('   ');

      expect(inner.speaks, isEmpty);
      expect(audioSession.activateCount, 0);
      expect(audioSession.deactivateCount, 0);
    });

    test('R7: stop immediately releases active ducking and delegates to inner engine', () async {
      final completer = Completer<void>();
      inner.completers['Preparación'] = completer;

      // Start speak in background
      final speakFuture = engine.speak('Preparación');
      // Yield to let activateDucking complete
      await Future<void>.delayed(Duration.zero);

      expect(audioSession.activateCount, 1);
      expect(audioSession.activeDuckingCount, 1);
      expect(audioSession.isDuckingActive, true);

      // Stop while speak is awaiting
      await engine.stop();
      expect(audioSession.deactivateCount, 1);
      expect(audioSession.activeDuckingCount, 0);
      expect(audioSession.isDuckingActive, false);
      expect(inner.stopCount, 1);

      // Complete the pending speak
      completer.complete();
      await speakFuture;

      // Deactivate count should still be 1 (finally does not double deactivate)
      expect(audioSession.deactivateCount, 1);
    });

    test('R8: fail-safe timer (5s) forces ducking release if TTS hangs', () {
      fakeAsync((async) {
        final completer = Completer<void>();
        inner.completers['Anuncio largo'] = completer;

        // Start speaking
        engine.speak('Anuncio largo');
        async.flushMicrotasks();

        expect(audioSession.activateCount, 1);
        expect(audioSession.activeDuckingCount, 1);
        expect(audioSession.deactivateCount, 0);

        // Advance time 4.9s -> still active
        async.elapse(const Duration(milliseconds: 4900));
        expect(audioSession.deactivateCount, 0);
        expect(audioSession.isDuckingActive, true);

        // Advance past 5.0s -> fail-safe fires
        async.elapse(const Duration(milliseconds: 200));
        expect(audioSession.deactivateCount, 1);
        expect(audioSession.isDuckingActive, false);

        // Later completion does not double deactivate
        completer.complete();
        async.flushMicrotasks();
        expect(audioSession.deactivateCount, 1);
      });
    });

    test('R11: concurrency - consecutive speaks keep ducking active until all complete', () async {
      final completer1 = Completer<void>();
      final completer2 = Completer<void>();

      inner.completers['Primero'] = completer1;
      inner.completers['Segundo'] = completer2;

      final future1 = engine.speak('Primero');
      final future2 = engine.speak('Segundo');

      await Future<void>.delayed(Duration.zero);

      expect(audioSession.activateCount, 2);
      expect(audioSession.activeDuckingCount, 2);

      // Complete first speak
      completer1.complete();
      await future1;

      expect(audioSession.deactivateCount, 1);
      expect(audioSession.activeDuckingCount, 1);
      expect(audioSession.isDuckingActive, true);

      // Complete second speak
      completer2.complete();
      await future2;

      expect(audioSession.deactivateCount, 2);
      expect(audioSession.activeDuckingCount, 0);
      expect(audioSession.isDuckingActive, false);
    });

    test('R9 & R10: error during speak releases ducking cleanly without throwing unhandled', () async {
      inner.shouldThrowOnSpeak = true;

      await expectLater(
        engine.speak('Error test'),
        throwsA(isA<Exception>()),
      );

      // Audio ducking is still deactivated via finally
      expect(audioSession.activateCount, 1);
      expect(audioSession.deactivateCount, 1);
      expect(audioSession.activeDuckingCount, 0);
      expect(audioSession.isDuckingActive, false);
    });

    test('isAvailable forwards to inner engine', () async {
      expect(await engine.isAvailable(), true);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/models/interval_type.dart';
import 'package:interval_timer/features/timer/application/timer_session_events.dart';
import 'package:interval_timer/features/timer/application/timer_state.dart';
import 'package:interval_timer/features/voice/domain/announce_text.dart';
import 'package:interval_timer/features/voice/domain/tts_engine.dart';
import 'package:interval_timer/features/voice/domain/voice_announcer.dart';
import 'package:interval_timer/features/voice/domain/voice_settings.dart';

class FakeTtsEngine implements TtsEngine {
  final List<String> speaks = <String>[];
  int stopCount = 0;
  bool failSpeak = false;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<void> speak(String text) async {
    if (failSpeak) throw Exception('tts unavailable');
    speaks.add(text);
  }

  @override
  Future<void> stop() async {
    stopCount++;
  }
}

IntervalStartedEvent _started({
  String id = 'i1',
  String name = 'Calentamiento',
  String? announceText,
  int durationSeconds = 10,
  int index = 0,
}) {
  return IntervalStartedEvent(
    intervalId: id,
    name: name,
    announceText: announceText,
    durationSeconds: durationSeconds,
    index: index,
    type: IntervalType.work,
  );
}

TimerState _running({
  required int remainingMs,
  TimerStatus status = TimerStatus.running,
  SegmentKind segmentKind = SegmentKind.interval,
}) {
  return TimerState(
    status: status,
    remainingMs: remainingMs,
    currentIntervalDurationMs: remainingMs > 0 ? remainingMs : 1000,
    segmentKind: segmentKind,
  );
}

void main() {
  group('resolveAnnounceText', () {
    test('uses custom when non-empty', () {
      expect(
        resolveAnnounceText(name: 'Work', announceText: 'Empuja fuerte'),
        'Empuja fuerte',
      );
    });

    test('falls back to name when null or blank', () {
      expect(resolveAnnounceText(name: 'Work', announceText: null), 'Work');
      expect(resolveAnnounceText(name: 'Work', announceText: '  '), 'Work');
    });
  });

  group('VoiceAnnouncer happy path', () {
    test('speaks name on IntervalStarted when voice on', () async {
      final engine = FakeTtsEngine();
      final announcer = VoiceAnnouncer(
        engine,
        settings: const VoiceSettings(voiceEnabled: true),
      );

      await announcer.onIntervalStarted(_started(name: 'Calentamiento'));

      expect(engine.speaks, ['Calentamiento']);
      expect(engine.stopCount, greaterThanOrEqualTo(1));
    });

    test('speaks countdown digits 3,2,1 once each', () async {
      final engine = FakeTtsEngine();
      final announcer = VoiceAnnouncer(
        engine,
        settings: const VoiceSettings(
          voiceEnabled: true,
          countdownSeconds: 3,
          announceIntervalName: false,
        ),
      );

      await announcer.onIntervalStarted(_started(durationSeconds: 10));
      await announcer.onTimerState(_running(remainingMs: 3000));
      await announcer.onTimerState(_running(remainingMs: 2900));
      await announcer.onTimerState(_running(remainingMs: 2000));
      await announcer.onTimerState(_running(remainingMs: 1000));
      await announcer.onTimerState(_running(remainingMs: 500));
      await announcer.onTimerState(_running(remainingMs: 1000));

      expect(engine.speaks, ['3', '2', '1']);
    });
  });

  group('VoiceAnnouncer announceText', () {
    test('custom non-empty is spoken', () async {
      final engine = FakeTtsEngine();
      final announcer = VoiceAnnouncer(engine);

      await announcer.onIntervalStarted(
        _started(name: 'Work', announceText: 'Empuja'),
      );

      expect(engine.speaks, ['Empuja']);
    });

    test('null/blank falls back to name', () async {
      final engine = FakeTtsEngine();
      final announcer = VoiceAnnouncer(engine);

      await announcer.onIntervalStarted(
        _started(name: 'Work', announceText: '  '),
      );

      expect(engine.speaks, ['Work']);
    });
  });

  group('VoiceAnnouncer mute and toggles', () {
    test('voiceEnabled=false does not speak and stop is called on mute',
        () async {
      final engine = FakeTtsEngine();
      final announcer = VoiceAnnouncer(
        engine,
        settings: const VoiceSettings(voiceEnabled: true),
      );

      await announcer.onIntervalStarted(_started());
      expect(engine.speaks, isNotEmpty);

      announcer.updateSettings(const VoiceSettings(voiceEnabled: false));
      final stopsAfterMute = engine.stopCount;

      await announcer.onIntervalStarted(_started(name: 'Otro'));
      await announcer.onTimerState(_running(remainingMs: 2000));

      expect(engine.speaks, isNot(contains('Otro')));
      expect(engine.stopCount, greaterThanOrEqualTo(stopsAfterMute));
    });

    test('announceIntervalName=false skips R1 but allows countdown', () async {
      final engine = FakeTtsEngine();
      final announcer = VoiceAnnouncer(
        engine,
        settings: const VoiceSettings(
          announceIntervalName: false,
          countdownSeconds: 3,
        ),
      );

      await announcer.onIntervalStarted(_started(name: 'SkipMe'));
      await announcer.onTimerState(_running(remainingMs: 3000));

      expect(engine.speaks, ['3']);
    });

    test('countdownSeconds=0 omits countdown', () async {
      final engine = FakeTtsEngine();
      final announcer = VoiceAnnouncer(
        engine,
        settings: const VoiceSettings(countdownSeconds: 0),
      );

      await announcer.onIntervalStarted(_started(name: 'Start'));
      await announcer.onTimerState(_running(remainingMs: 3000));

      expect(engine.speaks, ['Start']);
    });
  });

  group('VoiceAnnouncer error and edge', () {
    test('speak failure does not throw', () async {
      final engine = FakeTtsEngine()..failSpeak = true;
      final announcer = VoiceAnnouncer(engine);

      await expectLater(
        announcer.onIntervalStarted(_started()),
        completes,
      );
    });

    test('short interval only speaks reachable S', () async {
      final engine = FakeTtsEngine();
      final announcer = VoiceAnnouncer(
        engine,
        settings: const VoiceSettings(
          announceIntervalName: false,
          countdownSeconds: 5,
        ),
      );

      await announcer.onIntervalStarted(_started(durationSeconds: 2));
      await announcer.onTimerState(_running(remainingMs: 2000));
      await announcer.onTimerState(_running(remainingMs: 1000));

      expect(engine.speaks, ['2', '1']);
    });

    test('idle and completed do not speak countdown', () async {
      final engine = FakeTtsEngine();
      final announcer = VoiceAnnouncer(
        engine,
        settings: const VoiceSettings(announceIntervalName: false),
      );

      await announcer.onTimerState(
        const TimerState(status: TimerStatus.idle, remainingMs: 2000),
      );
      await announcer.onTimerState(
        const TimerState(status: TimerStatus.completed, remainingMs: 0),
      );

      expect(engine.speaks, isEmpty);
    });

    test('pause stops and does not speak ticks while paused', () async {
      final engine = FakeTtsEngine();
      final announcer = VoiceAnnouncer(
        engine,
        settings: const VoiceSettings(announceIntervalName: false),
      );

      await announcer.onTimerState(_running(remainingMs: 3000));
      expect(engine.speaks, ['3']);

      final stopsBefore = engine.stopCount;
      await announcer.onTimerState(
        _running(remainingMs: 2500, status: TimerStatus.paused),
      );
      expect(engine.stopCount, greaterThan(stopsBefore));

      await announcer.onTimerState(
        _running(remainingMs: 2000, status: TimerStatus.paused),
      );
      expect(engine.speaks, ['3']);
    });

    test('session ended stops speech', () async {
      final engine = FakeTtsEngine();
      final announcer = VoiceAnnouncer(engine);

      await announcer.onIntervalStarted(_started());
      final stopsBefore = engine.stopCount;
      await announcer.onSessionEnded();
      expect(engine.stopCount, greaterThan(stopsBefore));
    });
  });

  group('VoiceAnnouncer overlap', () {
    test('new IntervalStarted interrupts (stop before speak)', () async {
      final engine = FakeTtsEngine();
      final announcer = VoiceAnnouncer(engine);

      await announcer.onIntervalStarted(_started(name: 'A'));
      await announcer.onIntervalStarted(_started(name: 'B', id: 'i2'));

      expect(engine.speaks, ['A', 'B']);
      // stop called at least once per speak interrupt
      expect(engine.stopCount, greaterThanOrEqualTo(2));
    });

    test('same S is not spoken twice', () async {
      final engine = FakeTtsEngine();
      final announcer = VoiceAnnouncer(
        engine,
        settings: const VoiceSettings(announceIntervalName: false),
      );

      await announcer.onIntervalStarted(_started());
      await announcer.onTimerState(_running(remainingMs: 3000));
      await announcer.onTimerState(_running(remainingMs: 2800));
      await announcer.onTimerState(_running(remainingMs: 2500));

      expect(engine.speaks.where((s) => s == '3').length, 1);
    });
  });
}

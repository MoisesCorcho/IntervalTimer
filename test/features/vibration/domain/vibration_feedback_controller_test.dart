import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/features/timer/application/timer_session_events.dart';
import 'package:interval_timer/features/timer/application/timer_state.dart';
import 'package:interval_timer/features/vibration/domain/vibration_driver.dart';
import 'package:interval_timer/features/vibration/domain/vibration_feedback_controller.dart';
import 'package:interval_timer/features/vibration/domain/vibration_pattern_resolver.dart';
import 'package:interval_timer/features/vibration/domain/vibration_settings.dart';

class FakeVibrationDriver implements VibrationDriver {
  final List<VibrationCall> calls = <VibrationCall>[];
  int cancelCount = 0;
  bool hasVibratorFlag = true;
  bool throwOnVibrate = false;

  @override
  Future<bool> hasVibrator() async => hasVibratorFlag;

  @override
  Future<void> vibrate({int? durationMs, List<int>? pattern}) async {
    if (throwOnVibrate) throw Exception('vibrate failed');
    if (!hasVibratorFlag) return;
    calls.add(VibrationCall(durationMs: durationMs, pattern: pattern));
  }

  @override
  Future<void> cancel() async {
    cancelCount++;
  }
}

class VibrationCall {
  VibrationCall({this.durationMs, this.pattern});

  final int? durationMs;
  final List<int>? pattern;

  bool get isPatternA => durationMs == 60 && (pattern == null);

  bool get isPatternB =>
      durationMs == 25 &&
      pattern != null &&
      pattern!.length == 4 &&
      pattern![0] == 0 &&
      pattern![1] == 20;
}

IntervalStartedEvent _started({
  String id = 'i1',
  String name = 'Work',
  int durationSeconds = 10,
  int index = 0,
}) {
  return IntervalStartedEvent(
    intervalId: id,
    name: name,
    announceText: null,
    durationSeconds: durationSeconds,
    index: index,
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
  const patterns = VibrationPatternResolver();

  group('VibrationFeedbackController happy path', () {
    test('pattern A on IntervalStarted when vibration on', () async {
      final driver = FakeVibrationDriver();
      final controller = VibrationFeedbackController(
        driver,
        settings: const VibrationSettings(vibrationEnabled: true),
      );

      await controller.onIntervalStarted(_started());

      expect(driver.calls.length, 1);
      expect(driver.calls.single.isPatternA, isTrue);
      expect(driver.calls.single.durationMs, patterns.intervalStart.durationMs);
    });

    test('pattern B ticks S=3,2,1 once each', () async {
      final driver = FakeVibrationDriver();
      final controller = VibrationFeedbackController(
        driver,
        settings: const VibrationSettings(
          vibrationEnabled: true,
          vibrationOnIntervalStart: false,
          vibrationCountdownSeconds: 3,
        ),
      );

      await controller.onIntervalStarted(_started(durationSeconds: 10));
      await controller.onTimerState(_running(remainingMs: 3000));
      await controller.onTimerState(_running(remainingMs: 2900));
      await controller.onTimerState(_running(remainingMs: 2000));
      await controller.onTimerState(_running(remainingMs: 1000));
      await controller.onTimerState(_running(remainingMs: 500));
      await controller.onTimerState(_running(remainingMs: 1000));

      expect(driver.calls.length, 3);
      expect(driver.calls.every((c) => c.isPatternB), isTrue);
    });
  });

  group('VibrationFeedbackController toggles', () {
    test('vibrationEnabled=false does not vibrate', () async {
      final driver = FakeVibrationDriver();
      final controller = VibrationFeedbackController(
        driver,
        settings: const VibrationSettings(vibrationEnabled: false),
      );

      await controller.onIntervalStarted(_started());
      await controller.onTimerState(_running(remainingMs: 2000));

      expect(driver.calls, isEmpty);
    });

    test('onIntervalStart=false omits A but allows B', () async {
      final driver = FakeVibrationDriver();
      final controller = VibrationFeedbackController(
        driver,
        settings: const VibrationSettings(
          vibrationOnIntervalStart: false,
          vibrationCountdownSeconds: 3,
        ),
      );

      await controller.onIntervalStarted(_started());
      await controller.onTimerState(_running(remainingMs: 3000));

      expect(driver.calls.length, 1);
      expect(driver.calls.single.isPatternB, isTrue);
    });

    test('onCountdown=false omits B but allows A', () async {
      final driver = FakeVibrationDriver();
      final controller = VibrationFeedbackController(
        driver,
        settings: const VibrationSettings(vibrationOnCountdown: false),
      );

      await controller.onIntervalStarted(_started());
      await controller.onTimerState(_running(remainingMs: 3000));

      expect(driver.calls.length, 1);
      expect(driver.calls.single.isPatternA, isTrue);
    });

    test('countdownSeconds=0 omits B', () async {
      final driver = FakeVibrationDriver();
      final controller = VibrationFeedbackController(
        driver,
        settings: const VibrationSettings(vibrationCountdownSeconds: 0),
      );

      await controller.onIntervalStarted(_started());
      await controller.onTimerState(_running(remainingMs: 3000));

      expect(driver.calls.length, 1);
      expect(driver.calls.single.isPatternA, isTrue);
    });

    test('master mute cancels in-progress vibration', () async {
      final driver = FakeVibrationDriver();
      final controller = VibrationFeedbackController(
        driver,
        settings: const VibrationSettings(vibrationEnabled: true),
      );

      await controller.onIntervalStarted(_started());
      final cancelsBefore = driver.cancelCount;

      controller.updateSettings(
        const VibrationSettings(vibrationEnabled: false),
      );

      expect(driver.cancelCount, greaterThan(cancelsBefore));
    });
  });

  group('VibrationFeedbackController independence from voice', () {
    test('vibrates regardless of voiceEnabled (R14 — no voice gate)', () async {
      // Voice mute is outside this controller; presence of vibration-only
      // settings proves R14: no voiceEnabled field is consulted.
      final driver = FakeVibrationDriver();
      final controller = VibrationFeedbackController(
        driver,
        settings: const VibrationSettings(
          vibrationEnabled: true,
          vibrationOnIntervalStart: true,
          vibrationOnCountdown: true,
          vibrationCountdownSeconds: 3,
        ),
      );

      await controller.onIntervalStarted(_started());
      await controller.onTimerState(_running(remainingMs: 2000));

      expect(driver.calls.length, 2);
      expect(driver.calls.first.isPatternA, isTrue);
      expect(driver.calls.last.isPatternB, isTrue);
    });
  });

  group('VibrationFeedbackController error and edge', () {
    test('hasVibrator=false produces no calls and does not throw', () async {
      final driver = FakeVibrationDriver()..hasVibratorFlag = false;
      final controller = VibrationFeedbackController(driver);

      await expectLater(
        controller.onIntervalStarted(_started()),
        completes,
      );
      expect(driver.calls, isEmpty);
    });

    test('vibrate throw is swallowed', () async {
      final driver = FakeVibrationDriver()..throwOnVibrate = true;
      final controller = VibrationFeedbackController(driver);

      await expectLater(
        controller.onIntervalStarted(_started()),
        completes,
      );
    });

    test('short interval only emits reachable S', () async {
      final driver = FakeVibrationDriver();
      final controller = VibrationFeedbackController(
        driver,
        settings: const VibrationSettings(
          vibrationOnIntervalStart: false,
          vibrationCountdownSeconds: 5,
        ),
      );

      await controller.onIntervalStarted(_started(durationSeconds: 2));
      await controller.onTimerState(_running(remainingMs: 2000));
      await controller.onTimerState(_running(remainingMs: 1000));

      expect(driver.calls.length, 2);
    });

    test('idle and completed do not vibrate countdown', () async {
      final driver = FakeVibrationDriver();
      final controller = VibrationFeedbackController(
        driver,
        settings: const VibrationSettings(vibrationOnIntervalStart: false),
      );

      await controller.onTimerState(
        const TimerState(status: TimerStatus.idle, remainingMs: 2000),
      );
      await controller.onTimerState(
        const TimerState(status: TimerStatus.completed, remainingMs: 0),
      );

      expect(driver.calls, isEmpty);
    });

    test('pause cancels and does not tick while paused', () async {
      final driver = FakeVibrationDriver();
      final controller = VibrationFeedbackController(
        driver,
        settings: const VibrationSettings(vibrationOnIntervalStart: false),
      );

      await controller.onTimerState(_running(remainingMs: 3000));
      expect(driver.calls.length, 1);

      final cancelsBefore = driver.cancelCount;
      await controller.onTimerState(
        _running(remainingMs: 2500, status: TimerStatus.paused),
      );
      expect(driver.cancelCount, greaterThan(cancelsBefore));

      await controller.onTimerState(
        _running(remainingMs: 2000, status: TimerStatus.paused),
      );
      expect(driver.calls.length, 1);
    });

    test('session ended cancels vibration', () async {
      final driver = FakeVibrationDriver();
      final controller = VibrationFeedbackController(driver);

      await controller.onIntervalStarted(_started());
      final cancelsBefore = driver.cancelCount;
      await controller.onSessionEnded();
      expect(driver.cancelCount, greaterThan(cancelsBefore));
    });

    test('resume after pause does not re-emit already vibrated S', () async {
      final driver = FakeVibrationDriver();
      final controller = VibrationFeedbackController(
        driver,
        settings: const VibrationSettings(vibrationOnIntervalStart: false),
      );

      await controller.onIntervalStarted(_started());
      await controller.onTimerState(_running(remainingMs: 3000));
      expect(driver.calls.length, 1);

      await controller.onTimerState(
        _running(remainingMs: 2500, status: TimerStatus.paused),
      );
      await controller.onTimerState(_running(remainingMs: 2500));
      // S=3 already done; S=2 not yet
      await controller.onTimerState(_running(remainingMs: 2000));

      expect(driver.calls.length, 2);
    });
  });

  group('VibrationFeedbackController idempotency', () {
    test('same S is not emitted twice', () async {
      final driver = FakeVibrationDriver();
      final controller = VibrationFeedbackController(
        driver,
        settings: const VibrationSettings(vibrationOnIntervalStart: false),
      );

      await controller.onIntervalStarted(_started());
      await controller.onTimerState(_running(remainingMs: 3000));
      await controller.onTimerState(_running(remainingMs: 2800));
      await controller.onTimerState(_running(remainingMs: 2500));

      expect(driver.calls.length, 1);
    });
  });
}

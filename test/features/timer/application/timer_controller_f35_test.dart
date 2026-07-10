import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/models/interval.dart';
import 'package:interval_timer/data/models/routine.dart';
import 'package:interval_timer/data/models/routine_item.dart';
import 'package:interval_timer/features/timer/application/timer_controller.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';
import 'package:interval_timer/features/timer/application/timer_state.dart';

Routine _routineWithDurations(List<int> seconds) {
  return Routine(
    id: 'routine-1',
    name: 'Test',
    createdAt: DateTime.utc(2026, 1, 1),
    items: [
      for (var i = 0; i < seconds.length; i++)
        RoutineItem.interval(
          Interval(
            id: 'interval-$i',
            name: 'Interval $i',
            durationSeconds: seconds[i],
            colorArgb: 0xFF4CAF50,
          ),
        ),
    ],
  );
}

void main() {
  group('TimerController F35', () {
    late DateTime fakeNow;
    late ProviderContainer container;
    late TimerController controller;

    setUp(() {
      fakeNow = DateTime.utc(2026, 1, 1, 12);
      final timerController = TimerController(now: () => fakeNow);
      container = ProviderContainer(
        overrides: [
          timerControllerProvider.overrideWith(() => timerController),
        ],
      );
      controller = container.read(timerControllerProvider.notifier);
    });

    tearDown(() => container.dispose());

    TimerState state() => container.read(timerControllerProvider);

    test('prep=10 starts preparing and does not run interval 0 yet', () {
      controller.bindRoutine(_routineWithDurations([5, 5]));
      expect(controller.start(prepSeconds: 10), isTrue);

      expect(state().status, TimerStatus.preparing);
      expect(state().segmentKind, SegmentKind.preparation);
      expect(state().sessionPrepSeconds, 10);
      expect(state().remainingMs, 10000);
      expect(state().currentInterval, isNull);
      expect(state().nextInterval?.name, 'Interval 0');
    });

    test('prep=0 starts interval 0 immediately', () {
      controller.bindRoutine(_routineWithDurations([5]));
      expect(controller.start(prepSeconds: 0), isTrue);

      expect(state().status, TimerStatus.running);
      expect(state().segmentKind, SegmentKind.interval);
      expect(state().sessionPrepSeconds, 0);
      expect(state().remainingMs, 5000);
      expect(state().currentInterval?.name, 'Interval 0');
    });

    test('prep reaches 0 advances to interval 0 full duration', () {
      fakeAsync((async) {
        controller.bindRoutine(_routineWithDurations([8]));
        controller.start(prepSeconds: 3);

        fakeNow = fakeNow.add(const Duration(seconds: 3));
        controller.processDomainTickForTest();

        expect(state().status, TimerStatus.running);
        expect(state().segmentKind, SegmentKind.interval);
        expect(state().currentIndex, 0);
        expect(state().remainingMs, 8000);
      });
    });

    test('skipForward during prep starts interval 0', () {
      controller.bindRoutine(_routineWithDurations([8, 4]));
      controller.start(prepSeconds: 10);
      controller.skipForward();

      expect(state().status, TimerStatus.running);
      expect(state().currentIndex, 0);
      expect(state().remainingMs, 8000);
    });

    test('skipBack during prep is no-op', () {
      controller.bindRoutine(_routineWithDurations([8]));
      controller.start(prepSeconds: 10);
      final before = state();
      controller.skipBack();

      expect(state().status, TimerStatus.preparing);
      expect(state().remainingMs, before.remainingMs);
      expect(state().sessionPrepSeconds, 10);
    });

    test('skipBack from index>0 goes to previous full in running', () {
      controller.bindRoutine(_routineWithDurations([10, 20, 30]));
      controller.start(prepSeconds: 0);
      controller.skipForward();
      expect(state().currentIndex, 1);

      controller.pause();
      controller.skipBack();

      expect(state().status, TimerStatus.running);
      expect(state().currentIndex, 0);
      expect(state().remainingMs, 10000);
    });

    test('skipBack from index 0 restarts current full', () {
      fakeAsync((async) {
        controller.bindRoutine(_routineWithDurations([10, 20]));
        controller.start(prepSeconds: 0);
        fakeNow = fakeNow.add(const Duration(seconds: 4));
        controller.processDomainTickForTest();
        expect(state().remainingMs, 6000);

        controller.skipBack();

        expect(state().status, TimerStatus.running);
        expect(state().currentIndex, 0);
        expect(state().remainingMs, 10000);
      });
    });

    test('skipForward on last interval completes session', () {
      controller.bindRoutine(_routineWithDurations([10]));
      controller.start(prepSeconds: 0);
      controller.skipForward();

      expect(state().status, TimerStatus.completed);
    });

    test('skipForward on intermediate advances to next full running', () {
      controller.bindRoutine(_routineWithDurations([10, 20]));
      controller.start(prepSeconds: 0);
      controller.skipForward();

      expect(state().status, TimerStatus.running);
      expect(state().currentIndex, 1);
      expect(state().remainingMs, 20000);
    });

    test('pause/resume freezes remaining in interval without reset', () {
      fakeAsync((async) {
        // 15s section, pause after 4s → resume must continue at 11s (not reset to 15).
        controller.bindRoutine(_routineWithDurations([15, 20]));
        controller.start(prepSeconds: 0);
        fakeNow = fakeNow.add(const Duration(seconds: 4));
        controller.processDomainTickForTest();
        expect(state().remainingMs, 11000);

        controller.pause();
        async.elapse(const Duration(seconds: 5));
        expect(state().remainingMs, 11000);
        expect(state().currentIndex, 0);

        controller.resume();
        expect(state().status, TimerStatus.running);
        expect(state().currentIndex, 0);
        expect(state().remainingMs, 11000);

        // Critical: first domain tick after resume must NOT reset to full duration.
        controller.processDomainTickForTest();
        expect(state().remainingMs, 11000);
        expect(state().currentIntervalDurationMs, 15000);

        fakeNow = fakeNow.add(const Duration(seconds: 2));
        controller.processDomainTickForTest();
        expect(state().remainingMs, 9000);
        expect(state().currentIndex, 0);
      });
    });

    test('pause/resume freezes remaining in prep without reset', () {
      fakeAsync((async) {
        controller.bindRoutine(_routineWithDurations([10]));
        controller.start(prepSeconds: 10);
        fakeNow = fakeNow.add(const Duration(seconds: 4));
        controller.processDomainTickForTest();
        expect(state().remainingMs, 6000);

        controller.pause();
        expect(state().status, TimerStatus.paused);
        expect(state().segmentKind, SegmentKind.preparation);
        async.elapse(const Duration(seconds: 5));
        expect(state().remainingMs, 6000);

        controller.resume();
        expect(state().status, TimerStatus.preparing);
        expect(state().remainingMs, 6000);
        expect(state().sessionPrepSeconds, 10);

        controller.processDomainTickForTest();
        expect(state().remainingMs, 6000);

        fakeNow = fakeNow.add(const Duration(seconds: 1));
        controller.processDomainTickForTest();
        expect(state().remainingMs, 5000);
        expect(state().status, TimerStatus.preparing);
      });
    });

    test('totalRemainingMs coherent in prep, mid interval, last, and pause', () {
      fakeAsync((async) {
        // intervals 10 + 20 = 30s total work
        controller.bindRoutine(_routineWithDurations([10, 20]));
        controller.start(prepSeconds: 5);

        // prep remaining 5s + 10 + 20 = 35s
        expect(state().totalRemainingMs, 35000);

        fakeNow = fakeNow.add(const Duration(seconds: 2));
        controller.processDomainTickForTest();
        expect(state().totalRemainingMs, 33000);

        controller.skipForward(); // interval 0 full 10s + 20 = 30s
        expect(state().totalRemainingMs, 30000);

        fakeNow = fakeNow.add(const Duration(seconds: 4));
        controller.processDomainTickForTest();
        expect(state().totalRemainingMs, 26000);

        controller.pause();
        async.elapse(const Duration(seconds: 10));
        expect(state().totalRemainingMs, 26000);

        controller.resume();
        controller.skipForward(); // interval 1 full 20s
        expect(state().totalRemainingMs, 20000);
      });
    });

    test('R20: changing prep prefs after start does not alter sessionPrepSeconds',
        () {
      controller.bindRoutine(_routineWithDurations([10]));
      controller.start(prepSeconds: 10);
      expect(state().sessionPrepSeconds, 10);
      expect(state().remainingMs, 10000);

      // Simulated external settings change — start already snapshotted.
      // Calling start again is blocked while active; session stays.
      expect(controller.start(prepSeconds: 30), isFalse);
      expect(state().sessionPrepSeconds, 10);
      expect(state().remainingMs, 10000);
    });

    test('pause wins race over prep end (R19)', () {
      fakeAsync((async) {
        controller.bindRoutine(_routineWithDurations([10]));
        controller.start(prepSeconds: 1);

        fakeNow = fakeNow.add(const Duration(seconds: 1));
        controller.pause();

        expect(state().status, TimerStatus.paused);
        expect(state().segmentKind, SegmentKind.preparation);
        expect(state().isPausePending, isTrue);

        controller.processDomainTickForTest();
        expect(state().status, TimerStatus.paused);
        expect(state().segmentKind, SegmentKind.preparation);
      });
    });

    test('cancel during prep emits SessionCancelled with 0 completed', () {
      final cancelled = <Object>[];
      controller.sessionCancelledStream.listen(cancelled.add);

      controller.bindRoutine(_routineWithDurations([10, 10]));
      controller.start(prepSeconds: 5);
      controller.cancel();

      expect(state().status, TimerStatus.idle);
      expect(cancelled, hasLength(1));
    });
  });
}

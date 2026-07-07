import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/models/interval.dart';
import 'package:interval_timer/data/models/routine.dart';
import 'package:interval_timer/data/models/routine_item.dart';
import 'package:interval_timer/features/timer/application/timer_controller.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';
import 'package:interval_timer/features/timer/application/timer_session_events.dart';
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
  group('TimerController', () {
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
      expect(
        identical(controller, container.read(timerControllerProvider.notifier)),
        isTrue,
      );
    });

    tearDown(() => container.dispose());

    List<SessionCompletedEvent> listenCompleted() {
      final events = <SessionCompletedEvent>[];
      controller.sessionCompletedStream.listen(events.add);
      return events;
    }

    List<SessionCancelledEvent> listenCancelled() {
      final events = <SessionCancelledEvent>[];
      controller.sessionCancelledStream.listen(events.add);
      return events;
    }

    test('happy path: idle→running→paused→running→completed with auto-advance',
        () {
      final completedEvents = listenCompleted();

      fakeAsync((async) {
        final routine = _routineWithDurations([2, 3]);
        controller.bindRoutine(routine);

        expect(controller.start(), isTrue);
        expect(container.read(timerControllerProvider).status,
            TimerStatus.running);
        expect(
          container.read(timerControllerProvider).remainingMs,
          2000,
        );

        controller.pause();
        expect(container.read(timerControllerProvider).status,
            TimerStatus.paused);
        expect(
          container.read(timerControllerProvider).remainingMs,
          2000,
        );

        async.elapse(const Duration(seconds: 5));
        expect(
          container.read(timerControllerProvider).remainingMs,
          2000,
        );

        controller.resume();
        fakeNow = fakeNow.add(const Duration(seconds: 2));
        controller.processDomainTickForTest();
        expect(container.read(timerControllerProvider).currentIndex, 1);
        expect(
          container.read(timerControllerProvider).remainingMs,
          3000,
        );

        fakeNow = fakeNow.add(const Duration(seconds: 3));
        controller.processDomainTickForTest();
        expect(container.read(timerControllerProvider).status,
            TimerStatus.completed);
        expect(completedEvents, hasLength(1));
        expect(completedEvents.first.intervalCount, 2);
        expect(completedEvents.first.routineId, 'routine-1');
      });
    });

    test('empty routine blocks start', () {
      controller.bindRoutine(
        Routine(
          id: 'empty',
          name: 'Empty',
          createdAt: DateTime.utc(2026),
          items: const [],
        ),
      );
      expect(controller.start(), isFalse);
      expect(
        container.read(timerControllerProvider).status,
        TimerStatus.idle,
      );
    });

    test('pause in idle is ignored', () {
      controller.pause();
      expect(
        container.read(timerControllerProvider).status,
        TimerStatus.idle,
      );
    });

    test('pause wins race over interval advance (R16)', () {
      fakeAsync((async) {
        final routine = _routineWithDurations([1]);
        controller.bindRoutine(routine);
        controller.start();

        fakeNow = fakeNow.add(const Duration(seconds: 1));
        controller.pause();

        final state = container.read(timerControllerProvider);
        expect(state.status, TimerStatus.paused);
        expect(state.currentIndex, 0);
        expect(state.isPausePending, isTrue);
        expect(state.remainingMs, lessThanOrEqualTo(0));

        controller.processDomainTickForTest();
        expect(container.read(timerControllerProvider).currentIndex, 0);
        expect(container.read(timerControllerProvider).status,
            TimerStatus.paused);
      });
    });

    test('skip on last interval completes session', () {
      final completedEvents = listenCompleted();

      fakeAsync((async) {
        final routine = _routineWithDurations([10]);
        controller.bindRoutine(routine);
        controller.start();
        controller.skip();

        expect(container.read(timerControllerProvider).status,
            TimerStatus.completed);
        expect(completedEvents, hasLength(1));
      });
    });

    test('skip on single-interval routine completes session', () {
      final completedEvents = listenCompleted();
      final routine = _routineWithDurations([30]);
      controller.bindRoutine(routine);
      controller.start();
      controller.skip();

      expect(
        container.read(timerControllerProvider).status,
        TimerStatus.completed,
      );
      expect(completedEvents, hasLength(1));
      expect(completedEvents.single.intervalCount, 1);
    });

    test('cancel emits SessionCancelled and returns to idle', () {
      final cancelledEvents = listenCancelled();
      final routine = _routineWithDurations([10, 10]);
      controller.bindRoutine(routine);
      controller.start();
      fakeNow = fakeNow.add(const Duration(seconds: 3));
      controller.cancel();

      expect(
        container.read(timerControllerProvider).status,
        TimerStatus.idle,
      );
      expect(cancelledEvents, hasLength(1));
      expect(cancelledEvents.first.routineId, 'routine-1');
      expect(cancelledEvents.first.elapsedSeconds, 3);
    });

    test('remainingMs within ±1s after 60 min background simulation', () {
      fakeAsync((async) {
        final routine = _routineWithDurations([3600]);
        controller.bindRoutine(routine);
        controller.start();

        fakeNow = fakeNow.add(const Duration(minutes: 60));
        controller.onAppLifecycleResumed();

        final remaining = container.read(timerControllerProvider).remainingMs;
        const expectedMs = 0;
        expect((remaining - expectedMs).abs(), lessThanOrEqualTo(1000));
      });
    });
  });
}
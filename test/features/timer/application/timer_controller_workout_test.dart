import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/models/interval.dart';
import 'package:interval_timer/data/models/interval_type.dart';
import 'package:interval_timer/data/models/routine_item.dart';
import 'package:interval_timer/features/timer/application/timer_controller.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';
import 'package:interval_timer/features/timer/application/timer_session_events.dart';
import 'package:interval_timer/features/timer/application/timer_state.dart';

void main() {
  group('TimerController loadFlattenedWorkout', () {
    late ProviderContainer container;
    late TimerController controller;

    setUp(() {
      final timerController = TimerController();
      container = ProviderContainer(
        overrides: [
          timerControllerProvider.overrideWith(() => timerController),
        ],
      );
      controller = container.read(timerControllerProvider.notifier);
    });

    tearDown(() => container.dispose());

    test('loads flattened workout in idle with N intervals', () {
      final intervals = [
        const Interval(
          id: 'i-1',
          name: 'Push-ups',
          durationSeconds: 40,
          colorArgb: 0xFF4CAF50,
          type: IntervalType.work,
        ),
        const Interval(
          id: 'i-2',
          name: 'Descanso',
          durationSeconds: 20,
          colorArgb: 0xFF2196F3,
          type: IntervalType.rest,
        ),
      ];

      controller.loadFlattenedWorkout(
        workoutId: 'workout-abc',
        workoutName: 'Morning',
        flattened: intervals,
      );

      final state = container.read(timerControllerProvider);
      expect(state.status, TimerStatus.idle);
      expect(state.routine?.id, 'workout-abc');
      expect(state.routine?.name, 'Morning');
      expect(state.routine?.items.length, 2);
      final firstItem = state.routine!.items.first;
      expect(
        firstItem,
        RoutineItem.interval(intervals[0]),
      );
    });

    test('SessionCompleted uses workoutId as routineId', () {
      final events = <SessionCompletedEvent>[];
      controller.sessionCompletedStream.listen(events.add);

      controller.loadFlattenedWorkout(
        workoutId: 'workout-xyz',
        workoutName: 'Legs',
        flattened: [
          const Interval(
            id: 'i-1',
            name: 'Squats',
            durationSeconds: 30,
            colorArgb: 0xFF4CAF50,
          ),
        ],
      );

      expect(controller.start(), isTrue);
      controller.processDomainTickForTest();
      controller.skip();

      expect(events, hasLength(1));
      expect(events.first.routineId, 'workout-xyz');
    });
  });
}
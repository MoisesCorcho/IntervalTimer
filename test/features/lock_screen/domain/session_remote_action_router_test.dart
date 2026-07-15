import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/models/interval.dart';
import 'package:interval_timer/data/models/routine.dart';
import 'package:interval_timer/data/models/routine_item.dart';
import 'package:interval_timer/features/lock_screen/domain/session_remote_action.dart';
import 'package:interval_timer/features/lock_screen/domain/session_remote_action_router.dart';
import 'package:interval_timer/features/timer/application/timer_controller.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';
import 'package:interval_timer/features/timer/application/timer_state.dart';

void main() {
  group('SessionRemoteActionRouter (R4, R5)', () {
    late DateTime fakeNow;
    late ProviderContainer container;
    late TimerController timer;

    setUp(() {
      fakeNow = DateTime.utc(2026, 1, 1, 12);
      final tc = TimerController(now: () => fakeNow);
      container = ProviderContainer(
        overrides: [
          timerControllerProvider.overrideWith(() => tc),
        ],
      );
      timer = container.read(timerControllerProvider.notifier);
      timer.bindRoutine(
        Routine(
          id: 'r1',
          name: 'Test',
          createdAt: DateTime.utc(2026, 1, 1),
          items: [
            for (var i = 0; i < 2; i++)
              RoutineItem.interval(
                Interval(
                  id: 'i$i',
                  name: 'Interval $i',
                  durationSeconds: 30,
                  colorArgb: 0xFF4CAF50,
                ),
              ),
          ],
        ),
      );
      expect(timer.start(), isTrue);
    });

    tearDown(() => container.dispose());

    test('pause then resume dispatch to F01', () {
      expect(container.read(timerControllerProvider).status, TimerStatus.running);

      SessionRemoteActionRouter.dispatch(SessionRemoteAction.pause, timer);
      expect(container.read(timerControllerProvider).status, TimerStatus.paused);

      SessionRemoteActionRouter.dispatch(SessionRemoteAction.resume, timer);
      expect(container.read(timerControllerProvider).status, TimerStatus.running);
    });

    test('skip advances interval via F01', () {
      SessionRemoteActionRouter.dispatch(SessionRemoteAction.skip, timer);
      expect(container.read(timerControllerProvider).currentIndex, 1);
      expect(container.read(timerControllerProvider).status, TimerStatus.running);
    });

    test('openApp is a no-op on timer state', () {
      final before = container.read(timerControllerProvider);
      SessionRemoteActionRouter.dispatch(SessionRemoteAction.openApp, timer);
      final after = container.read(timerControllerProvider);
      expect(after.status, before.status);
      expect(after.remainingMs, before.remainingMs);
    });
  });
}

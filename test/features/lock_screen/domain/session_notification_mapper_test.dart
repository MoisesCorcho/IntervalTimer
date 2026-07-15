import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/data/models/interval.dart';
import 'package:interval_timer/data/models/routine.dart';
import 'package:interval_timer/data/models/routine_item.dart';
import 'package:interval_timer/features/lock_screen/domain/session_notification_mapper.dart';
import 'package:interval_timer/features/timer/application/timer_state.dart';

void main() {
  group('SessionNotificationMapper (R1, R3)', () {
    final routine = Routine(
      id: 'r1',
      name: 'Test',
      createdAt: DateTime.utc(2026, 1, 1),
      items: [
        RoutineItem.interval(
          const Interval(
            id: 'i1',
            name: 'Trabajo',
            durationSeconds: 45,
            colorArgb: 0xFF4CAF50,
          ),
        ),
      ],
    );

    test('running → name, remaining, pause flag, no resume', () {
      final snap = SessionNotificationMapper.fromTimerState(
        TimerState(
          status: TimerStatus.running,
          routine: routine,
          remainingMs: 45200,
          currentIntervalDurationMs: 45000,
        ),
      );

      expect(snap.status, 'running');
      expect(snap.title, 'Trabajo');
      expect(snap.remainingMs, 45200);
      expect(snap.remainingFormatted, '00:46');
      expect(snap.showPause, isTrue);
      expect(snap.showResume, isFalse);
      expect(snap.showSkip, isTrue);
    });

    test('paused → resume flag, not pause', () {
      final snap = SessionNotificationMapper.fromTimerState(
        TimerState(
          status: TimerStatus.paused,
          routine: routine,
          remainingMs: 12000,
          currentIntervalDurationMs: 45000,
        ),
      );

      expect(snap.status, 'paused');
      expect(snap.title, 'Trabajo');
      expect(snap.showPause, isFalse);
      expect(snap.showResume, isTrue);
      expect(snap.showSkip, isTrue);
    });

    test('preparing → preparation title', () {
      final snap = SessionNotificationMapper.fromTimerState(
        const TimerState(
          status: TimerStatus.preparing,
          remainingMs: 5000,
          currentIntervalDurationMs: 10000,
          segmentKind: SegmentKind.preparation,
        ),
      );

      expect(snap.status, 'preparing');
      expect(snap.title, UiStrings.preparation);
      expect(snap.showPause, isTrue);
      expect(snap.showResume, isFalse);
    });
  });
}

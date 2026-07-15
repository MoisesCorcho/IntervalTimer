import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/features/always_on/domain/keep_screen_on_policy.dart';
import 'package:interval_timer/features/timer/application/timer_state.dart';

void main() {
  group('KeepScreenOnPolicy happy path (R1, R14)', () {
    test('running + pref true + host mounted → true', () {
      expect(
        KeepScreenOnPolicy.shouldKeepScreenOn(
          sessionStatus: TimerStatus.running,
          keepScreenOnEnabled: true,
          executionHostMounted: true,
        ),
        isTrue,
      );
    });

    test('preparing + pref true + host mounted → true', () {
      expect(
        KeepScreenOnPolicy.shouldKeepScreenOn(
          sessionStatus: TimerStatus.preparing,
          keepScreenOnEnabled: true,
          executionHostMounted: true,
        ),
        isTrue,
      );
    });
  });

  group('KeepScreenOnPolicy off paths (R2, R12, R13)', () {
    test('paused → false', () {
      expect(
        KeepScreenOnPolicy.shouldKeepScreenOn(
          sessionStatus: TimerStatus.paused,
          keepScreenOnEnabled: true,
          executionHostMounted: true,
        ),
        isFalse,
      );
    });

    test('idle → false', () {
      expect(
        KeepScreenOnPolicy.shouldKeepScreenOn(
          sessionStatus: TimerStatus.idle,
          keepScreenOnEnabled: true,
          executionHostMounted: true,
        ),
        isFalse,
      );
    });

    test('completed → false', () {
      expect(
        KeepScreenOnPolicy.shouldKeepScreenOn(
          sessionStatus: TimerStatus.completed,
          keepScreenOnEnabled: true,
          executionHostMounted: true,
        ),
        isFalse,
      );
    });

    test('pref false → false even when running and mounted', () {
      expect(
        KeepScreenOnPolicy.shouldKeepScreenOn(
          sessionStatus: TimerStatus.running,
          keepScreenOnEnabled: false,
          executionHostMounted: true,
        ),
        isFalse,
      );
    });

    test('host not mounted → false even when running', () {
      expect(
        KeepScreenOnPolicy.shouldKeepScreenOn(
          sessionStatus: TimerStatus.running,
          keepScreenOnEnabled: true,
          executionHostMounted: false,
        ),
        isFalse,
      );
    });
  });
}

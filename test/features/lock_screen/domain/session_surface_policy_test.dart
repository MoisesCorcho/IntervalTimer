import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/features/lock_screen/domain/session_surface_policy.dart';
import 'package:interval_timer/features/timer/application/timer_state.dart';

void main() {
  group('SessionSurfacePolicy show (R1)', () {
    test('running + pref on + permission + background → show', () {
      expect(
        SessionSurfacePolicy.shouldShowSessionSurface(
          sessionStatus: TimerStatus.running,
          sessionLockScreenEnabled: true,
          notificationPermissionGranted: true,
          isAppInBackground: true,
        ),
        isTrue,
      );
    });

    test('paused + pref on + permission + background → show', () {
      expect(
        SessionSurfacePolicy.shouldShowSessionSurface(
          sessionStatus: TimerStatus.paused,
          sessionLockScreenEnabled: true,
          notificationPermissionGranted: true,
          isAppInBackground: true,
        ),
        isTrue,
      );
    });

    test('preparing + pref on + permission + background → show', () {
      expect(
        SessionSurfacePolicy.shouldShowSessionSurface(
          sessionStatus: TimerStatus.preparing,
          sessionLockScreenEnabled: true,
          notificationPermissionGranted: true,
          isAppInBackground: true,
        ),
        isTrue,
      );
    });
  });

  group('SessionSurfacePolicy hide (R14, R17 + foreground)', () {
    test('foreground (not in background) → hide even when running', () {
      expect(
        SessionSurfacePolicy.shouldShowSessionSurface(
          sessionStatus: TimerStatus.running,
          sessionLockScreenEnabled: true,
          notificationPermissionGranted: true,
          isAppInBackground: false,
        ),
        isFalse,
      );
    });

    test('idle → hide', () {
      expect(
        SessionSurfacePolicy.shouldShowSessionSurface(
          sessionStatus: TimerStatus.idle,
          sessionLockScreenEnabled: true,
          notificationPermissionGranted: true,
          isAppInBackground: true,
        ),
        isFalse,
      );
    });

    test('completed → hide', () {
      expect(
        SessionSurfacePolicy.shouldShowSessionSurface(
          sessionStatus: TimerStatus.completed,
          sessionLockScreenEnabled: true,
          notificationPermissionGranted: true,
          isAppInBackground: true,
        ),
        isFalse,
      );
    });

    test('pref off → hide even when running', () {
      expect(
        SessionSurfacePolicy.shouldShowSessionSurface(
          sessionStatus: TimerStatus.running,
          sessionLockScreenEnabled: false,
          notificationPermissionGranted: true,
          isAppInBackground: true,
        ),
        isFalse,
      );
    });

    test('permission denied → hide even when running', () {
      expect(
        SessionSurfacePolicy.shouldShowSessionSurface(
          sessionStatus: TimerStatus.running,
          sessionLockScreenEnabled: true,
          notificationPermissionGranted: false,
          isAppInBackground: true,
        ),
        isFalse,
      );
    });
  });
}

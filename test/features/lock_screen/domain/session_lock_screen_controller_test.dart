import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/models/interval.dart';
import 'package:interval_timer/data/models/routine.dart';
import 'package:interval_timer/data/models/routine_item.dart';
import 'package:interval_timer/features/lock_screen/domain/no_op_session_surface_driver.dart';
import 'package:interval_timer/features/lock_screen/domain/session_lock_screen_controller.dart';
import 'package:interval_timer/features/timer/application/timer_state.dart';

TimerState _running({int remainingMs = 30000}) {
  final routine = Routine(
    id: 'r1',
    name: 'Test',
    createdAt: DateTime.utc(2026, 1, 1),
    items: [
      RoutineItem.interval(
        const Interval(
          id: 'i1',
          name: 'Trabajo',
          durationSeconds: 30,
          colorArgb: 0xFF4CAF50,
        ),
      ),
    ],
  );
  return TimerState(
    status: TimerStatus.running,
    routine: routine,
    remainingMs: remainingMs,
    currentIntervalDurationMs: 30000,
  );
}

void main() {
  group('SessionLockScreenController show/update (R1, R2)', () {
    test('running + pref on + permission + background → show once; tick updates', () async {
      final driver = NoOpSessionSurfaceDriver(permissionGranted: true);
      final controller = SessionLockScreenController(
        driver,
        sessionLockScreenEnabled: true,
        permissionGranted: true,
        isAppInBackground: true,
      );

      await controller.onTimerState(_running(remainingMs: 30500));
      expect(driver.showCount, 1);
      expect(controller.surfaceVisible, isTrue);
      expect(driver.lastSnapshot?.title, 'Trabajo');

      // Same second (30): no re-show
      await controller.onTimerState(_running(remainingMs: 30100));
      expect(driver.showCount, 1);

      // Next second (29): update
      await controller.onTimerState(_running(remainingMs: 29900));
      expect(driver.showCount, 2);

      driver.dispose();
    });
  });

  group('SessionLockScreenController lifecycle background/foreground', () {
    test('foreground by default does not show surface; switching to background shows; returning hides', () async {
      final driver = NoOpSessionSurfaceDriver(permissionGranted: true);
      final controller = SessionLockScreenController(
        driver,
        sessionLockScreenEnabled: true,
        permissionGranted: true,
        isAppInBackground: false,
      );

      await controller.onTimerState(_running());
      expect(driver.showCount, 0, reason: 'Must not show notification while in foreground');
      expect(controller.surfaceVisible, isFalse);

      // Transition to background
      await controller.setAppInBackground(true);
      expect(driver.showCount, 1, reason: 'Must show notification upon background transition');
      expect(controller.surfaceVisible, isTrue);

      // Transition back to foreground
      await controller.setAppInBackground(false);
      expect(driver.hideCount, 1, reason: 'Must hide notification upon foreground return');
      expect(controller.surfaceVisible, isFalse);

      driver.dispose();
    });
  });

  group('SessionLockScreenController cleanup (R7, R9)', () {
    test('completed/cancelled/pref false → hide', () async {
      final driver = NoOpSessionSurfaceDriver(permissionGranted: true);
      final controller = SessionLockScreenController(
        driver,
        sessionLockScreenEnabled: true,
        permissionGranted: true,
        isAppInBackground: true,
      );

      await controller.onTimerState(_running());
      expect(driver.showCount, 1);

      await controller.onTimerState(
        const TimerState(status: TimerStatus.completed),
      );
      expect(driver.hideCount, 1);
      expect(controller.surfaceVisible, isFalse);

      await controller.onTimerState(_running());
      expect(driver.showCount, 2);

      await controller.setSessionLockScreenEnabled(false);
      expect(driver.hideCount, 2);

      await controller.setSessionLockScreenEnabled(true);
      await controller.onTimerState(_running());
      expect(driver.showCount, 3);

      await controller.onSessionEnded();
      expect(driver.hideCount, 3);

      driver.dispose();
    });
  });

  group('SessionLockScreenController errors (R15)', () {
    test('driver show/hide throw does not propagate or affect flow', () async {
      final driver = NoOpSessionSurfaceDriver(permissionGranted: true)
        ..throwOnShow = true;
      final controller = SessionLockScreenController(
        driver,
        sessionLockScreenEnabled: true,
        permissionGranted: true,
        isAppInBackground: true,
      );

      await expectLater(
        controller.onTimerState(_running()),
        completes,
      );

      driver.throwOnShow = false;
      await controller.onTimerState(_running(remainingMs: 20000));
      expect(driver.showCount, greaterThanOrEqualTo(1));

      driver.throwOnHide = true;
      await expectLater(controller.onSessionEnded(), completes);

      driver.dispose();
    });
  });

  group('SessionLockScreenController permission (R14)', () {
    test('permission denied → no show', () async {
      final driver = NoOpSessionSurfaceDriver(permissionGranted: false);
      // Override request to keep denied
      final controller = SessionLockScreenController(
        driver,
        sessionLockScreenEnabled: true,
        permissionGranted: false,
        isAppInBackground: true,
      );

      // First sync will request; NoOp grants on requestPermission.
      // Use a driver that stays denied:
      final denied = _DeniedPermissionDriver();
      final c2 = SessionLockScreenController(
        denied,
        sessionLockScreenEnabled: true,
        permissionGranted: false,
        isAppInBackground: true,
      );
      await c2.onTimerState(_running());
      expect(denied.showCount, 0);
      expect(c2.surfaceVisible, isFalse);

      driver.dispose();
      denied.dispose();
    });
  });
}

class _DeniedPermissionDriver extends NoOpSessionSurfaceDriver {
  _DeniedPermissionDriver() : super(permissionGranted: false);

  @override
  Future<bool> requestPermission() async {
    permissionGranted = false;
    return false;
  }
}

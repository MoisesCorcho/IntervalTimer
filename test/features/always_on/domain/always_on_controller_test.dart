import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/features/always_on/domain/always_on_controller.dart';
import 'package:interval_timer/features/always_on/domain/wakelock_driver.dart';
import 'package:interval_timer/features/timer/application/timer_state.dart';

class FakeWakelockDriver implements WakelockDriver {
  int enableCount = 0;
  int disableCount = 0;
  bool _enabled = false;
  bool throwOnEnable = false;
  bool throwOnDisable = false;

  @override
  Future<void> enable() async {
    if (throwOnEnable) throw Exception('enable failed');
    enableCount++;
    _enabled = true;
  }

  @override
  Future<void> disable() async {
    if (throwOnDisable) throw Exception('disable failed');
    disableCount++;
    _enabled = false;
  }

  @override
  Future<bool> get isEnabled async => _enabled;
}

TimerState _state(TimerStatus status) => TimerState(status: status);

void main() {
  group('AlwaysOnController transitions (R1, R2, R3)', () {
    test('running enables once; paused disables; completed disables', () async {
      final driver = FakeWakelockDriver();
      final controller = AlwaysOnController(
        driver,
        keepScreenOnEnabled: true,
        executionHostMounted: true,
      );

      await controller.onTimerState(_state(TimerStatus.running));
      expect(driver.enableCount, 1);
      expect(driver.disableCount, 0);

      // Same status: idempotent, no second enable
      await controller.onTimerState(_state(TimerStatus.running));
      expect(driver.enableCount, 1);

      await controller.onTimerState(_state(TimerStatus.paused));
      expect(driver.disableCount, 1);

      await controller.onTimerState(_state(TimerStatus.running));
      expect(driver.enableCount, 2);

      await controller.onTimerState(_state(TimerStatus.completed));
      expect(driver.disableCount, 2);
    });

    test('session ended disables', () async {
      final driver = FakeWakelockDriver();
      final controller = AlwaysOnController(
        driver,
        keepScreenOnEnabled: true,
        executionHostMounted: true,
        status: TimerStatus.running,
      );
      await controller.apply();
      expect(driver.enableCount, 1);

      await controller.onSessionEnded();
      expect(driver.disableCount, 1);
    });
  });

  group('AlwaysOnController live toggle (R7)', () {
    test('pref false→true enables; true→false disables while running', () async {
      final driver = FakeWakelockDriver();
      final controller = AlwaysOnController(
        driver,
        keepScreenOnEnabled: false,
        executionHostMounted: true,
        status: TimerStatus.running,
      );
      await controller.apply();
      expect(driver.enableCount, 0);

      await controller.setKeepScreenOnEnabled(true);
      expect(driver.enableCount, 1);

      await controller.setKeepScreenOnEnabled(false);
      expect(driver.disableCount, 1);
    });
  });

  group('AlwaysOnController error/edge (R11)', () {
    test('driver enable/disable throw does not propagate', () async {
      final driver = FakeWakelockDriver()..throwOnEnable = true;
      final controller = AlwaysOnController(
        driver,
        keepScreenOnEnabled: true,
        executionHostMounted: true,
        status: TimerStatus.running,
      );

      await expectLater(controller.apply(), completes);
      expect(controller.lastApplied, isNull);

      driver.throwOnEnable = false;
      driver.throwOnDisable = true;
      // Force lastApplied true so disable path runs
      await controller.apply();
      expect(driver.enableCount, 1);
      await controller.setKeepScreenOnEnabled(false);
      await expectLater(controller.apply(), completes);
    });
  });

  group('AlwaysOnController lifecycle (R9)', () {
    test('resumed with policy true re-enables (reaffirm)', () async {
      final driver = FakeWakelockDriver();
      final controller = AlwaysOnController(
        driver,
        keepScreenOnEnabled: true,
        executionHostMounted: true,
        status: TimerStatus.running,
      );
      await controller.apply();
      expect(driver.enableCount, 1);

      // Simulate OS release — reaffirm even if lastApplied was true
      await controller.onAppLifecycleResumed();
      expect(driver.enableCount, 2);
    });
  });

  group('AlwaysOnController dispose host (R4)', () {
    test('executionHostMounted false → disable', () async {
      final driver = FakeWakelockDriver();
      final controller = AlwaysOnController(
        driver,
        keepScreenOnEnabled: true,
        executionHostMounted: true,
        status: TimerStatus.running,
      );
      await controller.apply();
      expect(driver.enableCount, 1);

      await controller.setExecutionHostMounted(false);
      expect(driver.disableCount, 1);
    });
  });
}

import 'package:interval_timer/features/always_on/domain/wakelock_driver.dart';

/// No-op driver for tests and platforms without screen wakelock effect.
class NoOpWakelockDriver implements WakelockDriver {
  bool _enabled = false;

  @override
  Future<void> enable() async {
    _enabled = true;
  }

  @override
  Future<void> disable() async {
    _enabled = false;
  }

  @override
  Future<bool> get isEnabled async => _enabled;
}

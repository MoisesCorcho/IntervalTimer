import 'package:interval_timer/features/vibration/domain/vibration_driver.dart';

/// No-op driver for tests and environments without hardware.
class NoOpVibrationDriver implements VibrationDriver {
  @override
  Future<bool> hasVibrator() async => false;

  @override
  Future<void> vibrate({int? durationMs, List<int>? pattern}) async {}

  @override
  Future<void> cancel() async {}
}

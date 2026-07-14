/// Abstraction over platform vibration APIs (F18). Testable; errors → no-op.
abstract class VibrationDriver {
  Future<bool> hasVibrator();

  /// Emit a vibration. Prefer [pattern] when non-null and custom support exists;
  /// otherwise [durationMs] (or platform default if both absent).
  Future<void> vibrate({int? durationMs, List<int>? pattern});

  Future<void> cancel();
}

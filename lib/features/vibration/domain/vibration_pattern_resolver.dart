/// Resolved vibration payload for the driver.
class VibrationPattern {
  const VibrationPattern({this.durationMs, this.pattern});

  final int? durationMs;
  final List<int>? pattern;
}

/// Single source of truth for pattern A (interval start) and B (countdown).
class VibrationPatternResolver {
  const VibrationPatternResolver();

  /// Pattern A — brief single pulse at interval start (~60 ms).
  VibrationPattern get intervalStart =>
      const VibrationPattern(durationMs: 60);

  /// Pattern B — short/double pulse distinct from A.
  VibrationPattern get countdownTick => const VibrationPattern(
        durationMs: 25,
        pattern: [0, 20, 40, 20],
      );
}

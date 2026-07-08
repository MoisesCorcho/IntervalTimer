/// Pure step/clamp helpers for premium numeric steppers (F33).
/// No Flutter dependency — unit-testable without UI binding.

/// Returns [value] + [delta] clamped to [[min], [max]].
int clampStep({
  required int value,
  required int delta,
  required int min,
  required int max,
}) {
  final next = value + delta;
  if (next < min) return min;
  if (next > max) return max;
  return next;
}

/// Whether applying [delta] to [value] stays within [[min], [max]].
///
/// Strict: a full step must land inside range (no partial step).
bool canApplyStep({
  required int value,
  required int delta,
  required int min,
  required int max,
}) {
  final next = value + delta;
  return next >= min && next <= max;
}

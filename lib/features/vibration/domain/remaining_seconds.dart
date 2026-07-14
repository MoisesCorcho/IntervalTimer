/// Ceiling of remaining milliseconds to whole seconds (countdown digit S).
///
/// Kept local to vibration to avoid coupling the feature to voice domain.
int remainingSecondsCeil(int remainingMs) {
  if (remainingMs <= 0) return 0;
  return (remainingMs + 999) ~/ 1000;
}

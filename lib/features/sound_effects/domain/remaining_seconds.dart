/// Ceiling of remaining milliseconds to whole seconds (countdown digit S).
///
/// Local to sound_effects to avoid coupling to voice/vibration domains.
int remainingSecondsCeil(int remainingMs) {
  if (remainingMs <= 0) return 0;
  return (remainingMs + 999) ~/ 1000;
}

/// Resolves the utterance for interval-start announcements (R5).
String resolveAnnounceText({
  required String name,
  String? announceText,
}) {
  final custom = announceText?.trim();
  if (custom != null && custom.isNotEmpty) return custom;
  return name;
}

/// Ceiling of remaining milliseconds to whole seconds (countdown digit S).
int remainingSecondsCeil(int remainingMs) {
  if (remainingMs <= 0) return 0;
  return (remainingMs + 999) ~/ 1000;
}

/// Parses mm:ss duration strings. Returns seconds or null if invalid.
int? parseDurationMmSs(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return null;

  final parts = trimmed.split(':');
  if (parts.length != 2) return null;

  final minutes = int.tryParse(parts[0]);
  final seconds = int.tryParse(parts[1]);
  if (minutes == null || seconds == null) return null;
  if (seconds < 0 || seconds > 59) return null;
  if (minutes < 0 || minutes > 99) return null;

  final total = minutes * 60 + seconds;
  if (total < 1 || total > 5999) return null;
  return total;
}

/// Formats seconds as mm:ss.
String formatDurationMmSs(int totalSeconds) {
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

/// Formats milliseconds as mm:ss (ceil to nearest second for display).
String formatRemainingMs(int remainingMs) {
  final totalSeconds = (remainingMs / 1000).ceil();
  return formatDurationMmSs(totalSeconds.clamp(0, 5999));
}
import 'package:interval_timer/data/models/interval_type.dart';

class SessionCompletedEvent {
  const SessionCompletedEvent({
    required this.routineId,
    required this.completedAt,
    required this.totalElapsedSeconds,
    required this.intervalCount,
  });

  final String routineId;
  final DateTime completedAt;
  final int totalElapsedSeconds;
  final int intervalCount;
}

class SessionCancelledEvent {
  const SessionCancelledEvent({
    required this.routineId,
    required this.cancelledAt,
    required this.elapsedSeconds,
    required this.completedIntervalCount,
  });

  final String routineId;
  final DateTime cancelledAt;
  final int elapsedSeconds;
  final int completedIntervalCount;
}

/// Emitted when an interval segment begins (session start without prep, after
/// prep, advance, skip). F02 [VoiceAnnouncer] listens without coupling TTS to F01.
class IntervalStartedEvent {
  const IntervalStartedEvent({
    required this.intervalId,
    required this.name,
    required this.announceText,
    required this.durationSeconds,
    required this.index,
    required this.type,
  });

  final String intervalId;
  final String name;
  final String? announceText;
  final int durationSeconds;
  final int index;

  /// Interval type for channel-specific feedback (e.g. F36 work vs rest SFX).
  final IntervalType type;
}
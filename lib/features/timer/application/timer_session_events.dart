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
import 'package:interval_timer/data/models/interval.dart';
import 'package:interval_timer/data/models/interval_type.dart';

/// Work/rest split for a completed session plan (F16 R3).
class SessionPhaseBreakdown {
  const SessionPhaseBreakdown({
    required this.trainingSeconds,
    required this.restSeconds,
    this.setsCount = 0,
  });

  final int trainingSeconds;
  final int restSeconds;

  /// Count of [IntervalType.work] intervals (share template "Sets").
  final int setsCount;

  static const zero = SessionPhaseBreakdown(
    trainingSeconds: 0,
    restSeconds: 0,
  );

  /// Training = work + warmup + stretch + custom; rest = rest only.
  static SessionPhaseBreakdown fromIntervals(Iterable<Interval> intervals) {
    var training = 0;
    var rest = 0;
    var sets = 0;
    for (final interval in intervals) {
      if (interval.type == IntervalType.rest) {
        rest += interval.durationSeconds;
      } else {
        training += interval.durationSeconds;
        if (interval.type == IntervalType.work) {
          sets++;
        }
      }
    }
    return SessionPhaseBreakdown(
      trainingSeconds: training,
      restSeconds: rest,
      setsCount: sets,
    );
  }
}

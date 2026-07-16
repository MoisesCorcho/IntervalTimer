import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/models/interval.dart';
import 'package:interval_timer/data/models/interval_type.dart';
import 'package:interval_timer/features/session_summary/domain/session_phase_breakdown.dart';

Interval _i(int seconds, IntervalType type) => Interval(
      id: 'id-$seconds-${type.name}',
      name: type.name,
      durationSeconds: seconds,
      colorArgb: 0xFF000000,
      type: type,
    );

void main() {
  group('SessionPhaseBreakdown', () {
    test('only work → rest 0', () {
      final b = SessionPhaseBreakdown.fromIntervals([
        _i(30, IntervalType.work),
        _i(20, IntervalType.warmup),
      ]);
      expect(b.trainingSeconds, 50);
      expect(b.restSeconds, 0);
    });

    test('only rest → training 0', () {
      final b = SessionPhaseBreakdown.fromIntervals([
        _i(15, IntervalType.rest),
        _i(10, IntervalType.rest),
      ]);
      expect(b.trainingSeconds, 0);
      expect(b.restSeconds, 25);
    });

    test('mixed sums training and rest', () {
      final b = SessionPhaseBreakdown.fromIntervals([
        _i(40, IntervalType.work),
        _i(20, IntervalType.rest),
        _i(10, IntervalType.stretch),
        _i(5, IntervalType.custom),
        _i(30, IntervalType.rest),
      ]);
      expect(b.trainingSeconds, 55);
      expect(b.restSeconds, 50);
    });

    test('empty list is zero', () {
      final b = SessionPhaseBreakdown.fromIntervals([]);
      expect(b.trainingSeconds, 0);
      expect(b.restSeconds, 0);
    });
  });
}

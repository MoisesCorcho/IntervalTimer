import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:interval_timer/data/models/interval_type.dart';

part 'interval.freezed.dart';

@freezed
abstract class Interval with _$Interval {
  const factory Interval({
    required String id,
    required String name,
    required int durationSeconds,
    required int colorArgb,
    @Default(IntervalType.work) IntervalType type,
  }) = _Interval;
}
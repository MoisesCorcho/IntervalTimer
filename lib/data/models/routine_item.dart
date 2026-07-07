import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:interval_timer/data/models/interval.dart';

part 'routine_item.freezed.dart';

@freezed
sealed class RoutineItem with _$RoutineItem {
  const factory RoutineItem.interval(Interval interval) = IntervalRoutineItem;
}
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:interval_timer/data/models/routine_item.dart';

part 'routine.freezed.dart';

@freezed
abstract class Routine with _$Routine {
  const factory Routine({
    required String id,
    required String name,
    required DateTime createdAt,
    @Default([]) List<RoutineItem> items,
  }) = _Routine;
}
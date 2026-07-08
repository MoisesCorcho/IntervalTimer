import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout_exercise.freezed.dart';

@freezed
abstract class WorkoutExercise with _$WorkoutExercise {
  const factory WorkoutExercise({
    required String id,
    required String workoutId,
    required int position,
    required String name,
    required int sets,
    required int workSeconds,
    required int restSeconds,
  }) = _WorkoutExercise;
}
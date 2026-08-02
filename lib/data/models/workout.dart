import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:interval_timer/data/models/workout_exercise.dart';

part 'workout.freezed.dart';

@freezed
abstract class Workout with _$Workout {
  const factory Workout({
    required String id,
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
    /// Global workout rounds (1–99). Default 1 = single pass (legacy F32).
    @Default(1) int rounds,
    @Default([]) List<WorkoutExercise> exercises,
  }) = _Workout;
}
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:interval_timer/features/preset_routines/domain/models/enums.dart';
import 'package:interval_timer/features/preset_routines/domain/models/preset_exercise_ref.dart';

part 'preset_routine.freezed.dart';

@freezed
abstract class PresetRoutine with _$PresetRoutine {
  const PresetRoutine._();

  const factory PresetRoutine({
    required String id,
    required String title,
    required String description,
    required PresetCategory category,
    required DifficultyLevel difficulty,
    @Default(false) bool isFeatured,
    required int restBetweenExercisesSeconds,
    required List<PresetExerciseRef> exercises,
  }) = _PresetRoutine;

  factory PresetRoutine.fromJson(Map<String, dynamic> json) {
    return PresetRoutine(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: PresetCategory.fromId(json['category'] as String? ?? ''),
      difficulty: DifficultyLevel.fromId(json['difficulty'] as String? ?? ''),
      isFeatured: json['isFeatured'] as bool? ?? false,
      restBetweenExercisesSeconds:
          (json['restBetweenExercisesSeconds'] as num?)?.toInt() ?? 0,
      exercises: (json['exercises'] as List<dynamic>?)
              ?.map((e) =>
                  PresetExerciseRef.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category.id,
        'difficulty': difficulty.id,
        'isFeatured': isFeatured,
        'restBetweenExercisesSeconds': restBetweenExercisesSeconds,
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };

  /// Calcula la duración total en segundos de la rutina considerando todas las series,
  /// los descansos intra-set y los descansos de transición entre ejercicios.
  int calculateTotalDurationSeconds() {
    int total = 0;
    for (int i = 0; i < exercises.length; i++) {
      final ref = exercises[i];
      total += (ref.sets * ref.workSeconds);
      if (ref.sets > 1 && ref.restSeconds > 0) {
        total += ((ref.sets - 1) * ref.restSeconds);
      }
      if (i < exercises.length - 1) {
        total += restBetweenExercisesSeconds;
      }
    }
    return total;
  }
}

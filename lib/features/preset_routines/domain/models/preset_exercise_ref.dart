import 'package:freezed_annotation/freezed_annotation.dart';

part 'preset_exercise_ref.freezed.dart';

@freezed
abstract class PresetExerciseRef with _$PresetExerciseRef {
  const PresetExerciseRef._();

  const factory PresetExerciseRef({
    required String exerciseId,
    required int sets,
    required int workSeconds,
    required int restSeconds,
  }) = _PresetExerciseRef;

  factory PresetExerciseRef.fromJson(Map<String, dynamic> json) {
    return PresetExerciseRef(
      exerciseId: json['exerciseId'] as String? ?? '',
      sets: (json['sets'] as num?)?.toInt() ?? 1,
      workSeconds: (json['workSeconds'] as num?)?.toInt() ?? 0,
      restSeconds: (json['restSeconds'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'sets': sets,
        'workSeconds': workSeconds,
        'restSeconds': restSeconds,
      };
}

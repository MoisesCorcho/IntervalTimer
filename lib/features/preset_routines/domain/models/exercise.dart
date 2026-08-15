import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:interval_timer/features/preset_routines/domain/models/enums.dart';

part 'exercise.freezed.dart';

@freezed
abstract class Exercise with _$Exercise {
  const Exercise._();

  const factory Exercise({
    required String id,
    required String name,
    required PresetCategory category,
    required MediaType mediaType,
    required String mediaPath,
    @Default([]) List<String> steps,
    @Default([]) List<String> tips,
  }) = _Exercise;

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: PresetCategory.fromId(json['category'] as String? ?? ''),
      mediaType: MediaType.fromString(json['mediaType'] as String? ?? ''),
      mediaPath: json['mediaPath'] as String? ?? '',
      steps: (json['steps'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      tips: (json['tips'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category.id,
        'mediaType': mediaType.name,
        'mediaPath': mediaPath,
        'steps': steps,
        'tips': tips,
      };
}

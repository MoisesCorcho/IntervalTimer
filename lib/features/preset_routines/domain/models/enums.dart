enum PresetCategory {
  hiit('hiit', 'HIIT'),
  core('core', 'Abdomen & Core'),
  lowerBody('lowerBody', 'Piernas & Glúteos'),
  upperBody('upperBody', 'Tren Superior'),
  fullBody('fullBody', 'Cuerpo Completo'),
  cardio('cardio', 'Cardio');

  final String id;
  final String label;
  const PresetCategory(this.id, this.label);

  static PresetCategory fromId(String id) {
    return PresetCategory.values.firstWhere(
      (e) => e.id.toLowerCase() == id.toLowerCase(),
      orElse: () => PresetCategory.fullBody,
    );
  }
}

enum DifficultyLevel {
  beginner('beginner', 'Principiante'),
  intermediate('intermediate', 'Intermedio'),
  advanced('advanced', 'Avanzado');

  final String id;
  final String label;
  const DifficultyLevel(this.id, this.label);

  static DifficultyLevel fromId(String id) {
    return DifficultyLevel.values.firstWhere(
      (e) => e.id.toLowerCase() == id.toLowerCase(),
      orElse: () => DifficultyLevel.intermediate,
    );
  }
}

enum MediaType {
  lottie,
  gif,
  video,
  image;

  static MediaType fromString(String type) {
    return MediaType.values.firstWhere(
      (e) => e.name == type.toLowerCase(),
      orElse: () => MediaType.image,
    );
  }
}

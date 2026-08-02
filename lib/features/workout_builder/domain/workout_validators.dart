abstract final class WorkoutValidators {
  static const maxWorkoutNameLength = 80;
  static const maxExerciseNameLength = 50;
  static const minSets = 1;
  static const maxSets = 99;
  static const minRounds = 1;
  static const maxRounds = 99;
  static const minWorkSeconds = 1;
  static const maxWorkSeconds = 5999;
  static const maxRestSeconds = 5999;

  static String? validateWorkoutName(String? raw) {
    final name = raw?.trim() ?? '';
    if (name.isEmpty) return 'El nombre es obligatorio';
    if (name.length > maxWorkoutNameLength) {
      return 'El nombre no puede superar $maxWorkoutNameLength caracteres';
    }
    return null;
  }

  static String? validateExerciseName(String? raw) {
    final name = raw?.trim() ?? '';
    if (name.isEmpty) return 'El nombre es obligatorio';
    if (name.length > maxExerciseNameLength) {
      return 'El nombre no puede superar $maxExerciseNameLength caracteres';
    }
    return null;
  }

  static String? validateSets(int? sets) {
    if (sets == null || sets < minSets || sets > maxSets) {
      return 'Los sets deben estar entre $minSets y $maxSets';
    }
    return null;
  }

  static String? validateRounds(int? rounds) {
    if (rounds == null || rounds < minRounds || rounds > maxRounds) {
      return 'Las rondas deben estar entre $minRounds y $maxRounds';
    }
    return null;
  }

  /// Clamps [rounds] into the legal 1–99 range (persistence defense).
  static int clampRounds(int rounds) {
    if (rounds < minRounds) return minRounds;
    if (rounds > maxRounds) return maxRounds;
    return rounds;
  }

  static String? validateWorkSeconds(int? seconds) {
    if (seconds == null ||
        seconds < minWorkSeconds ||
        seconds > maxWorkSeconds) {
      return 'Duración inválida. Debe estar entre 00:01 y 99:59';
    }
    return null;
  }

  static String? validateRestSeconds(int? seconds) {
    if (seconds == null || seconds < 0 || seconds > maxRestSeconds) {
      return 'Duración inválida. Debe estar entre 00:00 y 99:59';
    }
    return null;
  }

  static String? validateRestAfterExerciseSeconds(int? seconds) {
    if (seconds == null || seconds < 0 || seconds > maxRestSeconds) {
      return 'Duración inválida. Debe estar entre 00:00 y 99:59';
    }
    return null;
  }
}
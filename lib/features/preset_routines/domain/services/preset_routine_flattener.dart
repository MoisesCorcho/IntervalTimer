import 'package:uuid/uuid.dart';
import 'package:interval_timer/data/models/interval.dart';
import 'package:interval_timer/data/models/interval_type.dart';
import 'package:interval_timer/features/preset_routines/domain/models/exercise.dart';
import 'package:interval_timer/features/preset_routines/domain/models/preset_routine.dart';

/// Servicio de dominio encargado de aplanar una [PresetRoutine] en una lista de [Interval]s efímeros para el [TimerController].
class PresetRoutineFlattener {
  const PresetRoutineFlattener._();

  static List<Interval> flatten({
    required PresetRoutine preset,
    required Map<String, Exercise> exerciseMap,
    Uuid? uuid,
  }) {
    final Uuid generator = uuid ?? const Uuid();
    final List<Interval> intervals = [];

    for (int i = 0; i < preset.exercises.length; i++) {
      final ref = preset.exercises[i];
      final exercise = exerciseMap[ref.exerciseId];
      final name = exercise?.name.toUpperCase() ?? 'EJERCICIO';

      for (int set = 1; set <= ref.sets; set++) {
        // Intervalo de trabajo
        intervals.add(
          Interval(
            id: generator.v4(),
            name: ref.sets > 1 ? '$name (SET $set/${ref.sets})' : name,
            durationSeconds: ref.workSeconds,
            colorArgb: 0xFF4CAF50, // Verde Trabajo
            type: IntervalType.work,
          ),
        );

        // Descanso intra-set (si no es el último set)
        if (set < ref.sets && ref.restSeconds > 0) {
          intervals.add(
            Interval(
              id: generator.v4(),
              name: 'DESCANSO SET',
              durationSeconds: ref.restSeconds,
              colorArgb: 0xFF2196F3, // Azul Descanso
              type: IntervalType.rest,
            ),
          );
        }
      }

      // Descanso entre ejercicios (si no es el último ejercicio)
      if (i < preset.exercises.length - 1 && preset.restBetweenExercisesSeconds > 0) {
        intervals.add(
          Interval(
            id: generator.v4(),
            name: 'DESCANSO SIGUIENTE EJERCICIO',
            durationSeconds: preset.restBetweenExercisesSeconds,
            colorArgb: 0xFF9C27B0, // Púrpura Transición
            type: IntervalType.rest,
          ),
        );
      }
    }

    return intervals;
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/models/interval_type.dart';
import 'package:interval_timer/features/preset_routines/domain/models/enums.dart';
import 'package:interval_timer/features/preset_routines/domain/models/exercise.dart';
import 'package:interval_timer/features/preset_routines/domain/models/preset_exercise_ref.dart';
import 'package:interval_timer/features/preset_routines/domain/models/preset_routine.dart';
import 'package:interval_timer/features/preset_routines/domain/services/preset_routine_flattener.dart';

void main() {
  group('PresetRoutineFlattener & Domain Models', () {
    late Exercise exPushups;
    late Exercise exSquats;
    late Map<String, Exercise> exerciseMap;

    setUp(() {
      exPushups = const Exercise(
        id: 'ex_pushups',
        name: 'Pushups',
        category: PresetCategory.upperBody,
        mediaType: MediaType.image,
        mediaPath: 'assets/media/exercises/ex_pushups.png',
        steps: ['Paso 1'],
        tips: ['Tip 1'],
      );
      exSquats = const Exercise(
        id: 'ex_squats',
        name: 'Sentadillas',
        category: PresetCategory.lowerBody,
        mediaType: MediaType.image,
        mediaPath: 'assets/media/exercises/ex_squats.png',
        steps: ['Paso 1'],
        tips: ['Tip 1'],
      );
      exerciseMap = {
        exPushups.id: exPushups,
        exSquats.id: exSquats,
      };
    });

    test('flatten single exercise with 1 set produces 1 work interval', () {
      const routine = PresetRoutine(
        id: 'p1',
        title: 'Single Set',
        description: 'Desc',
        category: PresetCategory.upperBody,
        difficulty: DifficultyLevel.beginner,
        restBetweenExercisesSeconds: 15,
        exercises: [
          PresetExerciseRef(
            exerciseId: 'ex_pushups',
            sets: 1,
            workSeconds: 30,
            restSeconds: 10,
          ),
        ],
      );

      final intervals = PresetRoutineFlattener.flatten(
        preset: routine,
        exerciseMap: exerciseMap,
      );

      expect(intervals.length, equals(1));
      expect(intervals[0].name, equals('PUSHUPS'));
      expect(intervals[0].type, equals(IntervalType.work));
      expect(intervals[0].durationSeconds, equals(30));
    });

    test('flatten single exercise with 3 sets includes intra-set rests', () {
      const routine = PresetRoutine(
        id: 'p1',
        title: 'Multi Set',
        description: 'Desc',
        category: PresetCategory.upperBody,
        difficulty: DifficultyLevel.beginner,
        restBetweenExercisesSeconds: 15,
        exercises: [
          PresetExerciseRef(
            exerciseId: 'ex_pushups',
            sets: 3,
            workSeconds: 30,
            restSeconds: 10,
          ),
        ],
      );

      final intervals = PresetRoutineFlattener.flatten(
        preset: routine,
        exerciseMap: exerciseMap,
      );

      // Sequence: W (SET 1/3), Rest Set, W (SET 2/3), Rest Set, W (SET 3/3)
      expect(intervals.length, equals(5));
      expect(intervals[0].name, equals('PUSHUPS (SET 1/3)'));
      expect(intervals[0].type, equals(IntervalType.work));
      expect(intervals[0].durationSeconds, equals(30));

      expect(intervals[1].name, equals('DESCANSO SET'));
      expect(intervals[1].type, equals(IntervalType.rest));
      expect(intervals[1].durationSeconds, equals(10));

      expect(intervals[2].name, equals('PUSHUPS (SET 2/3)'));
      expect(intervals[3].name, equals('DESCANSO SET'));
      expect(intervals[4].name, equals('PUSHUPS (SET 3/3)'));
    });

    test('flatten multiple exercises includes inter-exercise rest', () {
      const routine = PresetRoutine(
        id: 'p2',
        title: 'Two Exercises',
        description: 'Desc',
        category: PresetCategory.fullBody,
        difficulty: DifficultyLevel.intermediate,
        restBetweenExercisesSeconds: 20,
        exercises: [
          PresetExerciseRef(
            exerciseId: 'ex_pushups',
            sets: 1,
            workSeconds: 30,
            restSeconds: 10,
          ),
          PresetExerciseRef(
            exerciseId: 'ex_squats',
            sets: 1,
            workSeconds: 40,
            restSeconds: 10,
          ),
        ],
      );

      final intervals = PresetRoutineFlattener.flatten(
        preset: routine,
        exerciseMap: exerciseMap,
      );

      // Sequence: PUSHUPS (30s) -> DESCANSO SIGUIENTE EJERCICIO (20s) -> SENTADILLAS (40s)
      expect(intervals.length, equals(3));
      expect(intervals[0].name, equals('PUSHUPS'));
      expect(intervals[0].durationSeconds, equals(30));

      expect(intervals[1].name, equals('DESCANSO SIGUIENTE EJERCICIO'));
      expect(intervals[1].type, equals(IntervalType.rest));
      expect(intervals[1].durationSeconds, equals(20));

      expect(intervals[2].name, equals('SENTADILLAS'));
      expect(intervals[2].durationSeconds, equals(40));
    });

    test('fallback exercise name when exercise is missing from map', () {
      const routine = PresetRoutine(
        id: 'p3',
        title: 'Unknown Ex',
        description: 'Desc',
        category: PresetCategory.fullBody,
        difficulty: DifficultyLevel.beginner,
        restBetweenExercisesSeconds: 10,
        exercises: [
          PresetExerciseRef(
            exerciseId: 'non_existent_id',
            sets: 1,
            workSeconds: 20,
            restSeconds: 5,
          ),
        ],
      );

      final intervals = PresetRoutineFlattener.flatten(
        preset: routine,
        exerciseMap: exerciseMap,
      );

      expect(intervals.length, equals(1));
      expect(intervals[0].name, equals('EJERCICIO'));
    });

    test('calculateTotalDurationSeconds calculates correct total duration', () {
      const routine = PresetRoutine(
        id: 'p_test',
        title: 'Test Duration',
        description: 'Desc',
        category: PresetCategory.hiit,
        difficulty: DifficultyLevel.intermediate,
        restBetweenExercisesSeconds: 15,
        exercises: [
          PresetExerciseRef(
            exerciseId: 'ex_pushups',
            sets: 3,
            workSeconds: 30,
            restSeconds: 10,
          ),
          PresetExerciseRef(
            exerciseId: 'ex_squats',
            sets: 2,
            workSeconds: 40,
            restSeconds: 15,
          ),
        ],
      );

      // Ex 1: (3 * 30) + (2 * 10) = 90 + 20 = 110s
      // Inter-exercise rest: 15s
      // Ex 2: (2 * 40) + (1 * 15) = 80 + 15 = 95s
      // Total = 110 + 15 + 95 = 220s
      expect(routine.calculateTotalDurationSeconds(), equals(220));
    });

    group('Enums fromId / fromString Fallbacks', () {
      test('PresetCategory.fromId handles valid and invalid strings', () {
        expect(PresetCategory.fromId('hiit'), equals(PresetCategory.hiit));
        expect(PresetCategory.fromId('CORE'), equals(PresetCategory.core));
        expect(PresetCategory.fromId('lowerBody'), equals(PresetCategory.lowerBody));
        expect(PresetCategory.fromId('invalid_cat'), equals(PresetCategory.fullBody));
      });

      test('DifficultyLevel.fromId handles valid and invalid strings', () {
        expect(DifficultyLevel.fromId('beginner'), equals(DifficultyLevel.beginner));
        expect(DifficultyLevel.fromId('ADVANCED'), equals(DifficultyLevel.advanced));
        expect(DifficultyLevel.fromId('unknown'), equals(DifficultyLevel.intermediate));
      });

      test('MediaType.fromString handles valid and invalid strings', () {
        expect(MediaType.fromString('gif'), equals(MediaType.gif));
        expect(MediaType.fromString('LOTTIE'), equals(MediaType.lottie));
        expect(MediaType.fromString('unknown'), equals(MediaType.image));
      });
    });
  });
}

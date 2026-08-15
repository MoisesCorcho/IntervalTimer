import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/repositories/workout_repository.dart';
import 'package:interval_timer/features/preset_routines/application/preset_cloner_service.dart';
import 'package:interval_timer/features/preset_routines/domain/models/enums.dart';
import 'package:interval_timer/features/preset_routines/domain/models/exercise.dart';
import 'package:interval_timer/features/preset_routines/domain/models/preset_exercise_ref.dart';
import 'package:interval_timer/features/preset_routines/domain/models/preset_routine.dart';

void main() {
  late AppDatabase db;
  late WorkoutRepository workoutRepository;
  late PresetClonerService clonerService;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    workoutRepository = WorkoutRepository(db);
    clonerService = PresetClonerService(workoutRepository: workoutRepository);
  });

  tearDown(() async {
    await db.close();
  });

  test('clonePreset creates structured Workout with WorkoutExercises in Drift DB', () async {
    const preset = PresetRoutine(
      id: 'preset_test_1',
      title: 'Test Preset',
      description: 'Description',
      category: PresetCategory.core,
      difficulty: DifficultyLevel.beginner,
      restBetweenExercisesSeconds: 15,
      exercises: [
        PresetExerciseRef(
          exerciseId: 'ex_crunches',
          sets: 2,
          workSeconds: 30,
          restSeconds: 10,
        ),
      ],
    );

    final exerciseMap = {
      'ex_crunches': const Exercise(
        id: 'ex_crunches',
        name: 'Crunches',
        category: PresetCategory.core,
        mediaType: MediaType.image,
        mediaPath: 'assets/media/exercises/ex_crunches.png',
        steps: ['Paso 1'],
        tips: ['Tip 1'],
      ),
    };

    final clonedWorkout = await clonerService.clonePreset(
      preset,
      exerciseMap: exerciseMap,
    );

    expect(clonedWorkout.name, equals('Test Preset (Copia)'));
    expect(clonedWorkout.exercises.length, equals(1));
    expect(clonedWorkout.exercises.first.name, equals('Crunches'));
    expect(clonedWorkout.exercises.first.sets, equals(2));
    expect(clonedWorkout.exercises.first.workSeconds, equals(30));
    expect(clonedWorkout.exercises.first.restSeconds, equals(10));
    expect(clonedWorkout.exercises.first.restAfterExerciseSeconds, equals(15));

    final storedWorkouts = await db.getAllWorkoutRows();
    expect(storedWorkouts.any((w) => w.id == clonedWorkout.id), isTrue);

    final storedExercises = await db.getWorkoutExerciseRows(clonedWorkout.id);
    expect(storedExercises.length, equals(1));
    expect(storedExercises.first.name, equals('Crunches'));
  });
}

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/repositories/routine_repository.dart';
import 'package:interval_timer/features/preset_routines/application/preset_cloner_service.dart';
import 'package:interval_timer/features/preset_routines/domain/models/enums.dart';
import 'package:interval_timer/features/preset_routines/domain/models/exercise.dart';
import 'package:interval_timer/features/preset_routines/domain/models/preset_exercise_ref.dart';
import 'package:interval_timer/features/preset_routines/domain/models/preset_routine.dart';

void main() {
  late AppDatabase db;
  late RoutineRepository routineRepository;
  late PresetClonerService clonerService;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    routineRepository = RoutineRepository(db);
    clonerService = PresetClonerService(routineRepository: routineRepository);
  });

  tearDown(() async {
    await db.close();
  });

  test('clonePreset flattens PresetRoutine and inserts cloned routine into Drift DB', () async {
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

    final clonedRoutine = await clonerService.clonePreset(
      preset,
      exerciseMap: exerciseMap,
    );

    expect(clonedRoutine.name, equals('Test Preset (Copia)'));
    expect(clonedRoutine.items.length, equals(3)); // 2 work sets + 1 intra-set rest

    final storedRoutines = await db.getAllRoutines();
    expect(storedRoutines.any((r) => r.id == clonedRoutine.id), isTrue);

    final storedItems = await db.getRoutineItems(clonedRoutine.id);
    expect(storedItems.length, equals(3));
  });
}

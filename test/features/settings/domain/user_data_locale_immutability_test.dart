import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/models/session_log_status.dart';
import 'package:interval_timer/data/repositories/preferences_repository.dart';
import 'package:interval_timer/data/repositories/session_log_repository.dart';
import 'package:interval_timer/data/repositories/workout_repository.dart';
import 'package:interval_timer/features/settings/domain/app_language.dart';

void main() {
  late AppDatabase db;
  late WorkoutRepository workoutRepo;
  late SessionLogRepository sessionRepo;
  late PreferencesRepository prefsRepo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    workoutRepo = WorkoutRepository(db);
    sessionRepo = SessionLogRepository(db);
    prefsRepo = PreferencesRepository(db);
  });

  tearDown(() async => db.close());

  group('User Data Immutability on Locale Change (R12)', () {
    test('preserves user workout names, exercises, and session notes exactly across locale changes', () async {
      // 1. Create user data in Spanish context
      final workout = await workoutRepo.createWorkout('Mi Rutina Personalizada de Piernas');
      await workoutRepo.addExercise(
        workoutId: workout.id,
        name: 'Sentadillas profundas con barra',
        sets: 4,
        workSeconds: 45,
        restSeconds: 15,
        restAfterExerciseSeconds: 60,
      );

      final log = await sessionRepo.insert(
        sourceId: workout.id,
        displayName: workout.name,
        endedAt: DateTime.now(),
        totalDurationSeconds: 1800,
        itemCount: 4,
        status: SessionLogStatus.completed,
      );
      await sessionRepo.updateNote(
        log.id,
        'Entrenamiento excelente, aumenté 5kg.',
      );

      // 2. User switches app language to English ('en')
      await prefsRepo.setAppLanguage(AppLanguage.en.name);
      expect(await prefsRepo.getAppLanguage(), 'en');

      // 3. Verify user data in database remains 100% identical
      final loadedWorkoutEn = await workoutRepo.getWorkout(workout.id);
      expect(loadedWorkoutEn, isNotNull);
      expect(loadedWorkoutEn!.name, 'Mi Rutina Personalizada de Piernas');
      expect(
        loadedWorkoutEn.exercises.first.name,
        'Sentadillas profundas con barra',
      );

      final logsEn = await sessionRepo.getByLocalDate(log.localDate);
      expect(logsEn, isNotEmpty);
      expect(logsEn.first.displayName, 'Mi Rutina Personalizada de Piernas');
      expect(logsEn.first.note, 'Entrenamiento excelente, aumenté 5kg.');

      // 4. User switches app language back to Spanish ('es')
      await prefsRepo.setAppLanguage(AppLanguage.es.name);
      expect(await prefsRepo.getAppLanguage(), 'es');

      final loadedWorkoutEs = await workoutRepo.getWorkout(workout.id);
      expect(loadedWorkoutEs!.name, 'Mi Rutina Personalizada de Piernas');
      expect(
        loadedWorkoutEs.exercises.first.name,
        'Sentadillas profundas con barra',
      );

      final logsEs = await sessionRepo.getByLocalDate(log.localDate);
      expect(logsEs.first.note, 'Entrenamiento excelente, aumenté 5kg.');
    });
  });
}

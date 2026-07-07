import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/repositories/routine_repository.dart';
import 'package:interval_timer/features/timer/application/timer_controller.dart';
import 'package:interval_timer/features/timer/application/timer_state.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(openConnection());
  ref.onDispose(db.close);
  return db;
});

final routineRepositoryProvider = Provider<RoutineRepository>((ref) {
  return RoutineRepository(ref.watch(databaseProvider));
});

final timerControllerProvider =
    NotifierProvider<TimerController, TimerState>(TimerController.new);

final loadedRoutineProvider = FutureProvider((ref) async {
  final repo = ref.watch(routineRepositoryProvider);
  return repo.getActiveRoutine();
});
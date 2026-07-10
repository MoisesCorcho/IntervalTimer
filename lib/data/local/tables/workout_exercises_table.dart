import 'package:drift/drift.dart';
import 'package:interval_timer/data/local/tables/workouts_table.dart';

@DataClassName('WorkoutExerciseRow')
class WorkoutExercises extends Table {
  TextColumn get id => text()();
  TextColumn get workoutId =>
      text().references(Workouts, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  TextColumn get name => text()();
  IntColumn get sets => integer()();
  IntColumn get workSeconds => integer()();
  IntColumn get restSeconds => integer()();
  IntColumn get restAfterExerciseSeconds =>
      integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {workoutId, position},
      ];
}
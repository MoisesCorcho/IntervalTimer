import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/local/mappers/routine_mapper.dart';
import 'package:interval_timer/data/models/interval.dart' as domain;
import 'package:interval_timer/data/models/interval_type.dart';
import 'package:interval_timer/data/models/routine.dart' as domain;
import 'package:interval_timer/data/models/routine_item.dart';
import 'package:uuid/uuid.dart';

class RoutineRepository {
  RoutineRepository(this._db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final Uuid _uuid;
  static const activeRoutineId = 'active-routine';

  Future<domain.Routine> getActiveRoutine() async {
    final routines = await _db.getAllRoutines();
    if (routines.isEmpty) {
      return _emptyActiveRoutine();
    }

    final routineRow = routines.firstWhere(
      (r) => r.id == activeRoutineId,
      orElse: () => routines.first,
    );

    final itemRows = await _db.getRoutineItems(routineRow.id);
    final allIntervals = await _db.getAllIntervals();
    final intervalsById = {for (final i in allIntervals) i.id: i};

    return mapRoutineWithItems(routineRow, itemRows, intervalsById);
  }

  Future<void> saveActiveRoutine(domain.Routine routine) async {
    final intervalRows = <IntervalRow>[];
    final itemRows = <RoutineItemRow>[];

    for (var i = 0; i < routine.items.length; i++) {
      final item = routine.items[i];
      switch (item) {
        case IntervalRoutineItem(:final interval):
          intervalRows.add(
            IntervalRow(
              id: interval.id,
              name: interval.name,
              durationSeconds: interval.durationSeconds,
              colorArgb: interval.colorArgb,
              type: interval.type.storageValue,
              announceText: interval.announceText,
            ),
          );
          itemRows.add(
            RoutineItemRow(
              id: _uuid.v4(),
              routineId: routine.id,
              position: i,
              itemType: 'interval',
              intervalId: interval.id,
            ),
          );
      }
    }

    await _db.replaceRoutineData(
      routine: RoutineRow(
        id: routine.id,
        name: routine.name,
        createdAt: routine.createdAt.toUtc().millisecondsSinceEpoch,
      ),
      intervalRows: intervalRows,
      itemRows: itemRows,
    );
  }

  domain.Interval newInterval({
    required String name,
    required int durationSeconds,
    required int colorArgb,
    IntervalType type = IntervalType.work,
    String? announceText,
  }) {
    return domain.Interval(
      id: _uuid.v4(),
      name: name,
      durationSeconds: durationSeconds,
      colorArgb: colorArgb,
      type: type,
      announceText: announceText,
    );
  }

  domain.Routine _emptyActiveRoutine() {
    return domain.Routine(
      id: activeRoutineId,
      name: 'Mi rutina',
      createdAt: DateTime.now().toUtc(),
      items: const [],
    );
  }
}
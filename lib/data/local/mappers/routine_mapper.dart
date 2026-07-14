import 'package:drift/drift.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/models/interval.dart' as domain;
import 'package:interval_timer/data/models/interval_type.dart';
import 'package:interval_timer/data/models/routine.dart' as domain;
import 'package:interval_timer/data/models/routine_item.dart';
import 'package:interval_timer/data/models/routine_item_type.dart';

domain.Interval mapIntervalRow(IntervalRow row) {
  return domain.Interval(
    id: row.id,
    name: row.name,
    durationSeconds: row.durationSeconds,
    colorArgb: row.colorArgb,
    type: IntervalType.fromStorage(row.type),
    announceText: row.announceText,
  );
}

domain.Routine mapRoutineWithItems(
  RoutineRow routineRow,
  List<RoutineItemRow> itemRows,
  Map<String, IntervalRow> intervalsById,
) {
  final items = <RoutineItem>[];
  for (final itemRow in itemRows) {
    if (itemRow.itemType == RoutineItemType.interval.storageValue) {
      final intervalId = itemRow.intervalId;
      if (intervalId == null) continue;
      final intervalRow = intervalsById[intervalId];
      if (intervalRow == null) continue;
      items.add(RoutineItem.interval(mapIntervalRow(intervalRow)));
    }
  }

  return domain.Routine(
    id: routineRow.id,
    name: routineRow.name,
    createdAt: DateTime.fromMillisecondsSinceEpoch(
      routineRow.createdAt,
      isUtc: true,
    ),
    items: items,
  );
}

IntervalsCompanion intervalToCompanion(domain.Interval interval) {
  return IntervalsCompanion.insert(
    id: interval.id,
    name: interval.name,
    durationSeconds: interval.durationSeconds,
    colorArgb: interval.colorArgb,
    type: interval.type.storageValue,
    announceText: Value(interval.announceText),
  );
}

RoutinesCompanion routineToCompanion(domain.Routine routine) {
  return RoutinesCompanion.insert(
    id: routine.id,
    name: routine.name,
    createdAt: routine.createdAt.toUtc().millisecondsSinceEpoch,
  );
}

RoutineItemsCompanion routineItemToCompanion({
  required String id,
  required String routineId,
  required int position,
  required String intervalId,
}) {
  return RoutineItemsCompanion.insert(
    id: id,
    routineId: routineId,
    position: position,
    itemType: RoutineItemType.interval.storageValue,
    intervalId: Value(intervalId),
  );
}
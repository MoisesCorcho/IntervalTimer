import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/data/models/interval.dart';
import 'package:interval_timer/data/models/interval_type.dart';
import 'package:interval_timer/data/models/routine.dart';
import 'package:interval_timer/data/models/routine_item.dart';
import 'package:interval_timer/data/repositories/routine_repository.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';
import 'package:interval_timer/features/timer/application/timer_state.dart';

class RoutineEditorController extends AsyncNotifier<Routine> {
  @override
  Future<Routine> build() async {
    final repo = ref.watch(routineRepositoryProvider);
    return repo.getActiveRoutine();
  }

  bool get canEdit {
    final timerState = ref.read(timerControllerProvider);
    return timerState.status == TimerStatus.idle;
  }

  Future<bool> addInterval(Interval interval) async {
    if (!canEdit) return false;
    final current = await future;
    final updated = current.copyWith(
      items: [...current.items, RoutineItem.interval(interval)],
    );
    return _persist(updated);
  }

  Future<bool> updateInterval(int index, Interval interval) async {
    if (!canEdit) return false;
    final current = await future;
    if (index < 0 || index >= current.items.length) return false;

    final items = List<RoutineItem>.from(current.items);
    items[index] = RoutineItem.interval(interval);
    return _persist(current.copyWith(items: items));
  }

  Future<bool> removeInterval(int index) async {
    if (!canEdit) return false;
    final current = await future;
    if (index < 0 || index >= current.items.length) return false;

    final items = List<RoutineItem>.from(current.items)..removeAt(index);
    return _persist(current.copyWith(items: items));
  }

  Future<bool> _persist(Routine routine) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(routineRepositoryProvider);
      await repo.saveActiveRoutine(routine);
      ref.read(timerControllerProvider.notifier).bindRoutine(routine);
      return routine;
    });
    return !state.hasError;
  }

  Interval createNewInterval({
    required String name,
    required int durationSeconds,
    required int colorArgb,
    IntervalType type = IntervalType.work,
    String? announceText,
  }) {
    final repo = ref.read(routineRepositoryProvider);
    return repo.newInterval(
      name: name,
      durationSeconds: durationSeconds,
      colorArgb: colorArgb,
      type: type,
      announceText: announceText,
    );
  }
}

final routineEditorProvider =
    AsyncNotifierProvider<RoutineEditorController, Routine>(
  RoutineEditorController.new,
);
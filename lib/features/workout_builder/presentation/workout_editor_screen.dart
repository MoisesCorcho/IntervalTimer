import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/core/utils/duration_parser.dart';
import 'package:interval_timer/data/models/workout_exercise.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';
import 'package:interval_timer/features/workout_builder/application/workout_editor_controller.dart';
import 'package:interval_timer/features/workout_builder/application/workout_providers.dart';
import 'package:interval_timer/features/workout_builder/domain/workout_flattener.dart';
import 'package:interval_timer/features/workout_builder/domain/workout_validators.dart';
import 'package:interval_timer/features/workout_builder/presentation/widgets/exercise_form.dart';

class WorkoutEditorScreen extends ConsumerStatefulWidget {
  const WorkoutEditorScreen({super.key, required this.workoutId});

  final String workoutId;

  @override
  ConsumerState<WorkoutEditorScreen> createState() =>
      _WorkoutEditorScreenState();
}

class _WorkoutEditorScreenState extends ConsumerState<WorkoutEditorScreen> {
  String? _actionError;

  WorkoutEditorController get _editor =>
      ref.read(workoutEditorControllerProvider(widget.workoutId).notifier);

  Future<void> _showRenameDialog(String currentName) async {
    final controller = TextEditingController(text: currentName);
    String? nameError;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text(UiStrings.workoutName),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: UiStrings.workoutName,
                errorText: nameError,
              ),
              maxLength: WorkoutValidators.maxWorkoutNameLength + 1,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(UiStrings.cancel),
              ),
              FilledButton(
                onPressed: () {
                  nameError =
                      WorkoutValidators.validateWorkoutName(controller.text);
                  if (nameError != null) {
                    setDialogState(() {});
                    return;
                  }
                  Navigator.pop(context, true);
                },
                child: const Text(UiStrings.save),
              ),
            ],
          );
        },
      ),
    );

    if (saved != true) return;

    final ok = await _editor.renameWorkout(controller.text);
    if (!ok && mounted) {
      _showPersistenceError(() => _editor.renameWorkout(controller.text));
    }
  }

  Future<void> _showExerciseSheet({WorkoutExercise? existing}) async {
    if (!_editor.canEdit) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppTheme.spacingMd,
            right: AppTheme.spacingMd,
            top: AppTheme.spacingMd,
            bottom: MediaQuery.viewInsetsOf(context).bottom + AppTheme.spacingMd,
          ),
          child: ExerciseForm(
            initial: existing,
            onSubmit: (result) async {
              final ok = existing == null
                  ? await _editor.addExercise(
                      name: result.name,
                      sets: result.sets,
                      workSeconds: result.workSeconds,
                      restSeconds: result.restSeconds,
                    )
                  : await _editor.updateExercise(
                      existing.copyWith(
                        name: result.name,
                        sets: result.sets,
                        workSeconds: result.workSeconds,
                        restSeconds: result.restSeconds,
                      ),
                    );

              if (!ok && context.mounted) {
                _showPersistenceError(() async {
                  if (existing == null) {
                    await _editor.addExercise(
                      name: result.name,
                      sets: result.sets,
                      workSeconds: result.workSeconds,
                      restSeconds: result.restSeconds,
                    );
                  } else {
                    await _editor.updateExercise(
                      existing.copyWith(
                        name: result.name,
                        sets: result.sets,
                        workSeconds: result.workSeconds,
                        restSeconds: result.restSeconds,
                      ),
                    );
                  }
                });
              }

              if (context.mounted) Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  Future<void> _trainWorkout() async {
    final workout =
        ref.read(workoutEditorControllerProvider(widget.workoutId)).valueOrNull;
    if (workout == null || workout.exercises.isEmpty) {
      setState(() => _actionError = UiStrings.emptyWorkoutStart);
      return;
    }

    setState(() => _actionError = null);

    final flattened = flattenWorkout(
      workout,
      workColorArgb: AppTheme.workColor.toARGB32(),
      restColorArgb: AppTheme.restColor.toARGB32(),
    );

    ref.read(timerControllerProvider.notifier).loadFlattenedWorkout(
          workoutId: workout.id,
          workoutName: workout.name,
          flattened: flattened,
        );
    await ref
        .read(activeWorkoutIdProvider.notifier)
        .setActiveWorkoutId(workout.id);

    final started = ref.read(timerControllerProvider.notifier).start();
    if (!mounted) return;
    if (started) {
      context.go('/execute');
    } else {
      setState(() => _actionError = UiStrings.emptyWorkoutStart);
    }
  }

  void _showPersistenceError(Future<void> Function() onRetry) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(UiStrings.persistenceError),
        action: SnackBarAction(
          label: UiStrings.retry,
          onPressed: () => onRetry(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workoutAsync =
        ref.watch(workoutEditorControllerProvider(widget.workoutId));
    final canEdit = _editor.canEdit;

    return Scaffold(
      appBar: AppBar(
        title: workoutAsync.when(
          data: (workout) => Text(workout.name),
          loading: () => const Text(UiStrings.editWorkout),
          error: (_, __) => const Text(UiStrings.editWorkout),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.drive_file_rename_outline),
            tooltip: UiStrings.workoutName,
            onPressed: workoutAsync.hasValue
                ? () => _showRenameDialog(workoutAsync.requireValue.name)
                : null,
          ),
        ],
      ),
      body: workoutAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(UiStrings.persistenceError),
              const SizedBox(height: AppTheme.spacingMd),
              FilledButton(
                onPressed: () => ref.invalidate(
                  workoutEditorControllerProvider(widget.workoutId),
                ),
                child: const Text(UiStrings.retry),
              ),
            ],
          ),
        ),
        data: (workout) {
          return Column(
            children: [
              Expanded(
                child: workout.exercises.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppTheme.spacingLg),
                          child: Text(
                            UiStrings.emptyWorkoutStart,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      )
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.all(AppTheme.spacingMd),
                        itemCount: workout.exercises.length,
                        onReorder: (oldIndex, newIndex) async {
                          if (!canEdit) return;
                          if (newIndex > oldIndex) newIndex--;
                          final ids = workout.exercises
                              .map((e) => e.id)
                              .toList();
                          final moved = ids.removeAt(oldIndex);
                          ids.insert(newIndex, moved);
                          final ok = await _editor.reorderExercises(ids);
                          if (!ok && mounted) {
                            _showPersistenceError(
                              () => _editor.reorderExercises(ids),
                            );
                          }
                        },
                        itemBuilder: (context, index) {
                          final exercise = workout.exercises[index];
                          return Card(
                            key: ValueKey(exercise.id),
                            child: ListTile(
                              onTap: canEdit
                                  ? () => _showExerciseSheet(
                                        existing: exercise,
                                      )
                                  : null,
                              title: Text(exercise.name),
                              subtitle: Text(
                                '${exercise.sets} sets · '
                                '${formatDurationMmSs(exercise.workSeconds)} / '
                                '${formatDurationMmSs(exercise.restSeconds)}',
                              ),
                              trailing: canEdit
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.drag_handle),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                          ),
                                          onPressed: () async {
                                            final ok = await _editor
                                                .deleteExercise(exercise.id);
                                            if (!ok && mounted) {
                                              _showPersistenceError(
                                                () => _editor.deleteExercise(
                                                  exercise.id,
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
              ),
              if (_actionError != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd,
                  ),
                  child: Text(
                    _actionError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            canEdit ? () => _showExerciseSheet() : null,
                        icon: const Icon(Icons.add),
                        label: const Text(UiStrings.addExercise),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMd),
                    Expanded(
                      child: FilledButton(
                        onPressed: _trainWorkout,
                        child: const Text(UiStrings.train),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
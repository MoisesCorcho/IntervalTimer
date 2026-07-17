import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/data/models/workout.dart';
import 'package:interval_timer/features/settings/application/settings_providers.dart';
import 'package:interval_timer/features/settings/data/settings_repository.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';
import 'package:interval_timer/features/timer/application/timer_state.dart';
import 'package:interval_timer/features/workout_builder/application/workout_providers.dart';
import 'package:interval_timer/features/workout_builder/domain/workout_flattener.dart';
import 'package:interval_timer/features/workout_builder/domain/workout_validators.dart';
import 'package:interval_timer/features/workout_builder/presentation/widgets/delete_workout_dialog.dart';
import 'package:interval_timer/features/workout_builder/presentation/widgets/workout_actions_sheet.dart';
import 'package:interval_timer/shared/widgets/app_primary_button.dart';
import 'package:interval_timer/shared/widgets/dialog_actions_row.dart';

class MyWorkoutsScreen extends ConsumerStatefulWidget {
  const MyWorkoutsScreen({super.key});

  @override
  ConsumerState<MyWorkoutsScreen> createState() => _MyWorkoutsScreenState();
}

class _MyWorkoutsScreenState extends ConsumerState<MyWorkoutsScreen> {
  String? _actionError;

  Future<void> _showCreateDialog() async {
    final controller = TextEditingController();
    String? nameError;

    final created = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text(UiStrings.createWorkout),
            content: TextField(
              key: const Key('workout_name_field'),
              controller: controller,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: UiStrings.workoutName,
                errorText: nameError,
              ),
              maxLength: WorkoutValidators.maxWorkoutNameLength + 1,
              autofocus: true,
            ),
            actions: [
              DialogActionsRow(
                children: [
                  AppSecondaryButton(
                    compact: true,
                    onPressed: () => Navigator.pop(context, false),
                    label: UiStrings.cancel,
                  ),
                  AppPrimaryButton(
                    key: const Key('create_workout_confirm'),
                    compact: true,
                    onPressed: () {
                      nameError = WorkoutValidators.validateWorkoutName(
                        controller.text,
                      );
                      if (nameError != null) {
                        setDialogState(() {});
                        return;
                      }
                      Navigator.pop(context, true);
                    },
                    label: UiStrings.save,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    if (created != true || !mounted) return;

    final workout =
        await ref.read(workoutsListProvider.notifier).createWorkout(
              controller.text,
            );
    if (workout != null && mounted) {
      context.push('/workouts/${workout.id}/edit');
    }
  }

  Future<void> _trainWorkout(Workout workout) async {
    if (workout.exercises.isEmpty) {
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

    final prepSeconds = ref.read(settingsControllerProvider).valueOrNull
            ?.prepSeconds ??
        SettingsRepository.defaultPrepSeconds;
    final started = ref
        .read(timerControllerProvider.notifier)
        .start(prepSeconds: prepSeconds);
    if (!mounted) return;
    if (started) {
      context.go('/execute');
    } else {
      setState(() => _actionError = UiStrings.emptyWorkoutStart);
    }
  }

  Future<void> _duplicateWorkout(Workout workout) async {
    final copy =
        await ref.read(workoutsListProvider.notifier).duplicateWorkout(
              workout.id,
            );
    if (copy != null && mounted) {
      context.push('/workouts/${copy.id}/edit');
    } else if (mounted) {
      _showPersistenceError(() => _duplicateWorkout(workout));
    }
  }

  Future<void> _deleteWorkout(Workout workout) async {
    final timerStatus = ref.read(timerControllerProvider).status;
    if (timerStatus == TimerStatus.running ||
        timerStatus == TimerStatus.paused ||
        timerStatus == TimerStatus.preparing) {
      setState(() => _actionError = UiStrings.deleteBlockedDuringSession);
      return;
    }

    final confirmed = await showDeleteWorkoutDialog(context);
    if (confirmed != true) return;

    final deleted =
        await ref.read(workoutsListProvider.notifier).deleteWorkout(workout.id);
    if (!deleted && mounted) {
      _showPersistenceError(() => _deleteWorkout(workout));
    }
  }

  Future<void> _onWorkoutOverflow(Workout workout) async {
    final action = await showWorkoutActionsSheet(
      context: context,
      workout: workout,
    );
    if (action == null || !mounted) return;

    switch (action) {
      case WorkoutAction.train:
        await _trainWorkout(workout);
      case WorkoutAction.edit:
        context.push('/workouts/${workout.id}/edit');
      case WorkoutAction.duplicate:
        await _duplicateWorkout(workout);
      case WorkoutAction.delete:
        await _deleteWorkout(workout);
    }
  }

  void _showPersistenceError(VoidCallback onRetry) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(UiStrings.persistenceError),
        action: SnackBarAction(
          label: UiStrings.retry,
          onPressed: onRetry,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workoutsAsync = ref.watch(workoutsListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(UiStrings.workoutsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        icon: const Icon(Icons.add),
        label: const Text(UiStrings.createWorkout),
      ),
      body: workoutsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(UiStrings.persistenceError),
              const SizedBox(height: AppTheme.spacingMd),
              AppPrimaryButton(
                onPressed: () => ref.invalidate(workoutsListProvider),
                label: UiStrings.retry,
              ),
            ],
          ),
        ),
        data: (workouts) {
          if (workouts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                child: Text(
                  UiStrings.emptyWorkoutsHint,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return Column(
            children: [
              if (_actionError != null)
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  child: Text(
                    _actionError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.spacingMd,
                    AppTheme.spacingMd,
                    AppTheme.spacingMd,
                    88,
                  ),
                  itemCount: workouts.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppTheme.spacingSm),
                  itemBuilder: (context, index) {
                    final workout = workouts[index];
                    final countLabel = UiStrings.exerciseCountLabel
                        .replaceAll('{count}', '${workout.exercises.length}');
                    final showRounds = workout.rounds > 1;
                    final roundsLabel = UiStrings.workoutRoundsListLabel
                        .replaceAll('{count}', '${workout.rounds}');

                    return Card(
                      child: ListTile(
                        title: Text(workout.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(countLabel),
                            if (showRounds) ...[
                              const SizedBox(height: 6),
                              Chip(
                                key: Key('workout_rounds_chip_${workout.id}'),
                                avatar: Icon(
                                  Icons.loop_rounded,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                label: Text(roundsLabel),
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                labelStyle: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ],
                        ),
                        isThreeLine: showRounds,
                        trailing: IconButton(
                          key: Key('workout_overflow_${workout.id}'),
                          tooltip: 'Más opciones',
                          onPressed: () => _onWorkoutOverflow(workout),
                          icon: const Icon(Icons.more_vert),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
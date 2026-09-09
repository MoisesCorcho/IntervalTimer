import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interval_timer/core/l10n/l10n_extension.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/data/models/favorite_routine.dart';
import 'package:interval_timer/data/models/workout.dart';
import 'package:interval_timer/features/favorites/application/favorite_providers.dart';
import 'package:interval_timer/features/favorites/presentation/widgets/home_favorites_section.dart';
import 'package:interval_timer/features/preset_routines/application/preset_providers.dart';
import 'package:interval_timer/features/preset_routines/presentation/widgets/preset_hero_carousel.dart';
import 'package:interval_timer/features/settings/application/settings_providers.dart';
import 'package:interval_timer/features/settings/data/settings_repository.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';
import 'package:interval_timer/features/timer/application/timer_state.dart';
import 'package:interval_timer/features/workout_builder/application/workout_providers.dart';
import 'package:interval_timer/features/workout_builder/domain/workout_flattener.dart';
import 'package:interval_timer/features/workout_builder/domain/workout_validators.dart';
import 'package:interval_timer/features/workout_builder/presentation/widgets/delete_workout_dialog.dart';
import 'package:interval_timer/features/workout_builder/presentation/widgets/workout_actions_sheet.dart';
import 'package:interval_timer/features/workout_builder/presentation/widgets/workout_rounds_list_chip.dart';
import 'package:interval_timer/shared/widgets/app_primary_button.dart';
import 'package:interval_timer/shared/widgets/dialog_actions_row.dart';
import 'package:interval_timer/shared/widgets/favorite_toggle_button.dart';

class MyWorkoutsScreen extends ConsumerStatefulWidget {
  const MyWorkoutsScreen({super.key});

  @override
  ConsumerState<MyWorkoutsScreen> createState() => _MyWorkoutsScreenState();
}

class _MyWorkoutsScreenState extends ConsumerState<MyWorkoutsScreen> {
  String? _actionError;
  bool _favoritesOnly = false;

  Future<void> _showCreateDialog() async {
    final controller = TextEditingController();
    String? nameError;

    final created = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final l10n = context.l10n;
          return AlertDialog(
            title: Text(l10n.createWorkout),
            content: TextField(
              key: const Key('workout_name_field'),
              controller: controller,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: l10n.workoutName,
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
                    label: l10n.cancel,
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
                    label: l10n.save,
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
      setState(() => _actionError = context.l10n.emptyWorkoutStart);
      return;
    }

    final timerStatus = ref.read(timerControllerProvider).status;
    if (timerStatus == TimerStatus.running ||
        timerStatus == TimerStatus.paused ||
        timerStatus == TimerStatus.preparing) {
      final leave = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          final l10n = dialogContext.l10n;
          return AlertDialog(
            title: Text(l10n.exitConfirmTitle),
            content: Text(l10n.exitConfirmMessage),
            actions: [
              DialogActionsRow(
                children: [
                  AppSecondaryButton(
                    compact: true,
                    onPressed: () => Navigator.pop(dialogContext, false),
                    label: l10n.exitConfirmContinue,
                  ),
                  AppPrimaryButton(
                    compact: true,
                    onPressed: () => Navigator.pop(dialogContext, true),
                    label: l10n.exitConfirmLeave,
                  ),
                ],
              ),
            ],
          );
        },
      );
      if (leave != true) return;
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
      setState(() => _actionError = context.l10n.emptyWorkoutStart);
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
        final dup = await ref
            .read(workoutsListProvider.notifier)
            .duplicateWorkout(workout.id);
        if (dup == null && mounted) {
          _showPersistenceError(
            () => ref
                .read(workoutsListProvider.notifier)
                .duplicateWorkout(workout.id),
          );
        }
      case WorkoutAction.delete:
        final timerStatus = ref.read(timerControllerProvider).status;
        if (timerStatus == TimerStatus.running ||
            timerStatus == TimerStatus.paused ||
            timerStatus == TimerStatus.preparing) {
          setState(() => _actionError = context.l10n.deleteBlockedDuringSession);
          return;
        }

        final confirmed = await showDeleteWorkoutDialog(context);
        if (confirmed != true) return;

        final deleted = await ref
            .read(workoutsListProvider.notifier)
            .deleteWorkout(workout.id);
        if (!deleted && mounted) {
          _showPersistenceError(
            () => ref
                .read(workoutsListProvider.notifier)
                .deleteWorkout(workout.id),
          );
        }
    }
  }

  void _showPersistenceError(Future<void> Function() onRetry) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.persistenceError),
        action: SnackBarAction(
          label: context.l10n.retry,
          onPressed: () => onRetry(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final workoutsAsync = ref.watch(workoutsListProvider);
    final catalogAsync = ref.watch(presetCatalogProvider);
    final favoriteIds = ref.watch(favoriteIdsStreamProvider).valueOrNull ?? {};

    return Scaffold(
      appBar: AppBar(title: Text(l10n.workoutsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        icon: const Icon(Icons.add),
        label: Text(l10n.createWorkout),
      ),
      body: workoutsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.persistenceError),
              const SizedBox(height: AppTheme.spacingMd),
              AppPrimaryButton(
                onPressed: () => ref.invalidate(workoutsListProvider),
                label: l10n.retry,
              ),
            ],
          ),
        ),
        data: (workouts) {
          final displayedWorkouts = _favoritesOnly
              ? workouts.where((w) => favoriteIds.contains(w.id)).toList()
              : workouts;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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

                // Section 0: Home Favorites Section (auto-hides when count == 0)
                const HomeFavoritesSection(),

                // Section 1: Featured Presets Hero Carousel
                catalogAsync.when(
                  data: (allPresets) {
                    final featuredPresets =
                        allPresets.where((p) => p.isFeatured).toList();
                    if (featuredPresets.isEmpty) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.featuredRoutines,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              TextButton(
                                key: const Key('see_all_presets_button'),
                                onPressed: () => context.push('/presets'),
                                child: Text(l10n.seeAll),
                              ),
                            ],
                          ),
                        ),
                        PresetHeroCarousel(presets: featuredPresets),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                // Section 2: User Custom Workouts
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.myRoutines,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      FilterChip(
                        key: const Key('workouts_favorite_filter_chip'),
                        avatar: Icon(
                          Icons.star,
                          size: 16,
                          color: _favoritesOnly ? Colors.amber : Colors.grey,
                        ),
                        label: Text(l10n.favoritesFilterChip),
                        selected: _favoritesOnly,
                        onSelected: (val) {
                          setState(() => _favoritesOnly = val);
                        },
                      ),
                    ],
                  ),
                ),
                if (displayedWorkouts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingLg),
                    child: Center(
                      child: Text(
                        _favoritesOnly
                            ? l10n.noFavoriteWorkouts
                            : l10n.emptyWorkoutsHint,
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                       AppTheme.spacingMd,
                       AppTheme.spacingSm,
                       AppTheme.spacingMd,
                      88,
                    ),
                    itemCount: displayedWorkouts.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppTheme.spacingSm),
                    itemBuilder: (context, index) {
                      final workout = displayedWorkouts[index];
                      final countLabel =
                          l10n.exerciseCountLabel(workout.exercises.length);
                      final showRounds = workout.rounds > 1;

                      return Card(
                        child: ListTile(
                          title: Text(workout.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(countLabel),
                              if (showRounds) ...[
                                const SizedBox(height: 6),
                                WorkoutRoundsListChip(
                                  workoutId: workout.id,
                                  rounds: workout.rounds,
                                ),
                              ],
                            ],
                          ),
                          isThreeLine: showRounds,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FavoriteToggleButton(
                                targetId: workout.id,
                                targetType: FavoriteTargetType.workout,
                              ),
                              IconButton(
                                key: Key('workout_overflow_${workout.id}'),
                                tooltip: l10n.moreOptions,
                                onPressed: () => _onWorkoutOverflow(workout),
                                icon: const Icon(Icons.more_vert),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
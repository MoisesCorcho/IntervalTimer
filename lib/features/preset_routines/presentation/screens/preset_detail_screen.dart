import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interval_timer/core/l10n/l10n_extension.dart';
import 'package:interval_timer/data/models/favorite_routine.dart';
import 'package:interval_timer/features/preset_routines/application/preset_providers.dart';
import 'package:interval_timer/features/preset_routines/domain/models/preset_routine.dart';
import 'package:interval_timer/features/preset_routines/domain/services/preset_routine_flattener.dart';
import 'package:interval_timer/features/preset_routines/presentation/widgets/exercise_media_widget.dart';
import 'package:interval_timer/features/preset_routines/presentation/widgets/exercise_technique_bottom_sheet.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';
import 'package:interval_timer/shared/widgets/favorite_toggle_button.dart';

class PresetDetailScreen extends ConsumerWidget {
  final String presetId;

  const PresetDetailScreen({
    super.key,
    required this.presetId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presetAsync = ref.watch(presetDetailProvider(presetId));
    final exerciseMapAsync = ref.watch(exerciseMapProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.presetDetailTitle),
        actions: [
          FavoriteToggleButton(
            targetId: presetId,
            targetType: FavoriteTargetType.preset,
          ),
          IconButton(
            key: const Key('duplicate_routine_appbar_button'),
            icon: const Icon(Icons.copy),
            tooltip: context.l10n.duplicateToMyRoutines,
            onPressed: () => _handleDuplicate(context, ref),
          ),
        ],
      ),
      body: presetAsync.when(
        data: (preset) {
          if (preset == null) {
            return Center(
              child: Text(context.l10n.routineNotFound),
            );
          }
          final exerciseMap = exerciseMapAsync.value ?? {};
          return _PresetDetailBody(preset: preset, exerciseMap: exerciseMap);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error al cargar detalle: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(presetDetailProvider(presetId)),
                child: Text(context.l10n.retry),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: presetAsync.maybeWhen(
        data: (preset) => preset != null
            ? FloatingActionButton.extended(
                key: const Key('start_workout_fab'),
                onPressed: () => _handleStartWorkout(context, ref, preset),
                icon: const Icon(Icons.play_arrow),
                label: Text(
                  context.l10n.startWorkout,
                  style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
                ),
              )
            : null,
        orElse: () => null,
      ),
    );
  }

  void _handleStartWorkout(
    BuildContext context,
    WidgetRef ref,
    PresetRoutine preset,
  ) {
    final exerciseMap = ref.read(exerciseMapProvider).value ?? {};
    final flattenedIntervals = PresetRoutineFlattener.flatten(
      preset: preset,
      exerciseMap: exerciseMap,
    );

    final timerNotifier = ref.read(timerControllerProvider.notifier);
    timerNotifier.loadSession(
      sessionId: preset.id,
      sessionName: preset.title,
      intervals: flattenedIntervals,
    );

    final started = timerNotifier.start(prepSeconds: 10);
    if (started) {
      context.go('/execute');
    }
  }


  Future<void> _handleDuplicate(BuildContext context, WidgetRef ref) async {
    final preset = ref.read(presetDetailProvider(presetId)).value;
    if (preset == null) return;

    final exerciseMap = ref.read(exerciseMapProvider).value ?? {};
    final clonerService = ref.read(presetClonerServiceProvider);

    try {
      final clonedRoutine = await clonerService.clonePreset(
        preset,
        exerciseMap: exerciseMap,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.routineSavedToMyRoutines(clonedRoutine.name)),
            action: SnackBarAction(
              label: context.l10n.goToRoutines,
              onPressed: () => context.go('/workouts'),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.errorCloningRoutine(e.toString()))),
        );
      }
    }
  }
}

class _PresetDetailBody extends StatelessWidget {
  final PresetRoutine preset;
  final Map<String, dynamic> exerciseMap;

  const _PresetDetailBody({
    required this.preset,
    required this.exerciseMap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalDurationSec = preset.calculateTotalDurationSeconds();
    final minutes = totalDurationSec ~/ 60;
    final seconds = totalDurationSec % 60;
    final formattedTime = seconds > 0 ? '${minutes}m ${seconds}s' : '${minutes}m';
    final estimatedKcal = (8.0 * 70 * totalDurationSec / 3600).round();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 88.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner / Header Gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.surfaceContainerHighest,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Chip(
                      label: Text(preset.category.label),
                      backgroundColor: theme.colorScheme.primary,
                      labelStyle: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(preset.difficulty.label),
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      labelStyle: TextStyle(
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  preset.title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  preset.description,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                // Metric Stats Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _MetricBadge(
                      icon: Icons.timer,
                      label: context.l10n.metricDuration,
                      value: formattedTime,
                    ),
                    _MetricBadge(
                      icon: Icons.local_fire_department,
                      label: context.l10n.metricEstCalories,
                      value: '~$estimatedKcal kcal',
                    ),
                    _MetricBadge(
                      icon: Icons.fitness_center,
                      label: context.l10n.metricExercises,
                      value: '${preset.exercises.length}',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Secondary Action Button: Duplicar a Mis Rutinas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: OutlinedButton.icon(
              key: const Key('duplicate_routine_button'),
              onPressed: () {
                final state = context.findAncestorWidgetOfExactType<PresetDetailScreen>();
                // Invoke duplicate
                final widgetRef = ProviderScope.containerOf(context, listen: false);
                final clonerService = widgetRef.read(presetClonerServiceProvider);
                final exerciseMapTyped = widgetRef.read(exerciseMapProvider).value ?? {};
                clonerService.clonePreset(preset, exerciseMap: exerciseMapTyped).then((cloned) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.l10n.routineDuplicated(cloned.name)),
                      action: SnackBarAction(
                        label: context.l10n.goToRoutines,
                        onPressed: () => context.go('/workouts'),
                      ),
                    ),
                  );
                });
              },
              icon: const Icon(Icons.bookmark_add_outlined),
              label: Text(context.l10n.duplicateToMyRoutines),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Exercise List Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              context.l10n.sessionExercisesTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Exercise List Cards
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: preset.exercises.length,
            itemBuilder: (context, index) {
              final ref = preset.exercises[index];
              final exercise = exerciseMap[ref.exerciseId];
              final name = exercise?.name ?? ref.exerciseId;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: SizedBox(
                    width: 56,
                    height: 56,
                    child: ExerciseMediaWidget(
                      exercise: exercise,
                      category: preset.category,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  title: Text(
                    '${index + 1}. $name',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${ref.sets} sets × ${ref.workSeconds}s ${context.l10n.workShort}'
                    '${ref.restSeconds > 0 ? " / ${ref.restSeconds}s ${context.l10n.restShort}" : ""}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    if (exercise != null) {
                      ExerciseTechniqueBottomSheet.show(context, exercise);
                    }
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MetricBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetricBadge({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, size: 24, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

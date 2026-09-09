import 'package:flutter/material.dart' hide Interval;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interval_timer/core/l10n/l10n_extension.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/core/utils/duration_parser.dart';
import 'package:interval_timer/data/models/interval.dart';
import 'package:interval_timer/data/models/routine_item.dart';
import 'package:interval_timer/features/settings/application/settings_providers.dart';
import 'package:interval_timer/features/settings/data/settings_repository.dart';
import 'package:interval_timer/features/timer/application/routine_editor_controller.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';
import 'package:interval_timer/features/timer/application/timer_state.dart';
import 'package:interval_timer/features/workout_builder/application/workout_providers.dart';
import 'package:interval_timer/features/timer/presentation/widgets/interval_form.dart';
import 'package:interval_timer/shared/widgets/app_primary_button.dart';
import 'package:interval_timer/shared/widgets/interval_color_badge.dart';

class RoutineEditorScreen extends ConsumerStatefulWidget {
  const RoutineEditorScreen({super.key});

  @override
  ConsumerState<RoutineEditorScreen> createState() =>
      _RoutineEditorScreenState();
}

class _RoutineEditorScreenState extends ConsumerState<RoutineEditorScreen> {
  String? _startError;

  Future<void> _showIntervalSheet({Interval? existing, int? index}) async {
    final editor = ref.read(routineEditorProvider.notifier);
    if (!editor.canEdit) return;

    // Brand work green (dark enough for white execution chrome) — never Theme
    // primary, which is light mint under dark mode and forces black timer text.
    final defaultColor = AppTheme.workColor.toARGB32();

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
          child: IntervalForm(
            initial: existing,
            defaultColorArgb: defaultColor,
            onSubmit: (result) async {
              final interval = existing?.copyWith(
                    name: result.name,
                    durationSeconds: result.durationSeconds,
                    colorArgb: result.colorArgb,
                    type: result.type,
                    announceText: result.announceText,
                  ) ??
                  editor.createNewInterval(
                    name: result.name,
                    durationSeconds: result.durationSeconds,
                    colorArgb: result.colorArgb,
                    type: result.type,
                    announceText: result.announceText,
                  );

              if (index != null) {
                await editor.updateInterval(index, interval);
              } else {
                await editor.addInterval(interval);
              }
              if (context.mounted) Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  Future<void> _startSession() async {
    final routineAsync = ref.read(routineEditorProvider);
    final routine = routineAsync.valueOrNull;
    if (routine == null || routine.items.isEmpty) {
      setState(() => _startError = context.l10n.emptyRoutineStart);
      return;
    }

    setState(() => _startError = null);
    ref.read(timerControllerProvider.notifier).bindRoutine(routine);
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
      setState(() => _startError = context.l10n.emptyRoutineStart);
    }
  }

  @override
  Widget build(BuildContext context) {
    final routineAsync = ref.watch(routineEditorProvider);
    final timerStatus = ref.watch(timerControllerProvider).status;
    final canEdit = timerStatus == TimerStatus.idle;

    ref.listen(routineEditorProvider, (_, next) {
      final routine = next.valueOrNull;
      if (routine == null) return;

      final activeWorkoutId = ref.read(activeWorkoutIdProvider).valueOrNull;
      final timerRoutine = ref.read(timerControllerProvider).routine;
      if (activeWorkoutId != null && timerRoutine?.id == activeWorkoutId) {
        return;
      }

      ref.read(timerControllerProvider.notifier).bindRoutine(routine);
    });

    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.routineTitle)),
      body: routineAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.persistenceError)),
        data: (routine) {
          if (routine.items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.emptyRoutineHint,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    AppPrimaryButton(
                      onPressed:
                          canEdit ? () => _showIntervalSheet() : null,
                      icon: Icons.add,
                      label: l10n.addInterval,
                    ),
                    if (_startError != null) ...[
                      const SizedBox(height: AppTheme.spacingMd),
                      Text(
                        _startError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  itemCount: routine.items.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppTheme.spacingSm),
                  itemBuilder: (context, index) {
                    final item = routine.items[index];
                    final interval = switch (item) {
                      IntervalRoutineItem(:final interval) => interval,
                    };

                    return Card(
                      child: ListTile(
                        onTap: canEdit
                            ? () => _showIntervalSheet(
                                  existing: interval,
                                  index: index,
                                )
                            : null,
                        title: IntervalColorBadge(
                          name: interval.name,
                          color: Color(interval.colorArgb),
                          durationLabel:
                              formatDurationMmSs(interval.durationSeconds),
                        ),
                        trailing: canEdit
                            ? IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => ref
                                    .read(routineEditorProvider.notifier)
                                    .removeInterval(index),
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
              if (_startError != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd,
                  ),
                  child: Text(
                    _startError!,
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
                      child: AppPrimaryButton(
                        onPressed:
                            canEdit ? () => _showIntervalSheet() : null,
                        icon: Icons.add,
                        label: l10n.addInterval,
                        expand: true,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMd),
                    Expanded(
                      child: AppPrimaryButton(
                        key: const Key('start_session_button'),
                        onPressed: _startSession,
                        label: l10n.startSession,
                        expand: true,
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
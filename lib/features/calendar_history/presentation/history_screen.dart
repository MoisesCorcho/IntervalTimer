import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/data/models/session_log.dart';
import 'package:interval_timer/data/repositories/routine_repository.dart';
import 'package:interval_timer/features/calendar_history/application/calendar_history_providers.dart';
import 'package:interval_timer/features/calendar_history/presentation/widgets/history_calendar.dart';
import 'package:interval_timer/features/calendar_history/presentation/widgets/history_month_header.dart';
import 'package:interval_timer/features/calendar_history/presentation/widgets/session_log_actions_sheet.dart';
import 'package:interval_timer/features/calendar_history/presentation/widgets/session_log_card.dart';
import 'package:interval_timer/features/calendar_history/presentation/widgets/session_note_editor.dart';
import 'package:interval_timer/features/settings/application/settings_providers.dart';
import 'package:interval_timer/features/settings/data/settings_repository.dart';
import 'package:interval_timer/features/body_tracking/presentation/body_weight_section.dart';
import 'package:interval_timer/features/stats/presentation/progress_summary_section.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';
import 'package:interval_timer/features/workout_builder/application/workout_providers.dart';
import 'package:interval_timer/features/workout_builder/domain/workout_flattener.dart';
import 'package:interval_timer/shared/widgets/app_primary_button.dart';
import 'package:interval_timer/shared/widgets/dialog_actions_row.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyControllerProvider);
    final logsAsync = ref.watch(sessionLogsForSelectedDayProvider);
    final markersAsync = ref.watch(sessionMarkerDatesProvider);
    final markers = markersAsync.valueOrNull ?? const <String>{};

    return Scaffold(
      key: const Key('history_screen'),
      body: SafeArea(
        child: ListView(
          key: const Key('history_scroll'),
          children: [
            // F12: progress block at top of History scroll (R1, R9)
            const ProgressSummarySection(),
            // F15: body weight section between progress and calendar (R2, R13)
            const BodyWeightSection(),
            // Calendar chrome (month + today) sits with the calendar, not at scroll top.
            HistoryMonthHeader(
              focusedMonth: history.focusedMonth,
              showGoToToday: !_isSameCalendarDay(
                history.selectedDate,
                DateTime.now(),
              ),
              onMonthSelected: (month) {
                ref
                    .read(historyControllerProvider.notifier)
                    .setFocusedMonth(month);
              },
              onGoToToday: () {
                ref.read(historyControllerProvider.notifier).goToToday();
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: HistoryCalendar(
                focusedMonth: history.focusedMonth,
                selectedDate: history.selectedDate,
                markerDates: markers,
                onDaySelected: (selected, focused) {
                  ref
                      .read(historyControllerProvider.notifier)
                      .selectDay(selected);
                },
                onPageChanged: (focused) {
                  ref
                      .read(historyControllerProvider.notifier)
                      .setFocusedMonth(focused);
                },
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                UiStrings.historyWorkoutsSection,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(height: 4),
            ..._sessionChildren(context, ref, logsAsync),
          ],
        ),
      ),
    );
  }

  static bool _isSameCalendarDay(DateTime a, DateTime b) {
    final al = a.toLocal();
    final bl = b.toLocal();
    return al.year == bl.year && al.month == bl.month && al.day == bl.day;
  }

  List<Widget> _sessionChildren(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<SessionLog>> logsAsync,
  ) {
    return logsAsync.when(
      loading: () => [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(
            child: CircularProgressIndicator(
              key: Key('history_loading'),
            ),
          ),
        ),
      ],
      error: (_, _) => [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Center(child: Text(UiStrings.persistenceError)),
        ),
      ],
      data: (logs) {
        if (logs.isEmpty) {
          return [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  key: Key('history_empty_day'),
                  UiStrings.historyEmptyDay,
                ),
              ),
            ),
          ];
        }
        return [
          KeyedSubtree(
            key: const Key('history_session_list'),
            child: Column(
              children: [
                for (final log in logs)
                  SessionLogCard(
                    log: log,
                    onOverflow: () => _onOverflow(context, ref, log),
                    onNoteTap: () => _onNote(context, ref, log),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ];
      },
    );
  }

  Future<void> _onNote(
    BuildContext context,
    WidgetRef ref,
    SessionLog log,
  ) async {
    final result = await showSessionNoteEditor(
      context: context,
      initialNote: log.note,
    );
    if (result == null || !context.mounted) return;

    try {
      await ref.read(sessionLogRepositoryProvider).updateNote(log.id, result);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(UiStrings.persistenceError),
          action: SnackBarAction(
            label: UiStrings.retry,
            onPressed: () => _onNote(context, ref, log),
          ),
        ),
      );
    }
  }

  Future<void> _onOverflow(
    BuildContext context,
    WidgetRef ref,
    SessionLog log,
  ) async {
    final action = await showSessionLogActionsSheet(context: context, log: log);
    if (action == null || !context.mounted) return;

    switch (action) {
      case SessionLogAction.start:
        await _startFromLog(context, ref, log);
      case SessionLogAction.delete:
        await _deleteLog(context, ref, log);
    }
  }

  Future<void> _startFromLog(
    BuildContext context,
    WidgetRef ref,
    SessionLog log,
  ) async {
    final workoutRepo = ref.read(workoutRepositoryProvider);
    final workout = await workoutRepo.getWorkout(log.sourceId);

    if (workout != null && workout.exercises.isNotEmpty) {
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
    } else if (log.sourceId == RoutineRepository.activeRoutineId ||
        workout == null) {
      final routine =
          await ref.read(routineRepositoryProvider).getActiveRoutine();
      if (routine.id != log.sourceId &&
          log.sourceId != RoutineRepository.activeRoutineId) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(UiStrings.historySourceMissing)),
          );
        }
        return;
      }
      if (routine.items.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(UiStrings.historySourceMissing)),
          );
        }
        return;
      }
      ref.read(timerControllerProvider.notifier).bindRoutine(routine);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(UiStrings.historySourceMissing)),
        );
      }
      return;
    }

    final prepSeconds = ref.read(settingsControllerProvider).valueOrNull
            ?.prepSeconds ??
        SettingsRepository.defaultPrepSeconds;
    final started = ref
        .read(timerControllerProvider.notifier)
        .start(prepSeconds: prepSeconds);
    if (!context.mounted) return;
    if (started) {
      context.go('/execute');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(UiStrings.historySourceMissing)),
      );
    }
  }

  Future<void> _deleteLog(
    BuildContext context,
    WidgetRef ref,
    SessionLog log,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(UiStrings.historyDeleteTitle),
        content: const Text(UiStrings.historyDeleteMessage),
        actions: [
          DialogActionsRow(
            children: [
              AppSecondaryButton(
                compact: true,
                onPressed: () => Navigator.pop(context, false),
                label: UiStrings.cancel,
              ),
              AppPrimaryButton(
                key: const Key('history_delete_confirm'),
                compact: true,
                onPressed: () => Navigator.pop(context, true),
                label: UiStrings.delete,
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(sessionLogRepositoryProvider).delete(log.id);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(UiStrings.persistenceError)),
      );
    }
  }
}

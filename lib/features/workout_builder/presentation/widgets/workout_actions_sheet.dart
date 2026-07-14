import 'package:flutter/material.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/data/models/workout.dart';

Future<WorkoutAction?> showWorkoutActionsSheet({
  required BuildContext context,
  required Workout workout,
}) {
  return showModalBottomSheet<WorkoutAction>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return WorkoutActionsSheet(workout: workout);
    },
  );
}

enum WorkoutAction { train, edit, duplicate, delete }

class WorkoutActionsSheet extends StatelessWidget {
  const WorkoutActionsSheet({super.key, required this.workout});

  final Workout workout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final countLabel = UiStrings.exerciseCountLabel.replaceAll(
      '{count}',
      '${workout.exercises.length}',
    );

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                key: const Key('workout_sheet_header'),
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(workout.name, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      countLabel,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                key: const Key('workout_sheet_train'),
                leading: const Icon(Icons.play_arrow),
                title: const Text(UiStrings.train),
                onTap: () => Navigator.pop(context, WorkoutAction.train),
              ),
              ListTile(
                key: const Key('workout_sheet_edit'),
                leading: const Icon(Icons.edit_outlined),
                title: const Text(UiStrings.edit),
                onTap: () => Navigator.pop(context, WorkoutAction.edit),
              ),
              ListTile(
                key: const Key('workout_sheet_duplicate'),
                leading: const Icon(Icons.copy_outlined),
                title: const Text(UiStrings.duplicate),
                onTap: () => Navigator.pop(context, WorkoutAction.duplicate),
              ),
              ListTile(
                key: const Key('workout_sheet_delete'),
                leading: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.error,
                ),
                title: Text(
                  UiStrings.delete,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                onTap: () => Navigator.pop(context, WorkoutAction.delete),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

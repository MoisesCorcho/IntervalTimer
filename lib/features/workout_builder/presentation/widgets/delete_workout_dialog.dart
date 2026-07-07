import 'package:flutter/material.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';

Future<bool?> showDeleteWorkoutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text(UiStrings.deleteWorkoutTitle),
      content: const Text(UiStrings.deleteWorkoutMessage),
      actions: [
        TextButton(
          key: const Key('delete_workout_cancel'),
          onPressed: () => Navigator.pop(context, false),
          child: const Text(UiStrings.cancel),
        ),
        FilledButton(
          key: const Key('delete_workout_confirm'),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          onPressed: () => Navigator.pop(context, true),
          child: const Text(UiStrings.delete),
        ),
      ],
    ),
  );
}
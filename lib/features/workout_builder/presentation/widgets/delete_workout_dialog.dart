import 'package:flutter/material.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/shared/widgets/app_primary_button.dart';
import 'package:interval_timer/shared/widgets/dialog_actions_row.dart';

Future<bool?> showDeleteWorkoutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      final colorScheme = Theme.of(context).colorScheme;
      return AlertDialog(
        title: const Text(UiStrings.deleteWorkoutTitle),
        content: const Text(UiStrings.deleteWorkoutMessage),
        actions: [
          DialogActionsRow(
            children: [
              AppSecondaryButton(
                key: const Key('delete_workout_cancel'),
                compact: true,
                onPressed: () => Navigator.pop(context, false),
                label: UiStrings.cancel,
              ),
              AppPrimaryButton(
                key: const Key('delete_workout_confirm'),
                compact: true,
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
                onPressed: () => Navigator.pop(context, true),
                label: UiStrings.delete,
              ),
            ],
          ),
        ],
      );
    },
  );
}
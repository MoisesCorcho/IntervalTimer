import 'package:flutter/material.dart';
import 'package:interval_timer/core/l10n/l10n_extension.dart';
import 'package:interval_timer/shared/widgets/app_primary_button.dart';
import 'package:interval_timer/shared/widgets/dialog_actions_row.dart';

Future<bool?> showDeleteWorkoutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      final colorScheme = Theme.of(context).colorScheme;
      final l10n = context.l10n;
      return AlertDialog(
        title: Text(l10n.deleteWorkoutTitle),
        content: Text(l10n.deleteWorkoutMessage),
        actions: [
          DialogActionsRow(
            children: [
              AppSecondaryButton(
                key: const Key('delete_workout_cancel'),
                compact: true,
                onPressed: () => Navigator.pop(context, false),
                label: l10n.cancel,
              ),
              AppPrimaryButton(
                key: const Key('delete_workout_confirm'),
                compact: true,
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
                onPressed: () => Navigator.pop(context, true),
                label: l10n.delete,
              ),
            ],
          ),
        ],
      );
    },
  );
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/core/l10n/l10n_extension.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/features/body_tracking/domain/weight_unit.dart';
import 'package:interval_timer/features/settings/application/settings_providers.dart';
import 'package:interval_timer/features/settings/domain/app_settings.dart';

/// Settings block for body weight unit kg/lb (F15 R8).
class BodyWeightUnitSettingsSection extends ConsumerWidget {
  const BodyWeightUnitSettingsSection({super.key, required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Column(
      key: const Key('body_weight_unit_settings'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.bodyWeightUnitsSectionTitle,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Text(
          l10n.bodyWeightUnitPreferenceLabel,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppTheme.spacingSm),
        SegmentedButton<BodyWeightUnit>(
          key: const Key('body_weight_unit_segmented'),
          segments: [
            ButtonSegment<BodyWeightUnit>(
              value: BodyWeightUnit.kg,
              label: Text(l10n.bodyWeightUnitKg),
            ),
            ButtonSegment<BodyWeightUnit>(
              value: BodyWeightUnit.lb,
              label: Text(l10n.bodyWeightUnitLb),
            ),
          ],
          selected: {settings.bodyWeightUnit},
          onSelectionChanged: (selected) {
            ref
                .read(settingsControllerProvider.notifier)
                .setBodyWeightUnit(selected.first);
          },
        ),
      ],
    );
  }
}

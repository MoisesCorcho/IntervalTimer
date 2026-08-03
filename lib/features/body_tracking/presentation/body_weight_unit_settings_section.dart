import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
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

    return Column(
      key: const Key('body_weight_unit_settings'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          UiStrings.bodyWeightUnitsSectionTitle,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Text(
          UiStrings.bodyWeightUnitPreferenceLabel,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppTheme.spacingSm),
        SegmentedButton<BodyWeightUnit>(
          key: const Key('body_weight_unit_segmented'),
          segments: const [
            ButtonSegment<BodyWeightUnit>(
              value: BodyWeightUnit.kg,
              label: Text(UiStrings.bodyWeightUnitKg),
            ),
            ButtonSegment<BodyWeightUnit>(
              value: BodyWeightUnit.lb,
              label: Text(UiStrings.bodyWeightUnitLb),
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

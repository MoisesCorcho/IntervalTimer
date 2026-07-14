import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/features/settings/application/settings_providers.dart';
import 'package:interval_timer/features/settings/data/settings_repository.dart';
import 'package:interval_timer/features/settings/domain/app_settings.dart';
import 'package:interval_timer/shared/widgets/number_stepper.dart';

/// Settings block for F18 vibration preferences (composed into [SettingsScreen]).
class VibrationSettingsSection extends ConsumerWidget {
  const VibrationSettingsSection({super.key, required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final masterOn = settings.vibrationEnabled;
    final controller = ref.read(settingsControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          UiStrings.vibrationSectionTitle,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: AppTheme.spacingMd),
        SwitchListTile(
          key: const Key('vibration_enabled_switch'),
          contentPadding: EdgeInsets.zero,
          title: const Text(UiStrings.vibrationEnabledLabel),
          subtitle: Text(UiStrings.vibrationEnabledHint, style: muted),
          value: settings.vibrationEnabled,
          onChanged: controller.setVibrationEnabled,
        ),
        const SizedBox(height: AppTheme.spacingSm),
        SwitchListTile(
          key: const Key('vibration_on_interval_start_switch'),
          contentPadding: EdgeInsets.zero,
          title: const Text(UiStrings.vibrationOnIntervalStartLabel),
          subtitle:
              Text(UiStrings.vibrationOnIntervalStartHint, style: muted),
          value: settings.vibrationOnIntervalStart,
          onChanged: masterOn ? controller.setVibrationOnIntervalStart : null,
        ),
        const SizedBox(height: AppTheme.spacingSm),
        SwitchListTile(
          key: const Key('vibration_on_countdown_switch'),
          contentPadding: EdgeInsets.zero,
          title: const Text(UiStrings.vibrationOnCountdownLabel),
          subtitle: Text(UiStrings.vibrationOnCountdownHint, style: muted),
          value: settings.vibrationOnCountdown,
          onChanged: masterOn ? controller.setVibrationOnCountdown : null,
        ),
        const SizedBox(height: AppTheme.spacingMd),
        Text(
          UiStrings.vibrationCountdownSecondsLabel,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Text(UiStrings.vibrationCountdownSecondsHint, style: muted),
        const SizedBox(height: AppTheme.spacingMd),
        Opacity(
          opacity: masterOn ? 1 : 0.5,
          child: IgnorePointer(
            ignoring: !masterOn,
            child: NumberStepper(
              key: const Key('vibration_countdown_seconds_stepper'),
              value: settings.vibrationCountdownSeconds,
              min: SettingsRepository.minVibrationCountdownSeconds,
              max: SettingsRepository.maxVibrationCountdownSeconds,
              step: 1,
              label: UiStrings.vibrationCountdownSecondsLabel,
              keyPrefix: 'vibration_countdown_',
              onChanged: controller.setVibrationCountdownSeconds,
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/core/l10n/l10n_extension.dart';
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
    final l10n = context.l10n;
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
          l10n.vibrationSectionTitle,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: AppTheme.spacingMd),
        SwitchListTile(
          key: const Key('vibration_enabled_switch'),
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.vibrationEnabledLabel),
          subtitle: Text(l10n.vibrationEnabledHint, style: muted),
          value: settings.vibrationEnabled,
          onChanged: controller.setVibrationEnabled,
        ),
        const SizedBox(height: AppTheme.spacingSm),
        SwitchListTile(
          key: const Key('vibration_on_interval_start_switch'),
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.vibrationOnIntervalStartLabel),
          subtitle:
              Text(l10n.vibrationOnIntervalStartHint, style: muted),
          value: settings.vibrationOnIntervalStart,
          onChanged: masterOn ? controller.setVibrationOnIntervalStart : null,
        ),
        const SizedBox(height: AppTheme.spacingSm),
        SwitchListTile(
          key: const Key('vibration_on_countdown_switch'),
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.vibrationOnCountdownLabel),
          subtitle: Text(l10n.vibrationOnCountdownHint, style: muted),
          value: settings.vibrationOnCountdown,
          onChanged: masterOn ? controller.setVibrationOnCountdown : null,
        ),
        const SizedBox(height: AppTheme.spacingMd),
        Text(
          l10n.vibrationCountdownSecondsLabel,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Text(l10n.vibrationCountdownSecondsHint, style: muted),
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
              label: l10n.vibrationCountdownSecondsLabel,
              keyPrefix: 'vibration_countdown_',
              onChanged: controller.setVibrationCountdownSeconds,
            ),
          ),
        ),
      ],
    );
  }
}

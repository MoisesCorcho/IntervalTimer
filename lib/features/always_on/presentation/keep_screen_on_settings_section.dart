import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/features/settings/application/settings_providers.dart';
import 'package:interval_timer/features/settings/domain/app_settings.dart';

/// Settings block for F19 keep-screen-on preference (composed into SettingsScreen).
class KeepScreenOnSettingsSection extends ConsumerWidget {
  const KeepScreenOnSettingsSection({super.key, required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          UiStrings.keepScreenOnSectionTitle,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: AppTheme.spacingMd),
        SwitchListTile(
          key: const Key('keep_screen_on_enabled_switch'),
          contentPadding: EdgeInsets.zero,
          title: const Text(UiStrings.keepScreenOnEnabledLabel),
          subtitle: Text(UiStrings.keepScreenOnEnabledHint, style: muted),
          value: settings.keepScreenOnEnabled,
          onChanged: (value) {
            ref
                .read(settingsControllerProvider.notifier)
                .setKeepScreenOnEnabled(value);
          },
        ),
      ],
    );
  }
}

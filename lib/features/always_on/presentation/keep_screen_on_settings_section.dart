import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/core/l10n/l10n_extension.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/features/settings/application/settings_providers.dart';
import 'package:interval_timer/features/settings/domain/app_settings.dart';

/// Settings block for F19 keep-screen-on preference (composed into SettingsScreen).
class KeepScreenOnSettingsSection extends ConsumerWidget {
  const KeepScreenOnSettingsSection({super.key, required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.keepScreenOnSectionTitle,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: AppTheme.spacingMd),
        SwitchListTile(
          key: const Key('keep_screen_on_enabled_switch'),
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.keepScreenOnEnabledLabel),
          subtitle: Text(l10n.keepScreenOnEnabledHint, style: muted),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/core/l10n/l10n_extension.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/features/settings/application/settings_providers.dart';
import 'package:interval_timer/features/settings/domain/app_language.dart';
import 'package:interval_timer/features/settings/domain/app_settings.dart';

/// Language selection UI section in Settings (F28 R3, R8).
class LanguageSelectorSection extends ConsumerWidget {
  const LanguageSelectorSection({required this.settings, super.key});

  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final label = l10n.languageLabel;
    final autoLabel = l10n.languageAuto;
    const esLabel = 'Español';
    const enLabel = 'English';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppTheme.spacingSm),
        SegmentedButton<AppLanguage>(
          key: const Key('language_segmented_button'),
          segments: [
            ButtonSegment<AppLanguage>(
              value: AppLanguage.system,
              label: Text(autoLabel),
              icon: const Icon(Icons.language),
            ),
            ButtonSegment<AppLanguage>(
              value: AppLanguage.es,
              label: Text(esLabel),
            ),
            ButtonSegment<AppLanguage>(
              value: AppLanguage.en,
              label: Text(enLabel),
            ),
          ],
          selected: {settings.appLanguage},
          onSelectionChanged: (selected) {
            ref
                .read(settingsControllerProvider.notifier)
                .setAppLanguage(selected.first);
          },
        ),
      ],
    );
  }
}

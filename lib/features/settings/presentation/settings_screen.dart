import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/features/settings/application/settings_providers.dart';
import 'package:interval_timer/features/settings/data/settings_repository.dart';
import 'package:interval_timer/shared/widgets/app_primary_button.dart';
import 'package:interval_timer/shared/widgets/number_stepper.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(UiStrings.settingsTitle),
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  UiStrings.persistenceError,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingMd),
                AppPrimaryButton(
                  onPressed: () => ref.invalidate(settingsControllerProvider),
                  label: UiStrings.retry,
                ),
              ],
            ),
          ),
        ),
        data: (settings) {
          return ListView(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            children: [
              Text(
                UiStrings.prepSecondsLabel,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                UiStrings.prepSecondsHint,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              NumberStepper(
                key: const Key('prep_seconds_stepper'),
                value: settings.prepSeconds,
                min: SettingsRepository.minPrepSeconds,
                max: SettingsRepository.maxPrepSeconds,
                step: 1,
                label: UiStrings.prepSecondsLabel,
                keyPrefix: 'prep_',
                onChanged: (value) {
                  ref
                      .read(settingsControllerProvider.notifier)
                      .setPrepSeconds(value);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

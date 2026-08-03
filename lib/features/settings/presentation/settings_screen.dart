import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/features/settings/application/settings_providers.dart';
import 'package:interval_timer/features/settings/data/settings_repository.dart';
import 'package:interval_timer/features/settings/domain/app_settings.dart';
import 'package:interval_timer/features/settings/domain/app_theme_mode.dart';
import 'package:interval_timer/features/always_on/presentation/keep_screen_on_settings_section.dart';
import 'package:interval_timer/features/lock_screen/presentation/session_lock_screen_settings_section.dart';
import 'package:interval_timer/features/sound_effects/presentation/sound_effects_settings_section.dart';
import 'package:interval_timer/features/vibration/presentation/vibration_settings_section.dart';
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
        data: (settings) => _SettingsBody(settings: settings),
      ),
    );
  }
}

class _SettingsBody extends ConsumerWidget {
  const _SettingsBody({required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return ListView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      children: [
        Text(
          UiStrings.themeLabel,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppTheme.spacingSm),
        SegmentedButton<AppThemeMode>(
          key: const Key('theme_segmented_button'),
          segments: const [
            ButtonSegment<AppThemeMode>(
              value: AppThemeMode.light,
              label: Text(UiStrings.themeLight),
              icon: Icon(Icons.light_mode),
            ),
            ButtonSegment<AppThemeMode>(
              value: AppThemeMode.dark,
              label: Text(UiStrings.themeDark),
              icon: Icon(Icons.dark_mode),
            ),
            ButtonSegment<AppThemeMode>(
              value: AppThemeMode.system,
              label: Text(UiStrings.themeSystem),
              icon: Icon(Icons.settings_brightness),
            ),
          ],
          selected: {settings.themeMode},
          onSelectionChanged: (selected) {
            ref
                .read(settingsControllerProvider.notifier)
                .setThemeMode(selected.first);
          },
        ),
        const SizedBox(height: AppTheme.spacingLg),
        Text(
          UiStrings.prepSecondsLabel,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Text(UiStrings.prepSecondsHint, style: muted),
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
            ref.read(settingsControllerProvider.notifier).setPrepSeconds(value);
          },
        ),
        const SizedBox(height: AppTheme.spacingLg),
        Text(
          UiStrings.voiceSectionTitle,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: AppTheme.spacingMd),
        SwitchListTile(
          key: const Key('voice_enabled_switch'),
          contentPadding: EdgeInsets.zero,
          title: const Text(UiStrings.voiceEnabledLabel),
          subtitle: Text(UiStrings.voiceEnabledHint, style: muted),
          value: settings.voiceEnabled,
          onChanged: (value) {
            ref
                .read(settingsControllerProvider.notifier)
                .setVoiceEnabled(value);
          },
        ),
        const SizedBox(height: AppTheme.spacingSm),
        SwitchListTile(
          key: const Key('announce_interval_name_switch'),
          contentPadding: EdgeInsets.zero,
          title: const Text(UiStrings.announceIntervalNameLabel),
          subtitle: Text(UiStrings.announceIntervalNameHint, style: muted),
          value: settings.announceIntervalName,
          onChanged: settings.voiceEnabled
              ? (value) {
                  ref
                      .read(settingsControllerProvider.notifier)
                      .setAnnounceIntervalName(value);
                }
              : null,
        ),
        const SizedBox(height: AppTheme.spacingMd),
        Text(
          UiStrings.countdownSecondsLabel,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Text(UiStrings.countdownSecondsHint, style: muted),
        const SizedBox(height: AppTheme.spacingMd),
        NumberStepper(
          key: const Key('countdown_seconds_stepper'),
          value: settings.countdownSeconds,
          min: SettingsRepository.minCountdownSeconds,
          max: SettingsRepository.maxCountdownSeconds,
          step: 1,
          label: UiStrings.countdownSecondsLabel,
          keyPrefix: 'countdown_',
          onChanged: (value) {
            ref
                .read(settingsControllerProvider.notifier)
                .setCountdownSeconds(value);
          },
        ),
        const SizedBox(height: AppTheme.spacingLg),
        VibrationSettingsSection(settings: settings),
        const SizedBox(height: AppTheme.spacingLg),
        SoundEffectsSettingsSection(settings: settings),
        const SizedBox(height: AppTheme.spacingLg),
        KeepScreenOnSettingsSection(settings: settings),
        const SizedBox(height: AppTheme.spacingLg),
        SessionLockScreenSettingsSection(settings: settings),
      ],
    );
  }
}

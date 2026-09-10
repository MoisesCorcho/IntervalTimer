import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/core/l10n/l10n_extension.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/core/utils/contrast_text_color.dart';
import 'package:interval_timer/features/settings/application/settings_providers.dart';
import 'package:interval_timer/features/settings/data/settings_repository.dart';
import 'package:interval_timer/features/settings/domain/app_settings.dart';
import 'package:interval_timer/features/settings/domain/app_theme_mode.dart';
import 'package:interval_timer/features/always_on/presentation/keep_screen_on_settings_section.dart';
import 'package:interval_timer/features/body_tracking/presentation/body_weight_unit_settings_section.dart';
import 'package:interval_timer/features/lock_screen/presentation/session_lock_screen_settings_section.dart';
import 'package:interval_timer/features/settings/presentation/phase_color_picker_screen.dart';
import 'package:interval_timer/features/settings/presentation/widgets/language_selector_tile.dart';
import 'package:interval_timer/features/settings/presentation/widgets/settings_section_card.dart';
import 'package:interval_timer/features/sound_effects/presentation/sound_effects_settings_section.dart';
import 'package:interval_timer/features/vibration/presentation/vibration_settings_section.dart';
import 'package:interval_timer/shared/widgets/app_primary_button.dart';
import 'package:interval_timer/shared/widgets/number_stepper.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsControllerProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
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
                  l10n.persistenceError,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingMd),
                AppPrimaryButton(
                  onPressed: () => ref.invalidate(settingsControllerProvider),
                  label: l10n.retry,
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
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingMd,
      ),
      children: [
        // 1. General & Appearance
        SettingsSectionCard(
          key: const Key('settings_card_appearance'),
          icon: Icons.palette_outlined,
          title: l10n.themeLabel,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<AppThemeMode>(
                key: const Key('theme_segmented_button'),
                segments: [
                  ButtonSegment<AppThemeMode>(
                    value: AppThemeMode.light,
                    label: Text(l10n.themeLight),
                    icon: const Icon(Icons.light_mode),
                  ),
                  ButtonSegment<AppThemeMode>(
                    value: AppThemeMode.dark,
                    label: Text(l10n.themeDark),
                    icon: const Icon(Icons.dark_mode),
                  ),
                  ButtonSegment<AppThemeMode>(
                    value: AppThemeMode.system,
                    label: Text(l10n.themeSystem),
                    icon: const Icon(Icons.settings_brightness),
                  ),
                ],
                selected: {settings.themeMode},
                onSelectionChanged: (selected) {
                  ref
                      .read(settingsControllerProvider.notifier)
                      .setThemeMode(selected.first);
                },
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Divider(
                height: 1,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              _ThemeAccentColorSection(settings: settings),
              const SizedBox(height: AppTheme.spacingMd),
              Divider(
                height: 1,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              LanguageSelectorSection(settings: settings),
              const SizedBox(height: AppTheme.spacingMd),
              Divider(
                height: 1,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              BodyWeightUnitSettingsSection(settings: settings),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacingMd),

        // 2. Timer & Phase Configuration
        SettingsSectionCard(
          key: const Key('settings_card_timer'),
          icon: Icons.timer_outlined,
          title: l10n.prepSecondsLabel,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.prepSecondsHint, style: muted),
              const SizedBox(height: AppTheme.spacingSm),
              NumberStepper(
                key: const Key('prep_seconds_stepper'),
                value: settings.prepSeconds,
                min: SettingsRepository.minPrepSeconds,
                max: SettingsRepository.maxPrepSeconds,
                step: 1,
                label: l10n.prepSecondsLabel,
                keyPrefix: 'prep_',
                onChanged: (value) {
                  ref
                      .read(settingsControllerProvider.notifier)
                      .setPrepSeconds(value);
                },
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Divider(
                height: 1,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              _TimerPhaseColorsSection(settings: settings),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacingMd),

        // 3. Voice Assistant
        SettingsSectionCard(
          key: const Key('settings_card_voice'),
          icon: Icons.record_voice_over_outlined,
          title: l10n.voiceSectionTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SwitchListTile(
                key: const Key('voice_enabled_switch'),
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.voiceEnabledLabel),
                subtitle: Text(l10n.voiceEnabledHint, style: muted),
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
                title: Text(l10n.announceIntervalNameLabel),
                subtitle: Text(l10n.announceIntervalNameHint, style: muted),
                value: settings.announceIntervalName,
                onChanged: settings.voiceEnabled
                    ? (value) {
                        ref
                            .read(settingsControllerProvider.notifier)
                            .setAnnounceIntervalName(value);
                      }
                    : null,
              ),
              const SizedBox(height: AppTheme.spacingSm),
              SwitchListTile(
                key: const Key('music_ducking_switch'),
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.musicDuckingLabel),
                subtitle: Text(l10n.musicDuckingHint, style: muted),
                value: settings.musicDuckingEnabled,
                onChanged: settings.voiceEnabled
                    ? (value) {
                        ref
                            .read(settingsControllerProvider.notifier)
                            .setMusicDuckingEnabled(value);
                      }
                    : null,
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Divider(
                height: 1,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Text(
                l10n.countdownSecondsLabel,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Text(l10n.countdownSecondsHint, style: muted),
              const SizedBox(height: AppTheme.spacingMd),
              NumberStepper(
                key: const Key('countdown_seconds_stepper'),
                value: settings.countdownSeconds,
                min: SettingsRepository.minCountdownSeconds,
                max: SettingsRepository.maxCountdownSeconds,
                step: 1,
                label: l10n.countdownSecondsLabel,
                keyPrefix: 'countdown_',
                onChanged: (value) {
                  ref
                      .read(settingsControllerProvider.notifier)
                      .setCountdownSeconds(value);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacingMd),

        // 4. Sound Effects
        SettingsSectionCard(
          key: const Key('settings_card_sound_effects'),
          child: SoundEffectsSettingsSection(settings: settings),
        ),
        const SizedBox(height: AppTheme.spacingMd),

        // 5. Vibration & Haptics
        SettingsSectionCard(
          key: const Key('settings_card_vibration'),
          child: VibrationSettingsSection(settings: settings),
        ),
        const SizedBox(height: AppTheme.spacingMd),

        // 6. Screen & Session Lock Controls
        SettingsSectionCard(
          key: const Key('settings_card_screen_session'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              KeepScreenOnSettingsSection(settings: settings),
              const SizedBox(height: AppTheme.spacingMd),
              Divider(
                height: 1,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              SessionLockScreenSettingsSection(settings: settings),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimerPhaseColorsSection extends ConsumerWidget {
  const _TimerPhaseColorsSection({required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final controller = ref.read(settingsControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.timerColorsSectionTitle,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppTheme.spacingSm),
        ListTile(
          key: const Key('work_color_tile'),
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.workColorTitle),
          subtitle: Text(
            l10n.workColorSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          trailing: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Color(settings.workColorArgb),
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: AppTheme.buttonShadowFor(context),
            ),
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PhaseColorPickerScreen(
                  title: l10n.workColorTitle,
                  initialColor: Color(settings.workColorArgb),
                  defaultColor: AppTheme.workColor,
                  onColorSelected: (c) => controller.setWorkColor(c.toARGB32()),
                ),
              ),
            );
          },
        ),
        ListTile(
          key: const Key('rest_color_tile'),
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.restColorTitle),
          subtitle: Text(
            l10n.restColorSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          trailing: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Color(settings.restColorArgb),
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: AppTheme.buttonShadowFor(context),
            ),
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PhaseColorPickerScreen(
                  title: l10n.restColorTitle,
                  initialColor: Color(settings.restColorArgb),
                  defaultColor: AppTheme.restColor,
                  onColorSelected: (c) => controller.setRestColor(c.toARGB32()),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ThemeAccentColorSection extends ConsumerWidget {
  const _ThemeAccentColorSection({required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.themeAccentColorLabel,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.spacingXs),
        Text(
          l10n.themeAccentColorHint,
          style: muted,
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Wrap(
          key: const Key('settings_accent_color_selector'),
          spacing: 8,
          runSpacing: 8,
          children: AppTheme.accentColorPresets.map((color) {
            final isSelected = settings.themeColorArgb == color.toARGB32();
            final checkColor = contrastTextColor(color);

            return Semantics(
              label: 'Accent color ${color.toARGB32()}',
              selected: isSelected,
              button: true,
              child: InkWell(
                key: Key('accent_color_swatch_${color.toARGB32()}'),
                onTap: () {
                  ref
                      .read(settingsControllerProvider.notifier)
                      .setThemeColor(color.toARGB32());
                },
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(
                            color: theme.colorScheme.primary,
                            width: 2.5,
                          )
                        : null,
                  ),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: AppTheme.buttonShadowFor(context),
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            size: 18,
                            color: checkColor,
                          )
                        : null,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

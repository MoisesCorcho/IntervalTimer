import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/core/l10n/l10n_extension.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/features/settings/application/settings_providers.dart';
import 'package:interval_timer/shared/widgets/app_modal_bottom_sheet.dart';

/// Shows the [TimerAudioControlsSheet] using the canonical [showAppModalBottomSheet].
Future<void> showTimerAudioControlsSheet(BuildContext context) {
  return showAppModalBottomSheet<void>(
    context: context,
    builder: (ctx) => const TimerAudioControlsSheet(),
  );
}

/// Quick controls sheet allowing users to toggle voice, sound effects, and
/// vibration during an active timer session without leaving or restarting the workout.
class TimerAudioControlsSheet extends ConsumerWidget {
  const TimerAudioControlsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsControllerProvider);
    final settings = settingsAsync.valueOrNull;
    final l10n = context.l10n;

    if (settings == null) {
      return const SizedBox(
        height: 140,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final allMuted = !settings.voiceEnabled &&
        !settings.soundEnabled &&
        !settings.vibrationEnabled;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.quickAudioSettings,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          SwitchListTile.adaptive(
            key: const Key('timer_voice_switch'),
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.record_voice_over),
            title: Text(l10n.voiceAnnouncements),
            subtitle: Text(l10n.voiceAnnouncementsDesc),
            value: settings.voiceEnabled,
            onChanged: (val) {
              ref.read(settingsControllerProvider.notifier).setVoiceEnabled(val);
            },
          ),
          SwitchListTile.adaptive(
            key: const Key('timer_sound_switch'),
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.music_note),
            title: Text(l10n.soundEffects),
            subtitle: Text(l10n.soundEffectsDesc),
            value: settings.soundEnabled,
            onChanged: (val) {
              ref.read(settingsControllerProvider.notifier).setSoundEnabled(val);
            },
          ),
          SwitchListTile.adaptive(
            key: const Key('timer_vibration_switch'),
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.vibration),
            title: Text(l10n.vibrationFeedback),
            subtitle: Text(l10n.vibrationFeedbackDesc),
            value: settings.vibrationEnabled,
            onChanged: (val) {
              ref.read(settingsControllerProvider.notifier).setVibrationEnabled(val);
            },
          ),
          const SizedBox(height: AppTheme.spacingMd),
          OutlinedButton.icon(
            key: const Key('timer_toggle_all_audio_button'),
            icon: Icon(allMuted ? Icons.volume_up : Icons.volume_off),
            label: Text(allMuted ? l10n.unmuteAll : l10n.muteAll),
            onPressed: () {
              final target = allMuted;
              final notifier = ref.read(settingsControllerProvider.notifier);
              notifier.setVoiceEnabled(target);
              notifier.setSoundEnabled(target);
              notifier.setVibrationEnabled(target);
            },
          ),
        ],
      ),
    );
  }
}

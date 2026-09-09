import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/core/l10n/l10n_extension.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/features/settings/application/settings_providers.dart';
import 'package:interval_timer/features/settings/data/settings_repository.dart';
import 'package:interval_timer/features/settings/domain/app_settings.dart';
import 'package:interval_timer/features/sound_effects/application/sound_effects_providers.dart';
import 'package:interval_timer/features/sound_effects/domain/sfx_catalog.dart';
import 'package:interval_timer/features/sound_effects/domain/sfx_slot.dart';
import 'package:interval_timer/shared/widgets/number_stepper.dart';

/// Settings block for F36 SFX preferences (composed into [SettingsScreen]).
class SoundEffectsSettingsSection extends ConsumerWidget {
  const SoundEffectsSettingsSection({super.key, required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final masterOn = settings.soundEnabled;
    final controller = ref.read(settingsControllerProvider.notifier);
    final catalog = ref.watch(sfxCatalogProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.soundSectionTitle,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: AppTheme.spacingMd),
        SwitchListTile(
          key: const Key('sound_enabled_switch'),
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.soundEnabledLabel),
          subtitle: Text(l10n.soundEnabledHint, style: muted),
          value: settings.soundEnabled,
          onChanged: controller.setSoundEnabled,
        ),
        const SizedBox(height: AppTheme.spacingSm),
        SwitchListTile(
          key: const Key('sound_on_work_start_switch'),
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.soundOnWorkStartLabel),
          subtitle: Text(l10n.soundOnWorkStartHint, style: muted),
          value: settings.soundOnWorkStart,
          onChanged: masterOn ? controller.setSoundOnWorkStart : null,
        ),
        SwitchListTile(
          key: const Key('sound_on_rest_start_switch'),
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.soundOnRestStartLabel),
          subtitle: Text(l10n.soundOnRestStartHint, style: muted),
          value: settings.soundOnRestStart,
          onChanged: masterOn ? controller.setSoundOnRestStart : null,
        ),
        SwitchListTile(
          key: const Key('sound_on_session_complete_switch'),
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.soundOnSessionCompleteLabel),
          subtitle: Text(l10n.soundOnSessionCompleteHint, style: muted),
          value: settings.soundOnSessionComplete,
          onChanged: masterOn ? controller.setSoundOnSessionComplete : null,
        ),
        SwitchListTile(
          key: const Key('sound_on_prep_tick_switch'),
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.soundOnPrepTickLabel),
          subtitle: Text(l10n.soundOnPrepTickHint, style: muted),
          value: settings.soundOnPrepTick,
          onChanged: masterOn ? controller.setSoundOnPrepTick : null,
        ),
        SwitchListTile(
          key: const Key('sound_on_phase_warning_switch'),
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.soundOnPhaseWarningLabel),
          subtitle: Text(l10n.soundOnPhaseWarningHint, style: muted),
          value: settings.soundOnPhaseWarning,
          onChanged: masterOn ? controller.setSoundOnPhaseWarning : null,
        ),
        const SizedBox(height: AppTheme.spacingMd),
        Text(
          l10n.soundCountdownSecondsLabel,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Text(l10n.soundCountdownSecondsHint, style: muted),
        const SizedBox(height: AppTheme.spacingMd),
        Opacity(
          opacity: masterOn && settings.soundOnPhaseWarning ? 1 : 0.5,
          child: IgnorePointer(
            ignoring: !masterOn || !settings.soundOnPhaseWarning,
            child: NumberStepper(
              key: const Key('sound_countdown_seconds_stepper'),
              value: settings.soundCountdownSeconds,
              min: SettingsRepository.minSoundCountdownSeconds,
              max: SettingsRepository.maxSoundCountdownSeconds,
              step: 1,
              label: l10n.soundCountdownSecondsLabel,
              keyPrefix: 'sound_countdown_',
              onChanged: controller.setSoundCountdownSeconds,
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingLg),
        Text(
          l10n.soundClipLabel,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppTheme.spacingSm),
        _SoundSlotRow(
          slot: SfxSlot.workStart,
          label: l10n.soundSlotWorkStart,
          soundId: settings.soundIdWorkStart,
          catalog: catalog,
          onSelected: controller.setSoundIdWorkStart,
        ),
        _SoundSlotRow(
          slot: SfxSlot.restStart,
          label: l10n.soundSlotRestStart,
          soundId: settings.soundIdRestStart,
          catalog: catalog,
          onSelected: controller.setSoundIdRestStart,
        ),
        _SoundSlotRow(
          slot: SfxSlot.sessionComplete,
          label: l10n.soundSlotSessionComplete,
          soundId: settings.soundIdSessionComplete,
          catalog: catalog,
          onSelected: controller.setSoundIdSessionComplete,
        ),
        _SoundSlotRow(
          slot: SfxSlot.prepTick,
          label: l10n.soundSlotPrepTick,
          soundId: settings.soundIdPrepTick,
          catalog: catalog,
          onSelected: controller.setSoundIdPrepTick,
        ),
        _SoundSlotRow(
          slot: SfxSlot.phaseWarning,
          label: l10n.soundSlotPhaseWarning,
          soundId: settings.soundIdPhaseWarning,
          catalog: catalog,
          onSelected: controller.setSoundIdPhaseWarning,
        ),
      ],
    );
  }
}

class _SoundSlotRow extends ConsumerWidget {
  const _SoundSlotRow({
    required this.slot,
    required this.label,
    required this.soundId,
    required this.catalog,
    required this.onSelected,
  });

  final SfxSlot slot;
  final String label;
  final String soundId;
  final SfxCatalog catalog;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final resolved = catalog.resolveOrDefault(soundId, slot);

    return ListTile(
      key: Key('sound_slot_${slot.name}'),
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(
        resolved.id,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            key: Key('sound_preview_${slot.name}'),
            tooltip: l10n.soundPreviewClip,
            icon: const Icon(Icons.play_arrow),
            onPressed: () {
              ref
                  .read(soundEffectsControllerProvider)
                  .previewSoundId(resolved.id);
            },
          ),
          TextButton(
            key: Key('sound_change_${slot.name}'),
            onPressed: () => _openPicker(context, ref),
            child: Text(l10n.soundChangeClip),
          ),
        ],
      ),
    );
  }

  Future<void> _openPicker(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  child: Text(
                    l10n.soundPickClipTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: catalog.all.length,
                    itemBuilder: (context, index) {
                      final entry = catalog.all[index];
                      final selected = entry.id == soundId;
                      return ListTile(
                        key: Key('sound_pick_${entry.id}'),
                        title: Text(entry.id),
                        selected: selected,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.play_arrow),
                              onPressed: () {
                                ref
                                    .read(soundEffectsControllerProvider)
                                    .previewSoundId(entry.id);
                              },
                            ),
                            if (selected)
                              Icon(
                                Icons.check,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                          ],
                        ),
                        onTap: () => Navigator.of(context).pop(entry.id),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (selected != null) {
      onSelected(selected);
    }
  }
}

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/features/settings/application/settings_providers.dart';
import 'package:interval_timer/features/settings/domain/app_settings.dart';
import 'package:interval_timer/features/sound_effects/domain/audioplayers_sfx_player.dart';
import 'package:interval_timer/features/sound_effects/domain/sfx_catalog.dart';
import 'package:interval_timer/features/sound_effects/domain/sfx_player.dart';
import 'package:interval_timer/features/sound_effects/domain/sound_effects_controller.dart';
import 'package:interval_timer/features/sound_effects/domain/sound_effects_settings.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';

final sfxPlayerProvider = Provider<SfxPlayer>((ref) {
  final player = AudioPlayersSfxPlayer();
  ref.onDispose(() {
    unawaited(player.dispose());
  });
  return player;
});

final sfxCatalogProvider = Provider<SfxCatalog>((ref) => const SfxCatalog());

/// Creates and wires [SoundEffectsController] to F01 timer + settings.
///
/// Watch [soundEffectsBootstrapProvider] from [App] so wiring is active.
final soundEffectsControllerProvider = Provider<SoundEffectsController>((ref) {
  final player = ref.watch(sfxPlayerProvider);
  final catalog = ref.watch(sfxCatalogProvider);
  final controller = SoundEffectsController(player, catalog: catalog);

  final initialSettings = ref.read(settingsControllerProvider).valueOrNull;
  if (initialSettings != null) {
    controller.updateSettings(_toSoundSettings(initialSettings));
  }

  ref.listen<AsyncValue<AppSettings>>(settingsControllerProvider, (
    previous,
    next,
  ) {
    next.whenData((settings) {
      controller.updateSettings(_toSoundSettings(settings));
    });
  });

  ref.listen(timerControllerProvider, (previous, next) {
    unawaited(controller.onTimerState(next));
  });

  final timer = ref.read(timerControllerProvider.notifier);
  final subs = <StreamSubscription<dynamic>>[
    timer.intervalStartedStream.listen(controller.onIntervalStarted),
    timer.sessionCompletedStream.listen((_) => controller.onSessionCompleted()),
    timer.sessionCancelledStream.listen((_) => controller.onSessionCancelled()),
  ];

  ref.onDispose(() {
    for (final sub in subs) {
      unawaited(sub.cancel());
    }
  });

  return controller;
});

/// Bootstrap: keep [soundEffectsControllerProvider] alive for the app lifetime.
final soundEffectsBootstrapProvider = Provider<void>((ref) {
  ref.watch(soundEffectsControllerProvider);
});

SoundEffectsSettings _toSoundSettings(AppSettings s) {
  return SoundEffectsSettings(
    soundEnabled: s.soundEnabled,
    soundOnWorkStart: s.soundOnWorkStart,
    soundOnRestStart: s.soundOnRestStart,
    soundOnSessionComplete: s.soundOnSessionComplete,
    soundOnPrepTick: s.soundOnPrepTick,
    soundOnPhaseWarning: s.soundOnPhaseWarning,
    soundCountdownSeconds: s.soundCountdownSeconds,
    soundIdWorkStart: s.soundIdWorkStart,
    soundIdRestStart: s.soundIdRestStart,
    soundIdSessionComplete: s.soundIdSessionComplete,
    soundIdPrepTick: s.soundIdPrepTick,
    soundIdPhaseWarning: s.soundIdPhaseWarning,
  );
}

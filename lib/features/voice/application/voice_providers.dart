import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/features/music_ducking/application/music_ducking_providers.dart';
import 'package:interval_timer/features/music_ducking/domain/ducking_tts_engine.dart';
import 'package:interval_timer/features/settings/application/settings_providers.dart';
import 'package:interval_timer/features/settings/domain/app_settings.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';
import 'package:interval_timer/features/voice/domain/system_tts_engine.dart';
import 'package:interval_timer/features/voice/domain/tts_engine.dart';
import 'package:interval_timer/features/voice/domain/voice_announcer.dart';
import 'package:interval_timer/features/voice/domain/voice_settings.dart';

final rawTtsEngineProvider = Provider<TtsEngine>((ref) {
  return SystemTtsEngine();
});

final ttsEngineProvider = Provider<TtsEngine>((ref) {
  final rawEngine = ref.watch(rawTtsEngineProvider);
  final sessionManager = ref.watch(audioSessionManagerProvider);
  return DuckingTtsEngine(
    inner: rawEngine,
    audioSessionManager: sessionManager,
    isDuckingEnabled: () => ref.read(musicDuckingEnabledProvider),
  );
});

/// Creates and wires [VoiceAnnouncer] to F01 timer + settings.
///
/// Watch [voiceAnnouncerBootstrapProvider] from [App] so wiring is active.
final voiceAnnouncerProvider = Provider<VoiceAnnouncer>((ref) {
  final engine = ref.watch(ttsEngineProvider);
  final announcer = VoiceAnnouncer(engine);

  final initialSettings = ref.read(settingsControllerProvider).valueOrNull;
  if (initialSettings != null) {
    announcer.updateSettings(_toVoiceSettings(initialSettings));
  }

  ref.listen<AsyncValue<AppSettings>>(settingsControllerProvider, (
    previous,
    next,
  ) {
    next.whenData((settings) {
      announcer.updateSettings(_toVoiceSettings(settings));
    });
  });

  ref.listen(timerControllerProvider, (previous, next) {
    announcer.onTimerState(next);
  });

  final timer = ref.read(timerControllerProvider.notifier);
  final subs = <StreamSubscription<dynamic>>[
    timer.intervalStartedStream.listen(announcer.onIntervalStarted),
    timer.sessionCompletedStream.listen((_) => announcer.onSessionEnded()),
    timer.sessionCancelledStream.listen((_) => announcer.onSessionEnded()),
  ];

  ref.onDispose(() {
    for (final sub in subs) {
      unawaited(sub.cancel());
    }
  });

  return announcer;
});

/// Bootstrap: keep [voiceAnnouncerProvider] alive for the app lifetime.
final voiceAnnouncerBootstrapProvider = Provider<void>((ref) {
  ref.watch(voiceAnnouncerProvider);
});

VoiceSettings _toVoiceSettings(AppSettings s) {
  return VoiceSettings(
    voiceEnabled: s.voiceEnabled,
    countdownSeconds: s.countdownSeconds,
    announceIntervalName: s.announceIntervalName,
  );
}

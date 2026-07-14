import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/features/settings/application/settings_providers.dart';
import 'package:interval_timer/features/settings/domain/app_settings.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';
import 'package:interval_timer/features/vibration/domain/plugin_vibration_driver.dart';
import 'package:interval_timer/features/vibration/domain/vibration_driver.dart';
import 'package:interval_timer/features/vibration/domain/vibration_feedback_controller.dart';
import 'package:interval_timer/features/vibration/domain/vibration_settings.dart';

final vibrationDriverProvider = Provider<VibrationDriver>((ref) {
  return PluginVibrationDriver();
});

/// Creates and wires [VibrationFeedbackController] to F01 timer + settings.
///
/// Watch [vibrationFeedbackBootstrapProvider] from [App] so wiring is active.
final vibrationFeedbackProvider = Provider<VibrationFeedbackController>((ref) {
  final driver = ref.watch(vibrationDriverProvider);
  final controller = VibrationFeedbackController(driver);

  final initialSettings = ref.read(settingsControllerProvider).valueOrNull;
  if (initialSettings != null) {
    controller.updateSettings(_toVibrationSettings(initialSettings));
  }

  ref.listen<AsyncValue<AppSettings>>(settingsControllerProvider, (
    previous,
    next,
  ) {
    next.whenData((settings) {
      controller.updateSettings(_toVibrationSettings(settings));
    });
  });

  ref.listen(timerControllerProvider, (previous, next) {
    controller.onTimerState(next);
  });

  final timer = ref.read(timerControllerProvider.notifier);
  final subs = <StreamSubscription<dynamic>>[
    timer.intervalStartedStream.listen(controller.onIntervalStarted),
    timer.sessionCompletedStream.listen((_) => controller.onSessionEnded()),
    timer.sessionCancelledStream.listen((_) => controller.onSessionEnded()),
  ];

  ref.onDispose(() {
    for (final sub in subs) {
      unawaited(sub.cancel());
    }
  });

  return controller;
});

/// Bootstrap: keep [vibrationFeedbackProvider] alive for the app lifetime.
final vibrationFeedbackBootstrapProvider = Provider<void>((ref) {
  ref.watch(vibrationFeedbackProvider);
});

VibrationSettings _toVibrationSettings(AppSettings s) {
  return VibrationSettings(
    vibrationEnabled: s.vibrationEnabled,
    vibrationOnIntervalStart: s.vibrationOnIntervalStart,
    vibrationOnCountdown: s.vibrationOnCountdown,
    vibrationCountdownSeconds: s.vibrationCountdownSeconds,
  );
}

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/features/always_on/domain/always_on_controller.dart';
import 'package:interval_timer/features/always_on/domain/plugin_wakelock_driver.dart';
import 'package:interval_timer/features/always_on/domain/wakelock_driver.dart';
import 'package:interval_timer/features/settings/application/settings_providers.dart';
import 'package:interval_timer/features/settings/domain/app_settings.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';

final wakelockDriverProvider = Provider<WakelockDriver>((ref) {
  return PluginWakelockDriver();
});

/// Creates and wires [AlwaysOnController] to F01 timer + settings.
///
/// Watch [alwaysOnBootstrapProvider] from [App] so wiring is active.
/// [executionHostMounted] is set from [TimerExecutionScreen] lifecycle.
final alwaysOnControllerProvider = Provider<AlwaysOnController>((ref) {
  final driver = ref.watch(wakelockDriverProvider);
  final controller = AlwaysOnController(driver);

  final initialSettings = ref.read(settingsControllerProvider).valueOrNull;
  if (initialSettings != null) {
    unawaited(
      controller.setKeepScreenOnEnabled(initialSettings.keepScreenOnEnabled),
    );
  }

  ref.listen<AsyncValue<AppSettings>>(settingsControllerProvider, (
    previous,
    next,
  ) {
    next.whenData((settings) {
      unawaited(
        controller.setKeepScreenOnEnabled(settings.keepScreenOnEnabled),
      );
    });
  });

  // Sync current status (may already be running if provider rebuilds mid-session).
  unawaited(controller.onTimerState(ref.read(timerControllerProvider)));

  ref.listen(timerControllerProvider, (previous, next) {
    unawaited(controller.onTimerState(next));
  });

  final timer = ref.read(timerControllerProvider.notifier);
  final subs = <StreamSubscription<dynamic>>[
    timer.sessionCompletedStream.listen((_) {
      unawaited(controller.onSessionEnded());
    }),
    timer.sessionCancelledStream.listen((_) {
      unawaited(controller.onSessionEnded());
    }),
  ];

  ref.onDispose(() {
    for (final sub in subs) {
      unawaited(sub.cancel());
    }
    unawaited(controller.setExecutionHostMounted(false));
  });

  return controller;
});

/// Bootstrap: keep [alwaysOnControllerProvider] alive for the app lifetime.
final alwaysOnBootstrapProvider = Provider<void>((ref) {
  ref.watch(alwaysOnControllerProvider);
});

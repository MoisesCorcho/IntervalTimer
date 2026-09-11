import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/app/app_lifecycle_provider.dart';
import 'package:interval_timer/features/lock_screen/application/plugin_session_surface_driver.dart';
import 'package:interval_timer/features/lock_screen/domain/session_lock_screen_controller.dart';
import 'package:interval_timer/features/lock_screen/domain/session_remote_action_router.dart';
import 'package:interval_timer/features/lock_screen/domain/session_surface_driver.dart';
import 'package:interval_timer/features/settings/application/settings_providers.dart';
import 'package:interval_timer/features/settings/domain/app_settings.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';

final sessionSurfaceDriverProvider = Provider<SessionSurfaceDriver>((ref) {
  final driver = PluginSessionSurfaceDriver();
  ref.onDispose(driver.dispose);
  return driver;
});

/// Creates and wires [SessionLockScreenController] to F01 timer + settings + lifecycle.
final sessionLockScreenControllerProvider =
    Provider<SessionLockScreenController>((ref) {
  final driver = ref.watch(sessionSurfaceDriverProvider);
  final isBackground = ref.watch(isAppInBackgroundProvider);
  final controller = SessionLockScreenController(
    driver,
    isAppInBackground: isBackground,
  );

  ref.listen<bool>(isAppInBackgroundProvider, (previous, next) {
    unawaited(controller.setAppInBackground(next));
  });

  final initialSettings = ref.read(settingsControllerProvider).valueOrNull;
  if (initialSettings != null) {
    unawaited(
      controller.setSessionLockScreenEnabled(
        initialSettings.sessionLockScreenEnabled,
      ),
    );
  }

  ref.listen<AsyncValue<AppSettings>>(settingsControllerProvider, (
    previous,
    next,
  ) {
    next.whenData((settings) {
      unawaited(
        controller.setSessionLockScreenEnabled(
          settings.sessionLockScreenEnabled,
        ),
      );
    });
  });

  // Permission bootstrap (non-blocking; real request is contextual on first need).
  unawaited(() async {
    try {
      final granted = await driver.isPermissionGranted();
      await controller.setPermissionGranted(granted);
    } catch (e, st) {
      debugPrint('sessionLockScreen permission bootstrap: $e\n$st');
    }
  }());

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
    driver.remoteActions.listen((action) {
      SessionRemoteActionRouter.dispatch(action, timer);
    }),
  ];

  ref.onDispose(() {
    for (final sub in subs) {
      unawaited(sub.cancel());
    }
    unawaited(controller.onSessionEnded());
  });

  return controller;
});

/// Bootstrap: keep [sessionLockScreenControllerProvider] alive app-wide.
final sessionLockScreenBootstrapProvider = Provider<void>((ref) {
  ref.watch(sessionLockScreenControllerProvider);
});

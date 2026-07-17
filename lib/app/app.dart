import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/app/router.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/features/always_on/application/always_on_providers.dart';
import 'package:interval_timer/features/calendar_history/application/session_history_listener.dart';
import 'package:interval_timer/features/lock_screen/application/lock_screen_providers.dart';
import 'package:interval_timer/features/settings/application/settings_providers.dart';
import 'package:interval_timer/features/settings/domain/app_theme_mode.dart';
import 'package:interval_timer/features/vibration/application/vibration_providers.dart';
import 'package:interval_timer/features/voice/application/voice_providers.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Bootstrap F04 session history listener once for the app lifetime.
    ref.watch(sessionHistoryBootstrapProvider);
    // Bootstrap F02 voice announcements (listens to TimerController).
    ref.watch(voiceAnnouncerBootstrapProvider);
    // Bootstrap F18 vibration feedback (listens to TimerController).
    ref.watch(vibrationFeedbackBootstrapProvider);
    // Bootstrap F19 always-on screen (listens to TimerController + host).
    ref.watch(alwaysOnBootstrapProvider);
    // Bootstrap F20 session lock screen / notification surface.
    ref.watch(sessionLockScreenBootstrapProvider);
    final router = ref.watch(routerProvider);
    final settingsAsync = ref.watch(settingsControllerProvider);
    final themeMode = _toFlutterThemeMode(
      settingsAsync.valueOrNull?.themeMode ?? AppThemeMode.system,
    );

    return MaterialApp.router(
      title: UiStrings.appTitle,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}

/// Maps domain [AppThemeMode] → Flutter [ThemeMode] at the app shell only.
ThemeMode _toFlutterThemeMode(AppThemeMode mode) {
  return switch (mode) {
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
    AppThemeMode.system => ThemeMode.system,
  };
}

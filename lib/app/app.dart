import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/app/app_lifecycle_provider.dart';
import 'package:interval_timer/app/router.dart';
import 'package:interval_timer/core/l10n/l10n_extension.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/features/always_on/application/always_on_providers.dart';
import 'package:interval_timer/features/calendar_history/application/session_history_listener.dart';
import 'package:interval_timer/features/lock_screen/application/lock_screen_providers.dart';
import 'package:interval_timer/features/settings/application/language_providers.dart';
import 'package:interval_timer/features/settings/application/settings_providers.dart';
import 'package:interval_timer/features/settings/domain/app_theme_mode.dart';
import 'package:interval_timer/features/sound_effects/application/sound_effects_providers.dart';
import 'package:interval_timer/features/vibration/application/vibration_providers.dart';
import 'package:interval_timer/features/voice/application/voice_providers.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onStateChange: (state) {
        ref.read(appLifecycleStateProvider.notifier).state = state;
      },
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Bootstrap F04 session history listener once for the app lifetime.
    ref.watch(sessionHistoryBootstrapProvider);
    // Bootstrap F02 voice announcements (listens to TimerController).
    ref.watch(voiceAnnouncerBootstrapProvider);
    // Bootstrap F18 vibration feedback (listens to TimerController).
    ref.watch(vibrationFeedbackBootstrapProvider);
    // Bootstrap F36 timer SFX (listens to TimerController).
    ref.watch(soundEffectsBootstrapProvider);
    // Bootstrap F19 always-on screen (listens to TimerController + host).
    ref.watch(alwaysOnBootstrapProvider);
    // Bootstrap F20 session lock screen / notification surface.
    ref.watch(sessionLockScreenBootstrapProvider);
    final router = ref.watch(routerProvider);
    final settingsAsync = ref.watch(settingsControllerProvider);
    final settings = settingsAsync.valueOrNull;
    final themeMode = _toFlutterThemeMode(
      settings?.themeMode ?? AppThemeMode.system,
    );
    final primaryColor = settings != null
        ? Color(settings.themeColorArgb)
        : AppTheme.primaryColor;

    final effectiveLocale = ref.watch(effectiveLocaleProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appTitle,
      theme: AppTheme.light(primaryColor: primaryColor),
      darkTheme: AppTheme.dark(primaryColor: primaryColor),
      themeMode: themeMode,
      routerConfig: router,
      locale: effectiveLocale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
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

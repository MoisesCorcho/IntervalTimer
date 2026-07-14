import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/app/router.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/features/calendar_history/application/session_history_listener.dart';
import 'package:interval_timer/features/voice/application/voice_providers.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Bootstrap F04 session history listener once for the app lifetime.
    ref.watch(sessionHistoryBootstrapProvider);
    // Bootstrap F02 voice announcements (listens to TimerController).
    ref.watch(voiceAnnouncerBootstrapProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: UiStrings.appTitle,
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}
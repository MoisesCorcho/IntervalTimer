import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';

class SessionCompletedScreen extends ConsumerWidget {
  const SessionCompletedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: AppTheme.spacingLg),
              Text(
                UiStrings.sessionCompleted,
                key: const Key('session_completed_title'),
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Text(
                UiStrings.sessionCompletedMessage,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingLg),
              FilledButton(
                key: const Key('back_to_routine_button'),
                onPressed: () {
                  ref.read(timerControllerProvider.notifier).resetToIdle();
                  context.go('/');
                },
                child: const Text(UiStrings.backToRoutine),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
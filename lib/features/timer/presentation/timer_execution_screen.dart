import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/core/utils/contrast_text_color.dart';
import 'package:interval_timer/core/utils/duration_parser.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';
import 'package:interval_timer/features/timer/application/timer_state.dart';
import 'package:interval_timer/shared/widgets/countdown_ring.dart';
import 'package:interval_timer/shared/widgets/interval_color_badge.dart';

class TimerExecutionScreen extends ConsumerStatefulWidget {
  const TimerExecutionScreen({super.key});

  @override
  ConsumerState<TimerExecutionScreen> createState() =>
      _TimerExecutionScreenState();
}

class _TimerExecutionScreenState extends ConsumerState<TimerExecutionScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = ref.read(timerControllerProvider.notifier);
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        controller.onAppLifecyclePaused();
      case AppLifecycleState.resumed:
        controller.onAppLifecycleResumed();
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerControllerProvider);
    final controller = ref.read(timerControllerProvider.notifier);

    ref.listen(timerControllerProvider, (previous, next) {
      if (next.status == TimerStatus.completed) {
        context.go('/completed');
      }
      if (next.status == TimerStatus.idle &&
          previous?.status != TimerStatus.idle) {
        context.go('/');
      }
    });

    final current = timerState.currentInterval;
    if (current == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final bgColor = Color(current.colorArgb);
    final textColor = contrastTextColor(bgColor);
    final timeText = formatRemainingMs(timerState.remainingMs);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            children: [
              Text(
                current.name,
                key: const Key('current_interval_name'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                UiStrings.intervalProgress
                    .replaceAll('{current}', '${timerState.currentIndex + 1}')
                    .replaceAll('{total}', '${timerState.intervalCount}'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: textColor.withValues(alpha: 0.85),
                    ),
              ),
              const Spacer(),
              CountdownRing(
                remainingFraction: timerState.remainingFraction,
                color: textColor,
                child: Text(
                  timeText,
                  key: const Key('countdown_display'),
                  style: AppTheme.timerDisplayStyle(context).copyWith(
                    color: textColor,
                    fontSize: 48,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                timerState.hasNextInterval
                    ? UiStrings.nextInterval
                    : UiStrings.lastInterval,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: textColor.withValues(alpha: 0.8),
                    ),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              if (timerState.nextInterval != null)
                IntervalColorBadge(
                  name: timerState.nextInterval!.name,
                  color: Color(timerState.nextInterval!.colorArgb),
                  durationLabel: formatDurationMmSs(
                    timerState.nextInterval!.durationSeconds,
                  ),
                )
              else
                Text(
                  UiStrings.lastInterval,
                  key: const Key('last_interval_label'),
                  style: TextStyle(color: textColor),
                ),
              const SizedBox(height: AppTheme.spacingLg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ControlButton(
                    key: const Key('pause_resume_button'),
                    icon: timerState.status == TimerStatus.paused
                        ? Icons.play_arrow
                        : Icons.pause,
                    label: timerState.status == TimerStatus.paused
                        ? UiStrings.resume
                        : UiStrings.pause,
                    color: textColor,
                    onPressed: () {
                      if (timerState.status == TimerStatus.paused) {
                        controller.resume();
                      } else {
                        controller.pause();
                      }
                    },
                  ),
                  _ControlButton(
                    key: const Key('skip_button'),
                    icon: Icons.skip_next,
                    label: UiStrings.skip,
                    color: textColor,
                    onPressed: controller.skip,
                  ),
                  _ControlButton(
                    key: const Key('cancel_button'),
                    icon: Icons.close,
                    label: UiStrings.cancelSession,
                    color: textColor,
                    onPressed: controller.cancel,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: IconButton.filled(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
          fixedSize: const Size(56, 56),
          backgroundColor: color.withValues(alpha: 0.2),
          foregroundColor: color,
        ),
        tooltip: label,
        onPressed: onPressed,
        icon: Icon(icon),
      ),
    );
  }
}
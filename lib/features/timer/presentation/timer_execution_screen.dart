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

  Future<void> _confirmExit() async {
    final controller = ref.read(timerControllerProvider.notifier);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          key: const Key('exit_confirm_dialog'),
          title: const Text(UiStrings.exitConfirmTitle),
          content: const Text(UiStrings.exitConfirmMessage),
          actions: [
            TextButton(
              key: const Key('exit_continue_button'),
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(UiStrings.exitConfirmContinue),
            ),
            TextButton(
              key: const Key('exit_leave_button'),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(UiStrings.exitConfirmLeave),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      controller.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerControllerProvider);
    final controller = ref.read(timerControllerProvider.notifier);

    ref.listen(timerControllerProvider, (previous, next) {
      if (!context.mounted) return;
      // Widget tests may host this screen without GoRouter.
      final router = GoRouter.maybeOf(context);
      if (router == null) return;

      if (next.status == TimerStatus.completed) {
        router.go('/completed');
      }
      if (next.status == TimerStatus.idle &&
          previous?.status != TimerStatus.idle) {
        router.go('/');
      }
    });

    if (!timerState.isSessionActive &&
        timerState.status != TimerStatus.completed) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final current = timerState.currentInterval;
    final isPrep = timerState.isInPreparation;
    final bgColor = isPrep
        ? (timerState.nextInterval != null
            ? Color(timerState.nextInterval!.colorArgb)
            : Theme.of(context).colorScheme.surfaceContainerHighest)
        : Color(current?.colorArgb ?? 0xFF4CAF50);
    final textColor = contrastTextColor(bgColor);
    final segmentTimeText = formatRemainingMs(timerState.remainingMs);
    final totalTimeText = formatTotalRemainingMs(timerState.totalRemainingMs);
    final phaseName =
        isPrep ? UiStrings.preparation : (current?.name ?? '');
    final isPaused = timerState.status == TimerStatus.paused;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            children: [
              _ExecutionTopBar(
                textColor: textColor,
                totalTimeText: totalTimeText,
                onExit: _confirmExit,
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Text(
                phaseName,
                key: const Key('current_interval_name'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              if (!isPrep) ...[
                const SizedBox(height: AppTheme.spacingSm),
                Text(
                  UiStrings.intervalProgress
                      .replaceAll(
                        '{current}',
                        '${timerState.currentIndex + 1}',
                      )
                      .replaceAll('{total}', '${timerState.intervalCount}'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: textColor.withValues(alpha: 0.85),
                      ),
                ),
              ],
              const Spacer(),
              CountdownRing(
                remainingFraction: timerState.remainingFraction,
                color: textColor,
                child: Text(
                  segmentTimeText,
                  key: const Key('countdown_display'),
                  style: AppTheme.timerDisplayStyle(context).copyWith(
                    color: textColor,
                    fontSize: 48,
                  ),
                ),
              ),
              const Spacer(),
              _NextSegmentCard(
                textColor: textColor,
                hasNext: timerState.hasNextInterval,
                nextName: timerState.nextInterval?.name,
                nextDurationSeconds: timerState.nextInterval?.durationSeconds,
              ),
              const SizedBox(height: AppTheme.spacingLg),
              _ExecutionControlBar(
                textColor: textColor,
                isPaused: isPaused,
                canSkipBack: timerState.canSkipBack,
                onPrevious: controller.skipBack,
                onPauseResume: () {
                  if (isPaused) {
                    controller.resume();
                  } else {
                    controller.pause();
                  }
                },
                onNext: controller.skipForward,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExecutionTopBar extends StatelessWidget {
  const _ExecutionTopBar({
    required this.textColor,
    required this.totalTimeText,
    required this.onExit,
  });

  final Color textColor;
  final String totalTimeText;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 48,
          child: _RectControlButton(
            key: const Key('exit_button'),
            icon: Icons.close,
            label: UiStrings.exitSession,
            color: textColor,
            filled: false,
            iconOnly: true,
            onPressed: onExit,
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                UiStrings.remainingLabel,
                key: const Key('total_remaining_label'),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: textColor.withValues(alpha: 0.85),
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                totalTimeText,
                key: const Key('total_remaining_display'),
                style: AppTheme.timerDisplayStyle(context).copyWith(
                  color: textColor,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }
}

class _NextSegmentCard extends StatelessWidget {
  const _NextSegmentCard({
    required this.textColor,
    required this.hasNext,
    required this.nextName,
    required this.nextDurationSeconds,
  });

  final Color textColor;
  final bool hasNext;
  final String? nextName;
  final int? nextDurationSeconds;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: const Key('next_segment_card'),
      color: textColor.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingSm + 4,
        ),
        child: hasNext
            ? Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          UiStrings.nextInterval,
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: textColor.withValues(alpha: 0.75),
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          nextName ?? '',
                          key: const Key('next_segment_name'),
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: textColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  if (nextDurationSeconds != null)
                    Text(
                      formatDurationMmSs(nextDurationSeconds!),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: textColor.withValues(alpha: 0.85),
                          ),
                    ),
                ],
              )
            : Center(
                child: Text(
                  UiStrings.lastInterval,
                  key: const Key('last_interval_label'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: textColor,
                      ),
                ),
              ),
      ),
    );
  }
}

class _ExecutionControlBar extends StatelessWidget {
  const _ExecutionControlBar({
    required this.textColor,
    required this.isPaused,
    required this.canSkipBack,
    required this.onPrevious,
    required this.onPauseResume,
    required this.onNext,
  });

  final Color textColor;
  final bool isPaused;
  final bool canSkipBack;
  final VoidCallback onPrevious;
  final VoidCallback onPauseResume;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _RectControlButton(
            key: const Key('previous_button'),
            icon: Icons.skip_previous,
            label: UiStrings.previous,
            color: textColor,
            filled: false,
            iconOnly: true,
            onPressed: canSkipBack ? onPrevious : null,
          ),
        ),
        const SizedBox(width: AppTheme.spacingSm),
        Expanded(
          flex: 2,
          child: _RectControlButton(
            key: const Key('pause_resume_button'),
            icon: isPaused ? Icons.play_arrow : Icons.pause,
            label: isPaused ? UiStrings.resume : UiStrings.pause,
            color: textColor,
            filled: true,
            iconOnly: false,
            onPressed: onPauseResume,
          ),
        ),
        const SizedBox(width: AppTheme.spacingSm),
        Expanded(
          child: _RectControlButton(
            key: const Key('skip_button'),
            icon: Icons.skip_next,
            label: UiStrings.nextInterval,
            color: textColor,
            filled: false,
            iconOnly: true,
            onPressed: onNext,
          ),
        ),
      ],
    );
  }
}

/// Shared rectangular control used for exit, prev/next and pause/resume.
class _RectControlButton extends StatelessWidget {
  const _RectControlButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.filled,
    required this.iconOnly,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool filled;
  final bool iconOnly;
  final VoidCallback? onPressed;

  /// Outer elevation only (Tailwind-like `shadow` / `shadow-md`).
  /// Color + shadow live on the same [BoxDecoration] so the shadow is
  /// painted *around* the surface, not as an inset look inside the fill.
  static const _outerShadow = [
    BoxShadow(
      color: Color(0x1A000000), // ~10% black
      blurRadius: 6,
      offset: Offset(0, 4),
      spreadRadius: -1,
    ),
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 4,
      offset: Offset(0, 2),
      spreadRadius: -2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final bg = filled
        ? color.withValues(alpha: enabled ? 0.28 : 0.10)
        : color.withValues(alpha: enabled ? 0.16 : 0.08);
    final fg = color.withValues(alpha: enabled ? 1.0 : 0.35);
    final borderRadius = BorderRadius.circular(AppTheme.radiusSm);

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: borderRadius,
          boxShadow: enabled ? _outerShadow : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            borderRadius: borderRadius,
            splashColor: color.withValues(alpha: 0.12),
            highlightColor: color.withValues(alpha: 0.06),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal:
                      iconOnly ? AppTheme.spacingSm : AppTheme.spacingMd,
                  vertical: AppTheme.spacingSm,
                ),
                child: iconOnly
                    ? Center(
                        child: Icon(icon, color: fg, size: 26),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(icon, color: fg, size: 24),
                          const SizedBox(width: AppTheme.spacingSm),
                          Flexible(
                            child: Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: fg,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

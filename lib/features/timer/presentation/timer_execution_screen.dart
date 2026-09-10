import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interval_timer/core/l10n/l10n_extension.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/core/utils/duration_parser.dart';
import 'package:interval_timer/core/utils/execution_chrome.dart';
import 'package:interval_timer/core/utils/name_format.dart';
import 'package:interval_timer/features/always_on/application/always_on_providers.dart';
import 'package:interval_timer/features/always_on/domain/always_on_controller.dart';
import 'package:interval_timer/features/settings/application/settings_providers.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';
import 'package:interval_timer/features/timer/application/timer_state.dart';
import 'package:interval_timer/features/timer/presentation/widgets/timer_audio_controls_sheet.dart';
import 'package:interval_timer/shared/widgets/app_primary_button.dart';
import 'package:interval_timer/shared/widgets/countdown_ring.dart';
import 'package:interval_timer/shared/widgets/dialog_actions_row.dart';

class TimerExecutionScreen extends ConsumerStatefulWidget {
  const TimerExecutionScreen({super.key});

  @override
  ConsumerState<TimerExecutionScreen> createState() =>
      _TimerExecutionScreenState();
}

class _TimerExecutionScreenState extends ConsumerState<TimerExecutionScreen>
    with WidgetsBindingObserver {
  /// Cached so [dispose] can release wakelock without using [ref] after unmount.
  AlwaysOnController? _alwaysOn;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // F19: mark execution host mounted after first frame (R4 / R1 host gate).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _alwaysOn = ref.read(alwaysOnControllerProvider);
      _alwaysOn?.setExecutionHostMounted(true);
    });
  }

  @override
  void dispose() {
    // F19 R4: release wakelock when leaving execution screen (no ref after dispose).
    _alwaysOn?.setExecutionHostMounted(false);
    _alwaysOn = null;
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
        // F19 R9: reaffirm screen wakelock if policy still requires it.
        if (mounted) {
          ref.read(alwaysOnControllerProvider).onAppLifecycleResumed();
        }
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> _confirmExit() async {
    final controller = ref.read(timerControllerProvider.notifier);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        final l10n = dialogCtx.l10n;
        return AlertDialog(
          key: const Key('exit_confirm_dialog'),
          title: Text(l10n.exitConfirmTitle),
          content: Text(l10n.exitConfirmMessage),
          actions: [
            DialogActionsRow(
              children: [
                AppSecondaryButton(
                  key: const Key('exit_continue_button'),
                  compact: true,
                  onPressed: () => Navigator.of(dialogCtx).pop(false),
                  label: l10n.exitConfirmContinue,
                ),
                AppPrimaryButton(
                  key: const Key('exit_leave_button'),
                  compact: true,
                  onPressed: () => Navigator.of(dialogCtx).pop(true),
                  label: l10n.exitConfirmLeave,
                ),
              ],
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
    // Phase color + chrome: brand work/rest always dark fill + white text/ring
    // (F35), independent of app light/dark theme and of light colorArgb leftovers.
    final phaseInterval = isPrep ? timerState.nextInterval : current;
    final bgColor = executionBackgroundColor(
      interval: phaseInterval,
      prepFallback: Theme.of(context).colorScheme.surfaceContainerHighest,
    );
    final textColor = executionChromeColor(
      background: bgColor,
      type: phaseInterval?.type,
    );
    final segmentTimeText = formatRemainingMs(timerState.remainingMs);
    final totalTimeText = formatTotalRemainingMs(timerState.totalRemainingMs);
    final l10n = context.l10n;
    final settings = ref.watch(settingsControllerProvider).valueOrNull;
    final allAudioMuted = settings != null &&
        !settings.voiceEnabled &&
        !settings.soundEnabled &&
        !settings.vibrationEnabled;
    final phaseName = isPrep
        ? l10n.preparation
        : formatDisplayName(current?.name ?? '');
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
                allAudioMuted: allAudioMuted,
                onExit: _confirmExit,
                onOpenAudioControls: () => showTimerAudioControlsSheet(context),
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
                  l10n.intervalProgress(
                    timerState.currentIndex + 1,
                    timerState.intervalCount,
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: textColor.withValues(alpha: 0.85),
                      ),
                ),
                if (current?.roundCount != null &&
                    current!.roundCount! > 1 &&
                    current.roundIndex != null) ...[
                  const SizedBox(height: AppTheme.spacingXs),
                  Text(
                    l10n.workoutRoundProgress(
                      current.roundIndex!,
                      current.roundCount!,
                    ),
                    key: const Key('workout_round_progress'),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: textColor.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                  ),
                ],
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
                nextName: timerState.nextInterval != null
                    ? formatDisplayName(timerState.nextInterval!.name)
                    : null,
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
    required this.allAudioMuted,
    required this.onExit,
    required this.onOpenAudioControls,
  });

  final Color textColor;
  final String totalTimeText;
  final bool allAudioMuted;
  final VoidCallback onExit;
  final VoidCallback onOpenAudioControls;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        SizedBox(
          width: 48,
          child: _RectControlButton(
            key: const Key('exit_button'),
            icon: Icons.close,
            label: l10n.exitSession,
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
                l10n.remainingLabel,
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
        SizedBox(
          width: 48,
          child: _RectControlButton(
            key: const Key('timer_audio_controls_button'),
            icon: allAudioMuted ? Icons.volume_off : Icons.tune,
            label: l10n.quickAudioSettingsTooltip,
            color: textColor,
            filled: false,
            iconOnly: true,
            onPressed: onOpenAudioControls,
          ),
        ),
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
    final l10n = context.l10n;
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
                          l10n.nextInterval,
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
                  l10n.lastInterval,
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
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: _RectControlButton(
            key: const Key('previous_button'),
            icon: Icons.skip_previous,
            label: l10n.previous,
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
            label: isPaused ? l10n.resume : l10n.pause,
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
            label: l10n.nextInterval,
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

/// Execution control: rectangular + subtle radius + outer shadow
/// (same language as [AppPrimaryButton], adaptive colors on interval bg).
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

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    // Filled pause/resume: solid tone like primary CTA; outline-style for skips.
    final bg = filled
        ? color.withValues(alpha: enabled ? 0.92 : 0.28)
        : color.withValues(alpha: enabled ? 0.18 : 0.08);
    final fg = filled
        ? (enabled
            ? (color.computeLuminance() > 0.5
                ? Colors.black
                : Colors.white)
            : (color.computeLuminance() > 0.5
                ? Colors.black.withValues(alpha: 0.38)
                : Colors.white.withValues(alpha: 0.38)))
        : color.withValues(alpha: enabled ? 1.0 : 0.35);
    // Subtle square corners — never stadium (height/2).
    final borderRadius = BorderRadius.circular(AppTheme.buttonRadius);

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: borderRadius,
          boxShadow: enabled ? AppTheme.buttonShadowFor(context) : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            borderRadius: borderRadius,
            splashColor: color.withValues(alpha: 0.12),
            highlightColor: color.withValues(alpha: 0.06),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppTheme.buttonMinHeight,
                minWidth: AppTheme.buttonMinHeight,
              ),
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

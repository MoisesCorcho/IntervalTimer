import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/features/monetization/application/daily_rewarded_ad_tracker.dart';
import 'package:interval_timer/features/monetization/application/monetization_providers.dart';
import 'package:interval_timer/features/monetization/domain/rewarded_benefit.dart';
import 'package:interval_timer/features/pro_tier/presentation/screens/paywall_modal_screen.dart';
import 'package:interval_timer/shared/widgets/app_snack_bar.dart';

/// Diálogo modal contextual reutilizable para informar al usuario sobre funciones bloqueadas
/// y ofrecer la doble compuerta ética: "Obtener Pro" o "Ver video bonificado para probar".
class BenefitUnlockDialog extends ConsumerWidget {
  final RewardedBenefit benefit;
  final VoidCallback? onProPressed;
  final VoidCallback? onUnlocked;

  const BenefitUnlockDialog({
    super.key,
    required this.benefit,
    this.onProPressed,
    this.onUnlocked,
  });

  static Future<void> show({
    required BuildContext context,
    required RewardedBenefit benefit,
    VoidCallback? onProPressed,
    VoidCallback? onUnlocked,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => BenefitUnlockDialog(
        benefit: benefit,
        onProPressed: onProPressed,
        onUnlocked: onUnlocked,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tracker = ref.watch(dailyRewardedAdTrackerProvider);
    final state = ref.watch(monetizationControllerProvider);

    final title = _getTitle(benefit);
    final durationText = _getDurationText(benefit);
    final iconData = _getIcon(benefit);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: theme.colorScheme.surface,
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  iconData,
                  color: theme.colorScheme.primary,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                durationText,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Esta función pertenece al plan Pro. Puedes desbloquearla de forma ilimitada o probarla viendo un anuncio.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            // Opción Primaria: Pro
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onProPressed != null) {
                  onProPressed!();
                } else {
                  PaywallModalScreen.show(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Desbloquear con Pro',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 12),
            // Opción Secundaria: Video Bonificado
            _RewardedAdWatchButton(
              benefit: benefit,
              onUnlocked: onUnlocked,
            ),
          ],
        ),
      ),
    );
  }

  String _getTitle(RewardedBenefit benefit) {
    switch (benefit) {
      case RewardedBenefit.extraWorkoutSlot:
        return 'Desbloquear 4ª Rutina';
      case RewardedBenefit.proAudioPass:
        return 'Desbloquear Efectos de Sonido Pro';
      case RewardedBenefit.phaseColorsPass:
        return 'Desbloquear Colores de Fase';
      case RewardedBenefit.bodyTrackingPass:
        return 'Desbloquear Seguimiento Corporal';
      case RewardedBenefit.adFreePass:
        return 'Desbloquear 24h Sin Anuncios';
    }
  }

  String _getDurationText(RewardedBenefit benefit) {
    final hours = benefit.defaultDuration.inHours;
    return 'Probar por $hours horas';
  }

  IconData _getIcon(RewardedBenefit benefit) {
    switch (benefit) {
      case RewardedBenefit.extraWorkoutSlot:
        return Icons.fitness_center;
      case RewardedBenefit.proAudioPass:
        return Icons.volume_up;
      case RewardedBenefit.phaseColorsPass:
        return Icons.palette;
      case RewardedBenefit.bodyTrackingPass:
        return Icons.monitor_weight;
      case RewardedBenefit.adFreePass:
        return Icons.block;
    }
  }
}

class _RewardedAdWatchButton extends ConsumerStatefulWidget {
  final RewardedBenefit benefit;
  final VoidCallback? onUnlocked;

  const _RewardedAdWatchButton({
    required this.benefit,
    this.onUnlocked,
  });

  @override
  ConsumerState<_RewardedAdWatchButton> createState() =>
      _RewardedAdWatchButtonState();
}

class _RewardedAdWatchButtonState
    extends ConsumerState<_RewardedAdWatchButton> {
  Timer? _timer;
  Duration _remainingCooldown = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initCooldown() async {
    final tracker = ref.read(dailyRewardedAdTrackerProvider);
    final remaining = await tracker.getRemainingCooldown();
    if (!mounted) return;

    setState(() {
      _remainingCooldown = remaining;
    });

    if (remaining > Duration.zero) {
      _startCooldownTimer();
    }
  }

  void _startCooldownTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingCooldown > const Duration(seconds: 1)) {
        setState(() {
          _remainingCooldown -= const Duration(seconds: 1);
        });
      } else {
        timer.cancel();
        _timer = null;
        setState(() {
          _remainingCooldown = Duration.zero;
        });
        ref.invalidate(canWatchRewardedAdProvider);
        ref.invalidate(dailyRewardedAdCountProvider);
      }
    });
  }

  String _formatDuration(Duration d) {
    final totalSeconds = (d.inMilliseconds / 1000).ceil();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final mm = minutes.toString().padLeft(2, '0');
    final ss = seconds.toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final canWatchAsync = ref.watch(canWatchRewardedAdProvider);
    final dailyCountAsync = ref.watch(dailyRewardedAdCountProvider);
    final state = ref.watch(monetizationControllerProvider);

    ref.listen(canWatchRewardedAdProvider, (prev, next) {
      if (next.valueOrNull == false) {
        _initCooldown();
      }
    });

    final canWatch = canWatchAsync.valueOrNull ?? false;
    final dailyCount = dailyCountAsync.valueOrNull ?? 0;
    final capReached = dailyCount >= DailyRewardedAdTracker.maxDailyAds;

    final isCooldown = !canWatch && !capReached && (_remainingCooldown > Duration.zero);

    String buttonText = 'Ver video para desbloquear';
    if (capReached) {
      buttonText = 'Límite diario alcanzado (2/2)';
    } else if (isCooldown) {
      buttonText = 'Disponible en ${_formatDuration(_remainingCooldown)}';
    }

    final isBlocked = !canWatch || capReached || isCooldown;

    return OutlinedButton.icon(
      key: const Key('benefit_unlock_watch_ad_button'),
      onPressed: (isBlocked || state.isLoading)
          ? null
          : () async {
              final success = await ref
                  .read(monetizationControllerProvider.notifier)
                  .requestRewardedUnlock(widget.benefit);

              if (!context.mounted) return;

              if (success) {
                Navigator.of(context).pop();
                widget.onUnlocked?.call();
                AppSnackBar.showSuccess(
                  context,
                  message: '¡Pase temporal activado con éxito!',
                );
              } else {
                final err = ref
                    .read(monetizationControllerProvider)
                    .errorMessage;
                if (err != null) {
                  AppSnackBar.showError(
                    context,
                    message: err,
                  );
                }
              }
            },
      icon: state.isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              isCooldown ? Icons.timer_outlined : Icons.play_circle_outline,
              size: 20,
            ),
      label: Text(buttonText),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}


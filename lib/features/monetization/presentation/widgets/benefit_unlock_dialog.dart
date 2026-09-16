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
            Builder(
              builder: (context) {
                final canWatchAsync = ref.watch(canWatchRewardedAdProvider);
                final dailyCountAsync = ref.watch(dailyRewardedAdCountProvider);
                final canWatch = canWatchAsync.valueOrNull ?? false;
                final dailyCount = dailyCountAsync.valueOrNull ?? 0;
                final capReached =
                    dailyCount >= DailyRewardedAdTracker.maxDailyAds;

                String buttonText = 'Ver video para desbloquear';
                if (capReached) {
                  buttonText = 'Límite diario alcanzado (2/2)';
                }

                return OutlinedButton.icon(
                  key: const Key('benefit_unlock_watch_ad_button'),
                  onPressed: (!canWatch || state.isLoading)
                      ? null
                      : () async {
                          final success = await ref
                              .read(monetizationControllerProvider.notifier)
                              .requestRewardedUnlock(benefit);

                          if (!context.mounted) return;

                          if (success) {
                            Navigator.of(context).pop();
                            onUnlocked?.call();
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
                      : const Icon(Icons.play_circle_outline, size: 20),
                  label: Text(buttonText),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                );
              },
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

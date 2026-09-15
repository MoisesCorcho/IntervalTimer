import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:interval_timer/core/l10n/l10n_extension.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/shared/widgets/app_primary_button.dart';
import 'package:interval_timer/shared/widgets/app_snack_bar.dart';

/// Modal bottom sheet displaying active Pro membership status and premium benefits.
/// Shown to users who already have Pro entitlement when interacting with account status.
class ProStatusModalSheet extends StatelessWidget {
  const ProStatusModalSheet({super.key});

  /// Presents the active Pro status modal bottom sheet.
  static Future<void> show(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF141417) : const Color(0xFFF9F9FB);

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
      ),
      clipBehavior: Clip.antiAlias,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.92,
      ),
      builder: (context) => const ProStatusModalSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF141417) : const Color(0xFFF9F9FB);

    return Material(
      color: backgroundColor,
      child: SafeArea(
        top: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingMd,
                AppTheme.spacingSm,
                AppTheme.spacingMd,
                AppTheme.spacingMd,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Verified Crown & Glow
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFB300).withValues(alpha: 0.4),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.verified_rounded,
                        size: 34,
                        color: Color(0xFF2E1C00),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),

                  // Title & Subtitle
                  Text(
                    l10n.proActiveTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXs),
                  Text(
                    l10n.proActiveSubtitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),

                  // Membership Active Pill
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingMd,
                        vertical: AppTheme.spacingXs,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB300).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: const Color(0xFFFFB300).withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 16,
                            color: Color(0xFFFF8F00),
                          ),
                          const SizedBox(width: AppTheme.spacingXs),
                          Text(
                            l10n.proActiveMembershipLabel,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: const Color(0xFFFF8F00),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLg),

                  // Unlocked Benefits List
                  _ProStatusBenefitItem(
                    icon: Icons.fitness_center_rounded,
                    title: l10n.proBenefitUnlimitedWorkoutsTitle,
                    subtitle: l10n.proBenefitUnlimitedWorkoutsDesc,
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  _ProStatusBenefitItem(
                    icon: Icons.straighten_rounded,
                    title: l10n.proBenefitBodyTrackingTitle,
                    subtitle: l10n.proBenefitBodyTrackingDesc,
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  _ProStatusBenefitItem(
                    icon: Icons.block_rounded,
                    title: l10n.proBenefitZeroAdsTitle,
                    subtitle: l10n.proBenefitZeroAdsDesc,
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  _ProStatusBenefitItem(
                    icon: Icons.sports_rounded,
                    title: l10n.proBenefitSfxClipsTitle,
                    subtitle: l10n.proBenefitSfxClipsDesc,
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  _ProStatusBenefitItem(
                    icon: Icons.palette_rounded,
                    title: l10n.proBenefitPhaseColorsTitle,
                    subtitle: l10n.proBenefitPhaseColorsDesc,
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  _ProStatusBenefitItem(
                    icon: Icons.favorite_rounded,
                    title: l10n.proBenefitIndieDevTitle,
                    subtitle: l10n.proBenefitIndieDevDesc,
                  ),
                  const SizedBox(height: AppTheme.spacingLg),

                  // Primary Dismiss CTA
                  AppPrimaryButton(
                    key: const Key('pro_status_dismiss_button'),
                    onPressed: () => Navigator.of(context).pop(),
                    label: l10n.proDismissDialog,
                  ),
                  const SizedBox(height: AppTheme.spacingSm),

                  // Manage Subscription Text Button
                  Center(
                    child: TextButton(
                      key: const Key('pro_status_manage_button'),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        AppSnackBar.showInfo(
                          context,
                          message: l10n.proManageSubscriptionNotice,
                        );
                      },
                      child: Text(
                        l10n.proManageSubscription,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: AppTheme.spacingXs,
              child: IconButton(
                key: const Key('pro_status_close_button'),
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProStatusBenefitItem extends StatelessWidget {
  const _ProStatusBenefitItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Icon(
            icon,
            size: 18,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: AppTheme.spacingSm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

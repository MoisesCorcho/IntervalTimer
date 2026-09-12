import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/core/l10n/l10n_extension.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/features/pro_tier/application/paywall_controller.dart';
import 'package:interval_timer/features/pro_tier/application/pro_providers.dart';
import 'package:interval_timer/features/pro_tier/domain/product_package.dart';
import 'package:interval_timer/features/pro_tier/domain/purchase_result.dart';
import 'package:interval_timer/shared/widgets/app_primary_button.dart';
import 'package:interval_timer/shared/widgets/app_snack_bar.dart';

/// Ultra-premium modal paywall displaying Pro tier benefits and subscription packages.
class PaywallModalScreen extends ConsumerStatefulWidget {
  const PaywallModalScreen({super.key});

  /// Presents the Paywall as a modal bottom sheet.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PaywallModalScreen(),
    );
  }

  @override
  ConsumerState<PaywallModalScreen> createState() => _PaywallModalScreenState();
}

class _PaywallModalScreenState extends ConsumerState<PaywallModalScreen> {
  String? _selectedPackageId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final productsAsync = ref.watch(proProductsProvider);
    final paywallState = ref.watch(paywallControllerProvider);
    final isLoading = paywallState.isLoading;

    final backgroundColor = isDark ? const Color(0xFF141417) : const Color(0xFFF9F9FB);
    final cardColor = isDark ? const Color(0xFF1E1E24) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 24,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: AppTheme.spacingMd),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top drag handle & Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  IconButton(
                    key: const Key('paywall_close_button'),
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingSm),

              // Header Crown & Glow
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
                    Icons.workspace_premium_rounded,
                    size: 34,
                    color: Color(0xFF2E1C00),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),

              // Title & Subtitle
              Text(
                l10n.proUpgradeTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: AppTheme.spacingXs),
              Text(
                l10n.proUpgradeSubtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppTheme.spacingLg),

              // Benefits List
              _BenefitItem(
                icon: Icons.fitness_center_rounded,
                title: l10n.proBenefitUnlimitedWorkoutsTitle,
                subtitle: l10n.proBenefitUnlimitedWorkoutsDesc,
              ),
              const SizedBox(height: AppTheme.spacingSm),
              _BenefitItem(
                icon: Icons.block_rounded,
                title: l10n.proBenefitZeroAdsTitle,
                subtitle: l10n.proBenefitZeroAdsDesc,
              ),
              const SizedBox(height: AppTheme.spacingSm),
              _BenefitItem(
                icon: Icons.sports_rounded,
                title: l10n.proBenefitSfxClipsTitle,
                subtitle: l10n.proBenefitSfxClipsDesc,
              ),
              const SizedBox(height: AppTheme.spacingSm),
              _BenefitItem(
                icon: Icons.palette_rounded,
                title: l10n.proBenefitPhaseColorsTitle,
                subtitle: l10n.proBenefitPhaseColorsDesc,
              ),
              const SizedBox(height: AppTheme.spacingSm),
              _BenefitItem(
                icon: Icons.edit_note_rounded,
                title: l10n.proBenefitCalendarNotesTitle,
                subtitle: l10n.proBenefitCalendarNotesDesc,
              ),
              const SizedBox(height: AppTheme.spacingLg),

              // Subscription packages
              productsAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppTheme.spacingMd),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, _) => Center(
                  child: Text(
                    err.toString(),
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
                data: (products) {
                  if (products.isEmpty) return const SizedBox.shrink();

                  // Default select annual if not already set
                  final defaultPackage = products.firstWhere(
                    (p) => p.period == BillingPeriod.annual,
                    orElse: () => products.first,
                  );
                  final selectedId = _selectedPackageId ?? defaultPackage.id;
                  final selectedPackage = products.firstWhere(
                    (p) => p.id == selectedId,
                    orElse: () => products.first,
                  );

                  return Column(
                    children: [
                      ...products.map((package) {
                        final isSelected = package.id == selectedId;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
                          child: _PackageCard(
                            package: package,
                            isSelected: isSelected,
                            cardColor: cardColor,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedPackageId = package.id);
                            },
                          ),
                        );
                      }),
                      const SizedBox(height: AppTheme.spacingMd),

                      // CTA Button
                      if (isLoading)
                        const SizedBox(
                          height: AppTheme.buttonMinHeight,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else
                        AppPrimaryButton(
                          key: const Key('paywall_primary_cta'),
                          onPressed: () => _handlePurchase(context, selectedPackage),
                          label: _getCtaLabel(l10n, selectedPackage),
                        ),
                    ],
                  );
                },
              ),

              const SizedBox(height: AppTheme.spacingSm),

              // Restore purchases button
              Center(
                child: TextButton(
                  key: const Key('paywall_restore_button'),
                  onPressed: isLoading ? null : () => _handleRestore(context),
                  child: Text(
                    l10n.proRestorePurchases,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),

              // Legal disclaimers
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm),
                child: Text(
                  l10n.proLegalNotice,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.proTerms,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      decoration: TextDecoration.underline,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Text(
                    l10n.proPrivacy,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      decoration: TextDecoration.underline,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCtaLabel(dynamic l10n, ProductPackage package) {
    if (package.hasFreeTrial) {
      return l10n.proStartFreeTrial;
    }
    if (package.period == BillingPeriod.lifetime) {
      return l10n.proUnlockLifetime;
    }
    return l10n.proSubscribe;
  }

  Future<void> _handlePurchase(BuildContext context, ProductPackage package) async {
    HapticFeedback.mediumImpact();
    final result = await ref.read(paywallControllerProvider.notifier).purchase(package);
    if (!mounted) return;

    if (result.status == PurchaseStatus.success) {
      AppSnackBar.showSuccess(context, message: context.l10n.proPurchaseSuccess);
      Navigator.of(context).pop();
    } else if (result.status == PurchaseStatus.error && result.errorMessage != null) {
      AppSnackBar.showError(context, message: result.errorMessage!);
    }
  }

  Future<void> _handleRestore(BuildContext context) async {
    HapticFeedback.lightImpact();
    final result = await ref.read(paywallControllerProvider.notifier).restorePurchases();
    if (!mounted) return;

    if (result.status == PurchaseStatus.success) {
      AppSnackBar.showSuccess(context, message: context.l10n.proRestoreSuccess);
      Navigator.of(context).pop();
    } else if (result.status == PurchaseStatus.error && result.errorMessage != null) {
      AppSnackBar.showError(context, message: result.errorMessage!);
    }
  }
}

class _BenefitItem extends StatelessWidget {
  const _BenefitItem({
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
            color: const Color(0xFFFFB300).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: const Color(0xFFFF8F00),
          ),
        ),
        const SizedBox(width: AppTheme.spacingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
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

class _PackageCard extends StatelessWidget {
  const _PackageCard({
    required this.package,
    required this.isSelected,
    required this.cardColor,
    required this.onTap,
  });

  final ProductPackage package;
  final bool isSelected;
  final Color cardColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final isAnnual = package.period == BillingPeriod.annual;

    final borderColor = isSelected
        ? const Color(0xFFFFB300)
        : theme.colorScheme.outlineVariant.withValues(alpha: 0.4);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFFB300).withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? const Color(0xFFFF8F00) : theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        package.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (isAnnual) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            l10n.proBestValue,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF2E1C00),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    package.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              package.priceFormatted,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

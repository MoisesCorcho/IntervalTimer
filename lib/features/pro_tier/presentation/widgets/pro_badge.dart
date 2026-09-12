import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/core/l10n/l10n_extension.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/features/pro_tier/application/pro_providers.dart';
import 'package:interval_timer/features/pro_tier/presentation/screens/paywall_modal_screen.dart';

/// Metallic gold micro-badge indicating Pro entitlement or Pro-locked features.
/// Automatically hides itself when the active user has Pro entitlement (unless [hideWhenPro] is false).
class ProBadge extends ConsumerWidget {
  const ProBadge({
    super.key,
    this.hideWhenPro = true,
    this.compact = false,
    this.onTap,
    this.margin,
  });

  /// Whether to automatically hide the badge when the user is Pro.
  final bool hideWhenPro;

  /// Whether to render a compact icon-only variant.
  final bool compact;

  /// Optional tap callback. Defaults to presenting the [PaywallModalScreen].
  final VoidCallback? onTap;

  /// Optional surrounding margin.
  final EdgeInsetsGeometry? margin;

  static const _goldGradient = LinearGradient(
    colors: [
      Color(0xFFFFD54F), // Amber 300
      Color(0xFFFF8F00), // Amber 800
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPro = ref.watch(isProUserProvider).valueOrNull ?? false;
    if (isPro && hideWhenPro) {
      return const SizedBox.shrink();
    }

    final l10n = context.l10n;

    Widget badge = Container(
      margin: margin,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 4.0 : 6.0,
        vertical: 2.0,
      ),
      decoration: BoxDecoration(
        gradient: _goldGradient,
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(
          color: const Color(0xFFFFECB3),
          width: 0.8,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33FF8F00),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.workspace_premium_rounded,
            size: 11,
            color: Color(0xFF3E2723), // Deep brown/black contrast on gold
          ),
          if (!compact) ...[
            const SizedBox(width: 3),
            Text(
              l10n.proBadge,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                color: Color(0xFF3E2723),
                height: 1.1,
              ),
            ),
          ],
        ],
      ),
    );

    return Semantics(
      label: l10n.proBadgeTooltip,
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(4.0),
        onTap: onTap ?? () => PaywallModalScreen.show(context),
        child: badge,
      ),
    );
  }
}

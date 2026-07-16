import 'package:flutter/material.dart';
import 'package:interval_timer/core/theme/app_theme.dart';

/// Primary CTA: solid fill, onPrimary label, soft **outer** shadow,
/// **rectangular** with subtle corner radius ([AppTheme.buttonRadius]).
///
/// Not a stadium/pill. Use for main actions: Iniciar, Guardar, etc.
/// Prefer [compact] inside [AlertDialog] actions for better proportion.
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.expand = false,
    this.compact = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;

  /// When true, stretches to parent width (e.g. inside [Expanded]).
  final bool expand;

  /// Denser padding for dialogs and tight rows (still ≥ 40dp touch height).
  final bool compact;

  /// Override fill (e.g. adaptive contrast color on timer). Defaults to primary.
  final Color? backgroundColor;

  /// Override label/icon color. Defaults to onPrimary.
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final enabled = onPressed != null;
    final bg = backgroundColor ?? colorScheme.primary;
    final fg = foregroundColor ?? colorScheme.onPrimary;
    final borderRadius = BorderRadius.circular(AppTheme.buttonRadius);
    final minHeight = compact ? 40.0 : AppTheme.buttonMinHeight;
    // Compact: tighter horizontal pad so two actions fit side-by-side in dialogs.
    final hPad = compact ? AppTheme.spacingSm + 4 : AppTheme.spacingMd + 4;
    final vPad = compact ? AppTheme.spacingSm : AppTheme.spacingSm + 2;

    final labelStyle = TextStyle(
      color: enabled ? fg : fg.withValues(alpha: 0.38),
      fontWeight: FontWeight.w600,
      fontSize: compact ? 14 : null,
    );

    final content = icon == null
        ? Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: labelStyle,
          )
        : Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: compact ? 18 : 20,
                color: enabled ? fg : fg.withValues(alpha: 0.38),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: labelStyle,
                ),
              ),
            ],
          );

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Container(
        width: expand ? double.infinity : null,
        decoration: BoxDecoration(
          color: enabled ? bg : bg.withValues(alpha: 0.38),
          borderRadius: borderRadius,
          boxShadow: enabled ? AppTheme.buttonShadowFor(context) : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            borderRadius: borderRadius,
            splashColor: fg.withValues(alpha: 0.12),
            highlightColor: fg.withValues(alpha: 0.06),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: minHeight,
                minWidth: expand ? double.infinity : 48,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: hPad,
                  vertical: vPad,
                ),
                child: Center(child: content),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Secondary action with the same rectangular + subtle-radius language as
/// [AppPrimaryButton], outlined / surface-toned (Cancel, Continuar, etc.).
class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.expand = false,
    this.compact = false,
  });

  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;
  final bool expand;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final enabled = onPressed != null;
    final fg = colorScheme.primary;
    final borderRadius = BorderRadius.circular(AppTheme.buttonRadius);
    final minHeight = compact ? 40.0 : AppTheme.buttonMinHeight;
    final hPad = compact ? AppTheme.spacingSm + 4 : AppTheme.spacingMd + 4;
    final vPad = compact ? AppTheme.spacingSm : AppTheme.spacingSm + 2;

    final labelStyle = TextStyle(
      color: enabled ? fg : fg.withValues(alpha: 0.38),
      fontWeight: FontWeight.w600,
      fontSize: compact ? 14 : null,
    );

    final content = icon == null
        ? Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: labelStyle,
          )
        : Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: compact ? 18 : 20,
                color: enabled ? fg : fg.withValues(alpha: 0.38),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: labelStyle,
                ),
              ),
            ],
          );

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Container(
        width: expand ? double.infinity : null,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: borderRadius,
          border: Border.all(
            color: enabled
                ? colorScheme.primary.withValues(alpha: 0.55)
                : colorScheme.outline.withValues(alpha: 0.35),
            width: 1.5,
          ),
          boxShadow: enabled ? AppTheme.buttonShadowFor(context) : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            borderRadius: borderRadius,
            splashColor: fg.withValues(alpha: 0.12),
            highlightColor: fg.withValues(alpha: 0.06),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: minHeight,
                minWidth: expand ? double.infinity : 48,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: hPad,
                  vertical: vPad,
                ),
                child: Center(child: content),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/core/theme/app_theme.dart';

/// Single source of truth for app name + logo used in share cards, MaterialApp, etc.
///
/// When renaming the product:
/// 1. Update [UiStrings.appTitle] and [UiStrings.appTagline]
/// 2. Replace [logoAsset] file under `assets/branding/`
///
/// Share templates and other UI must consume this class — do not hardcode names/logos.
abstract final class AppBranding {
  /// Display name (MaterialApp title, share footer, etc.).
  static String get displayName => UiStrings.appTitle;

  /// Short marketing line under the name on share cards.
  static String get tagline => UiStrings.appTagline;

  /// Path registered in `pubspec.yaml` under `flutter.assets`.
  static const String logoAsset = 'assets/branding/app_logo.png';

  /// Brand mark. Falls back to a timer icon if the asset is missing.
  static Widget logo({
    double size = 36,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
  }) {
    final radius = borderRadius ?? BorderRadius.circular(size * 0.22);
    return ClipRRect(
      borderRadius: radius,
      child: Image.asset(
        logoAsset,
        width: size,
        height: size,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: const LinearGradient(
                colors: [AppTheme.workColor, AppTheme.restColor],
              ),
            ),
            child: Icon(
              Icons.timer_outlined,
              size: size * 0.55,
              color: Colors.white,
            ),
          );
        },
      ),
    );
  }
}

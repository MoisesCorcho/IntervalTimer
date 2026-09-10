import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const spacingXs = 4.0;
  static const spacingSm = 8.0;
  static const spacingMd = 16.0;
  static const spacingLg = 24.0;

  static const radiusSm = 8.0;
  static const radiusMd = 12.0;
  static const radiusLg = 16.0;
  /// Soft premium containers (duration pickers, calm cards).
  static const radiusXl = 20.0;

  /// Primary action buttons: rectangular with subtle corner radius (not stadium/pill).
  /// Touch target ≥ 48dp; outer shadow for light depth (Tailwind-like, outside only).
  static const buttonElevation = 6.0;
  static const buttonMinHeight = 48.0;
  /// Same language as cards/controls: soft square, not fully rounded.
  static const buttonRadius = radiusSm;
  /// Outer shadow only — never an inset/inner look.
  static const buttonOuterShadow = [
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

  /// Dark mode shadow — white tint for visibility on dark surfaces.
  static const buttonOuterShadowDark = [
    BoxShadow(
      color: Color(0x26FFFFFF), // ~15% white
      blurRadius: 6,
      offset: Offset(0, 4),
      spreadRadius: -1,
    ),
    BoxShadow(
      color: Color(0x26FFFFFF),
      blurRadius: 4,
      offset: Offset(0, 2),
      spreadRadius: -2,
    ),
  ];

  /// Returns the appropriate button shadow for the current theme brightness.
  static List<BoxShadow> buttonShadowFor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? buttonOuterShadowDark
        : buttonOuterShadow;
  }

  /// Default primary brand seed color (athletic green).
  static const primaryColorArgb = 0xFF4CAF50;
  static const primaryColor = Color(primaryColorArgb);

  /// Default interval colors per type (ARGB).
  /// Work/rest use deeper tones so execution UI text/ring stay white
  /// ([contrastTextColor] → white when luminance ≤ 0.179), matching routine
  /// sessions on saturated backgrounds. Lighter Material 500 greens/blues
  /// force black text and looked inconsistent on the workout timer.
  static const warmupColorArgb = 0xFFFFC107;
  static const warmupColor = Color(warmupColorArgb);

  static const workColorArgb = 0xFF2E7D32; // Green 800
  static const workColor = Color(workColorArgb);

  static const restColorArgb = 0xFF1565C0; // Blue 800
  static const restColor = Color(restColorArgb);

  static const stretchColorArgb = 0xFF9C27B0;
  static const stretchColor = Color(stretchColorArgb);

  /// Fixed neutral dark slate grey for the preparation countdown.
  static const prepColorArgb = 0xFF2E3239;
  static const prepColor = Color(prepColorArgb);

  /// Curated athletic palette (10 shades) for customizable work and rest phases.
  static const phaseColorPresets = <Color>[
    workColor, // Forest Green (default work)
    restColor, // Deep Blue (default rest)
    Color(0xFFC62828), // Crimson Red
    Color(0xFFE65100), // Energy Orange
    Color(0xFF6A1B9A), // Deep Purple
    Color(0xFF00838F), // Cyan / Teal
    Color(0xFFFF8F00), // Amber Gold
    Color(0xFFAD1457), // Vivid Magenta
    Color(0xFF827717), // Volt / Lime
    Color(0xFF283593), // Navy / Indigo
  ];

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingMd,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        showDragHandle: true,
        backgroundColor: colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusLg)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: BorderSide(
            color: Colors.black.withValues(alpha: 0.08),
          ),
        ),
        backgroundColor: const Color(0xFF1E2124),
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        actionTextColor: colorScheme.primary,
        showCloseIcon: true,
        closeIconColor: Colors.white70,
      ),
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingMd,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        showDragHandle: true,
        backgroundColor: colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusLg)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.12),
          ),
        ),
        backgroundColor: const Color(0xFF2C3036),
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        actionTextColor: colorScheme.primary,
        showCloseIcon: true,
        closeIconColor: Colors.white70,
      ),
    );
  }

  static TextStyle timerDisplayStyle(BuildContext context) {
    return Theme.of(context).textTheme.headlineLarge!.copyWith(
          fontFamily: 'RobotoMono',
          fontFeatures: const [FontFeature.tabularFigures()],
          fontWeight: FontWeight.bold,
        );
  }
}
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

  /// Default interval colors per type (ARGB).
  static const warmupColor = Color(0xFFFFC107);
  static const workColor = Color(0xFF4CAF50);
  static const restColor = Color(0xFF2196F3);
  static const stretchColor = Color(0xFF9C27B0);

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF4CAF50),
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
          vertical: spacingSm,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
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
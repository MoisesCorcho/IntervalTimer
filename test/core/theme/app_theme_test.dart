import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/core/theme/app_theme.dart';

void main() {
  group('AppTheme snackBarTheme', () {
    test('light theme configures floating, dark background and primary action color', () {
      final theme = AppTheme.light();
      final snackBarTheme = theme.snackBarTheme;

      expect(snackBarTheme.behavior, SnackBarBehavior.floating);
      expect(snackBarTheme.shape, isA<RoundedRectangleBorder>());
      final shape = snackBarTheme.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(AppTheme.radiusMd));

      // Background should be dark charcoal (not white) in light mode
      expect(snackBarTheme.backgroundColor, isNotNull);
      expect(snackBarTheme.backgroundColor!.computeLuminance(), lessThan(0.2));

      // Action text color should match primary
      expect(snackBarTheme.actionTextColor, theme.colorScheme.primary);
    });

    test('dark theme configures floating, non-white dark elevated background, and primary action color', () {
      final theme = AppTheme.dark();
      final snackBarTheme = theme.snackBarTheme;

      expect(snackBarTheme.behavior, SnackBarBehavior.floating);
      expect(snackBarTheme.shape, isA<RoundedRectangleBorder>());
      final shape = snackBarTheme.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(AppTheme.radiusMd));

      // Background must NOT be white in dark mode; it should be dark elevated surface
      expect(snackBarTheme.backgroundColor, isNotNull);
      expect(snackBarTheme.backgroundColor, isNot(Colors.white));
      expect(snackBarTheme.backgroundColor!.computeLuminance(), lessThan(0.2));

      // Action text color should match primary
      expect(snackBarTheme.actionTextColor, theme.colorScheme.primary);
    });
  });
}

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

    test('light and dark themes respect custom primaryColor seed', () {
      const customPrimary = Color(0xFF00BCD4); // Electric Cyan
      final lightTheme = AppTheme.light(primaryColor: customPrimary);
      final darkTheme = AppTheme.dark(primaryColor: customPrimary);

      // ColorScheme generated from custom seed
      expect(lightTheme.colorScheme.primary, ColorScheme.fromSeed(seedColor: customPrimary, brightness: Brightness.light).primary);
      expect(darkTheme.colorScheme.primary, ColorScheme.fromSeed(seedColor: customPrimary, brightness: Brightness.dark).primary);
      expect(lightTheme.floatingActionButtonTheme.backgroundColor, lightTheme.colorScheme.primary);
    });

    test('accentColorPresets contains default primary color and curated options', () {
      expect(AppTheme.accentColorPresets, isNotEmpty);
      expect(AppTheme.accentColorPresets, contains(AppTheme.primaryColor));
      expect(AppTheme.accentColorPresets.first, AppTheme.primaryColor);
      expect(AppTheme.accentColorPresets, contains(const Color(0xFF4CAF50))); // Green
    });
  });

  group('AppTheme cardTheme (Contrast & Border)', () {
    test('light theme configures surfaceContainer background and outlineVariant border for card items', () {
      final theme = AppTheme.light();
      final cardTheme = theme.cardTheme;

      expect(cardTheme.color, theme.colorScheme.surfaceContainer);
      expect(cardTheme.elevation, 0);
      expect(cardTheme.shape, isA<RoundedRectangleBorder>());
      final shape = cardTheme.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(AppTheme.radiusMd));
      expect(shape.side.color, theme.colorScheme.outlineVariant.withValues(alpha: 0.45));
      expect(shape.side.width, 1.0);
    });

    test('dark theme configures surfaceContainer background and subtle outlineVariant border for card items', () {
      final theme = AppTheme.dark();
      final cardTheme = theme.cardTheme;

      expect(cardTheme.color, theme.colorScheme.surfaceContainer);
      expect(cardTheme.elevation, 0);
      expect(cardTheme.shape, isA<RoundedRectangleBorder>());
      final shape = cardTheme.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(AppTheme.radiusMd));
      expect(shape.side.color, theme.colorScheme.outlineVariant.withValues(alpha: 0.35));
      expect(shape.side.width, 1.0);
    });

    testWidgets('Card widget inside light theme inherits cardTheme surfaceContainer and border on underlying Material', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(
            body: Card(
              child: Text('Item'),
            ),
          ),
        ),
      );

      final material = tester.widget<Material>(
        find.descendant(of: find.byType(Card), matching: find.byType(Material)).first,
      );
      final theme = AppTheme.light();
      expect(material.color, theme.colorScheme.surfaceContainer);
      expect(material.elevation, 0.0);
      expect(material.shape, isA<RoundedRectangleBorder>());
      final shape = material.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(AppTheme.radiusMd));
      expect(shape.side.style, BorderStyle.solid);
      expect(shape.side.width, 1.0);
      expect(shape.side.color, theme.colorScheme.outlineVariant.withValues(alpha: 0.45));
    });

    testWidgets('Card widget inside dark theme inherits cardTheme surfaceContainer and border on underlying Material', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: const Scaffold(
            body: Card(
              child: Text('Item'),
            ),
          ),
        ),
      );

      final material = tester.widget<Material>(
        find.descendant(of: find.byType(Card), matching: find.byType(Material)).first,
      );
      final theme = AppTheme.dark();
      expect(material.color, theme.colorScheme.surfaceContainer);
      expect(material.elevation, 0.0);
      expect(material.shape, isA<RoundedRectangleBorder>());
      final shape = material.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(AppTheme.radiusMd));
      expect(shape.side.style, BorderStyle.solid);
      expect(shape.side.width, 1.0);
      expect(shape.side.color, theme.colorScheme.outlineVariant.withValues(alpha: 0.35));
    });
  });
}

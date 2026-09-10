import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/core/l10n/app_localizations.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/features/settings/presentation/widgets/phase_color_picker_sheet.dart';
import 'package:interval_timer/shared/widgets/countdown_ring.dart';

void main() {
  Widget buildTestWidget({
    required String title,
    required Color initialColor,
    required Color defaultColor,
    required ValueChanged<Color> onColorSelected,
  }) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es')],
      locale: const Locale('es'),
      home: Scaffold(
        body: PhaseColorPickerSheet(
          title: title,
          initialColor: initialColor,
          defaultColor: defaultColor,
          onColorSelected: onColorSelected,
        ),
      ),
    );
  }

  group('PhaseColorPickerSheet', () {
    testWidgets('renders title, preview card, 10 swatches, and action buttons',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          title: 'Color de Trabajo',
          initialColor: AppTheme.workColor,
          defaultColor: AppTheme.workColor,
          onColorSelected: (_) {},
        ),
      );
      await tester.pump();

      expect(find.text('Color de Trabajo'), findsWidgets);
      expect(find.byKey(const Key('phase_color_preview_card')), findsOneWidget);

      // Verify all 10 preset swatches are rendered
      for (final color in AppTheme.phaseColorPresets) {
        final key = Key('color_swatch_${color.toARGB32()}');
        expect(find.byKey(key), findsOneWidget);
      }

      expect(find.byKey(const Key('reset_color_button')), findsOneWidget);
      expect(find.byKey(const Key('save_color_button')), findsOneWidget);
    });

    testWidgets('preview renders miniature timer execution screen mockup with countdown ring and controls',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          title: 'Color de Trabajo',
          initialColor: AppTheme.workColor,
          defaultColor: AppTheme.workColor,
          onColorSelected: (_) {},
        ),
      );
      await tester.pump();

      // Verify preview card exists and is wrapped in IgnorePointer
      final previewFinder = find.byKey(const Key('phase_color_preview_card'));
      expect(previewFinder, findsOneWidget);

      final ignorePointer = tester.widget<IgnorePointer>(
        find.byKey(const Key('preview_mockup_ignore_pointer')),
      );
      expect(ignorePointer.ignoring, isTrue);

      // Verify miniature top bar components
      expect(find.byKey(const Key('preview_mockup_top_bar')), findsOneWidget);

      // Verify countdown ring and animated countdown display
      expect(find.byType(CountdownRing), findsOneWidget);
      expect(find.byKey(const Key('preview_mockup_countdown')), findsOneWidget);

      // Verify next segment card mockup
      expect(find.byKey(const Key('preview_mockup_next_segment')), findsOneWidget);

      // Verify bottom controls mockup
      expect(find.byKey(const Key('preview_mockup_controls')), findsOneWidget);

      // Verify countdown advances as animation ticks
      final initialText = tester
          .widget<Text>(find.byKey(const Key('preview_mockup_countdown')))
          .data;
      await tester.pump(const Duration(seconds: 3));
      final nextText = tester
          .widget<Text>(find.byKey(const Key('preview_mockup_countdown')))
          .data;
      expect(initialText, isNotNull);
      expect(nextText, isNotNull);
      expect(initialText != nextText, isTrue);
    });

    testWidgets('tapping a swatch updates preview card color', (tester) async {
      Color? selected;
      const crimson = Color(0xFFC62828);

      await tester.pumpWidget(
        buildTestWidget(
          title: 'Color de Trabajo',
          initialColor: AppTheme.workColor,
          defaultColor: AppTheme.workColor,
          onColorSelected: (c) => selected = c,
        ),
      );
      await tester.pump();

      // Tap on Crimson swatch
      await tester.tap(find.byKey(Key('color_swatch_${crimson.toARGB32()}')));
      await tester.pump();

      // Verify preview card background is now crimson
      final previewCard = tester.widget<Container>(
        find.byKey(const Key('phase_color_preview_card')),
      );
      final decoration = previewCard.decoration as BoxDecoration;
      expect(decoration.color, crimson);

      // Tap save
      await tester.tap(find.byKey(const Key('save_color_button')));
      await tester.pump();

      expect(selected, crimson);
    });

    testWidgets('reset button restores default color', (tester) async {
      const crimson = Color(0xFFC62828);
      Color? saved;

      await tester.pumpWidget(
        buildTestWidget(
          title: 'Color de Trabajo',
          initialColor: crimson,
          defaultColor: AppTheme.workColor,
          onColorSelected: (c) => saved = c,
        ),
      );
      await tester.pump();

      // Tap Reset
      await tester.tap(find.byKey(const Key('reset_color_button')));
      await tester.pump();

      final previewCard = tester.widget<Container>(
        find.byKey(const Key('phase_color_preview_card')),
      );
      final decoration = previewCard.decoration as BoxDecoration;
      expect(decoration.color, AppTheme.workColor);

      // Tap Save
      await tester.tap(find.byKey(const Key('save_color_button')));
      await tester.pump();

      expect(saved, AppTheme.workColor);
    });
  });
}

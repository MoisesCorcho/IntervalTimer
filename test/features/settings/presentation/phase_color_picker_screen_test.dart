import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/core/l10n/app_localizations.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/features/settings/presentation/phase_color_picker_screen.dart';
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
      home: PhaseColorPickerScreen(
        title: title,
        initialColor: initialColor,
        defaultColor: defaultColor,
        onColorSelected: onColorSelected,
      ),
    );
  }

  group('PhaseColorPickerScreen', () {
    testWidgets('renders phone mockup with exact TimerExecutionScreen components',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          title: 'Color de trabajo',
          initialColor: AppTheme.workColor,
          defaultColor: AppTheme.workColor,
          onColorSelected: (_) {},
        ),
      );
      await tester.pump();

      // Verify phone device frame exists and is non-interactive
      final phoneFrame = find.byKey(const Key('preview_phone_frame'));
      expect(phoneFrame, findsOneWidget);

      final ignorePointer = tester.widget<IgnorePointer>(
        find.byKey(const Key('preview_phone_ignore_pointer')),
      );
      expect(ignorePointer.ignoring, isTrue);

      // Verify exact components from TimerExecutionScreen screenshot:
      // 1. Top bar with square rounded buttons and 01:15 total time
      expect(find.byKey(const Key('preview_phone_top_bar')), findsOneWidget);
      expect(find.text('01:15'), findsOneWidget);
      expect(find.text('RESTANTE'), findsOneWidget);

      // 2. Centered bold phase title
      expect(find.byKey(const Key('preview_phone_phase_title')), findsOneWidget);

      // 3. Countdown ring with animated display
      expect(find.byType(CountdownRing), findsOneWidget);
      expect(find.byKey(const Key('preview_phone_countdown')), findsOneWidget);

      // 4. Next segment card with ABDOMEN and duration 00:10
      expect(find.byKey(const Key('preview_phone_next_segment')), findsOneWidget);
      expect(find.text('ABDOMEN'), findsOneWidget);
      expect(find.text('00:10'), findsOneWidget);

      // 5. Control bar with previous, filled Pausar button, and next
      expect(find.byKey(const Key('preview_phone_controls')), findsOneWidget);
      expect(find.text('Pausar'), findsOneWidget);

      // 6. 10 curated swatches
      for (final color in AppTheme.phaseColorPresets) {
        expect(find.byKey(Key('color_swatch_${color.toARGB32()}')), findsOneWidget);
      }

      // 7. Action buttons
      expect(find.byKey(const Key('reset_color_button')), findsOneWidget);
      expect(find.byKey(const Key('save_color_button')), findsOneWidget);
    });

    testWidgets('animated countdown in phone mockup counts down and loops',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          title: 'Color de trabajo',
          initialColor: AppTheme.workColor,
          defaultColor: AppTheme.workColor,
          onColorSelected: (_) {},
        ),
      );
      await tester.pump();

      final initialText = tester
          .widget<Text>(find.byKey(const Key('preview_phone_countdown')))
          .data;
      await tester.pump(const Duration(seconds: 2));
      final nextText = tester
          .widget<Text>(find.byKey(const Key('preview_phone_countdown')))
          .data;

      expect(initialText, isNotNull);
      expect(nextText, isNotNull);
      expect(initialText != nextText, isTrue);
    });

    testWidgets('tapping swatch updates phone mockup background color',
        (tester) async {
      Color? selected;
      const crimson = Color(0xFFC62828);

      await tester.pumpWidget(
        buildTestWidget(
          title: 'Color de trabajo',
          initialColor: AppTheme.workColor,
          defaultColor: AppTheme.workColor,
          onColorSelected: (c) => selected = c,
        ),
      );
      await tester.pump();

      // Tap crimson swatch
      await tester.tap(find.byKey(Key('color_swatch_${crimson.toARGB32()}')));
      await tester.pump();

      // Verify phone screen container color is updated to crimson
      final screenContainer = tester.widget<Container>(
        find.byKey(const Key('preview_phone_screen_canvas')),
      );
      final decoration = screenContainer.decoration as BoxDecoration;
      expect(decoration.color, crimson);

      // Tap save
      await tester.ensureVisible(find.byKey(const Key('save_color_button')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('save_color_button')));
      await tester.pump();

      expect(selected, crimson);
    });

    testWidgets('reset button restores default color on phone screen canvas',
        (tester) async {
      const crimson = Color(0xFFC62828);
      Color? saved;

      await tester.pumpWidget(
        buildTestWidget(
          title: 'Color de trabajo',
          initialColor: crimson,
          defaultColor: AppTheme.workColor,
          onColorSelected: (c) => saved = c,
        ),
      );
      await tester.pump();

      // Tap Reset
      await tester.ensureVisible(find.byKey(const Key('reset_color_button')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('reset_color_button')));
      await tester.pump();

      final screenContainer = tester.widget<Container>(
        find.byKey(const Key('preview_phone_screen_canvas')),
      );
      final decoration = screenContainer.decoration as BoxDecoration;
      expect(decoration.color, AppTheme.workColor);

      // Tap Save
      await tester.ensureVisible(find.byKey(const Key('save_color_button')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('save_color_button')));
      await tester.pump();

      expect(saved, AppTheme.workColor);
    });
  });
}
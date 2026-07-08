import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/features/timer/presentation/widgets/interval_form.dart';
import 'package:interval_timer/shared/widgets/interval_duration_picker.dart';


void main() {
  testWidgets('rejects empty name and name >50 chars', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: IntervalForm(
              defaultColorArgb: 0xFF4CAF50,
              onSubmit: (_) {},
            ),
          ),
        ),
      ),
    );

    final nameField = find.byKey(const Key('interval_name_field'));
    final saveButton = find.byKey(const Key('interval_save_button'));

    await tester.enterText(nameField, '');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pump();

    expect(find.text(UiStrings.nameRequired), findsOneWidget);

    await tester.enterText(nameField, 'a' * 51);
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pump();

    expect(find.text(UiStrings.nameTooLong), findsOneWidget);
  });

  testWidgets('duration uses IntervalDurationPicker; cannot set 00:00 via UI', (
    tester,
  ) async {
    IntervalFormResult? result;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: IntervalForm(
              defaultColorArgb: 0xFF4CAF50,
              onSubmit: (r) => result = r,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(IntervalDurationPicker), findsOneWidget);
    expect(find.byKey(const Key('interval_duration_field')), findsNothing);
    expect(find.text('01:00'), findsOneWidget);

    // Drive duration down toward minimum (1s) using -5s repeatedly.
    for (var i = 0; i < 20; i++) {
      final secDec = find.byKey(
        const Key('interval_duration_duration_stepper_sec_decrement'),
      );
      await tester.ensureVisible(secDec);
      final button = tester.widget<IconButton>(
        find.descendant(of: secDec, matching: find.byType(IconButton)),
      );
      if (button.onPressed == null) break;
      await tester.tap(secDec);
      await tester.pumpAndSettle();
    }

    // Also drain minutes if still above 1s.
    for (var i = 0; i < 5; i++) {
      final minDec = find.byKey(
        const Key('interval_duration_duration_stepper_min_decrement'),
      );
      await tester.ensureVisible(minDec);
      final button = tester.widget<IconButton>(
        find.descendant(of: minDec, matching: find.byType(IconButton)),
      );
      if (button.onPressed == null) break;
      await tester.tap(minDec);
      await tester.pumpAndSettle();
    }

    // At min, further - must stay disabled; never show 00:00 for interval.
    expect(find.text('00:00'), findsNothing);

    final secDecAtMin = tester.widget<IconButton>(
      find.descendant(
        of: find.byKey(
          const Key('interval_duration_duration_stepper_sec_decrement'),
        ),
        matching: find.byType(IconButton),
      ),
    );
    expect(secDecAtMin.onPressed, isNull);

    await tester.enterText(
      find.byKey(const Key('interval_name_field')),
      'Work',
    );
    final saveButton = find.byKey(const Key('interval_save_button'));
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pump();

    expect(result, isNotNull);
    expect(result!.durationSeconds, greaterThanOrEqualTo(1));
    expect(result!.durationSeconds, lessThanOrEqualTo(5));
  });
}


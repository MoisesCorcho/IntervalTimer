import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/features/timer/presentation/widgets/interval_form.dart';

void main() {
  testWidgets('rejects empty name, name >50 chars, and 00:00 duration', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: IntervalForm(
            defaultColorArgb: 0xFF4CAF50,
            onSubmit: (_) {},
          ),
        ),
      ),
    );

    final nameField = find.byKey(const Key('interval_name_field'));
    final durationField = find.byKey(const Key('interval_duration_field'));
    final saveButton = find.byKey(const Key('interval_save_button'));

    await tester.enterText(nameField, '');
    await tester.enterText(durationField, '00:00');
    await tester.tap(saveButton);
    await tester.pump();

    expect(find.text(UiStrings.nameRequired), findsOneWidget);
    expect(find.text(UiStrings.durationInvalid), findsOneWidget);

    await tester.enterText(nameField, 'a' * 51);
    await tester.tap(saveButton);
    await tester.pump();

    expect(find.text(UiStrings.nameTooLong), findsOneWidget);
  });
}
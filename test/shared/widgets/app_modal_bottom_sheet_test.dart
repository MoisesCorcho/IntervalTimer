import 'package:flutter/material.dart' hide Interval;
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/features/timer/presentation/widgets/interval_form.dart';
import 'package:interval_timer/features/workout_builder/presentation/widgets/exercise_form.dart';
import 'package:interval_timer/shared/widgets/app_modal_bottom_sheet.dart';

void main() {
  test('AppTheme defines bottomSheetTheme with showDragHandle in light and dark', () {
    final light = AppTheme.light();
    final dark = AppTheme.dark();

    expect(light.bottomSheetTheme.showDragHandle, isTrue);
    expect(dark.bottomSheetTheme.showDragHandle, isTrue);
    expect(light.bottomSheetTheme.shape, isA<RoundedRectangleBorder>());
    expect(dark.bottomSheetTheme.shape, isA<RoundedRectangleBorder>());
  });

  testWidgets('showAppModalBottomSheet configures drag handle, height constraint and padding', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showAppModalBottomSheet<void>(
                context: context,
                builder: (sheetContext) => const SizedBox(
                  height: 3000,
                  child: Text('Sheet Content'),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final bottomSheetFinder = find.byType(BottomSheet);
    expect(bottomSheetFinder, findsOneWidget);
    final bottomSheet = tester.widget<BottomSheet>(bottomSheetFinder);
    expect(bottomSheet.showDragHandle, isTrue);

    // Height constraint test: 85% of 2400 is 2040, top clearance must be >= 360 (15%)
    final sheetTopLeft = tester.getTopLeft(bottomSheetFinder);
    expect(sheetTopLeft.dy, greaterThanOrEqualTo(2400 * 0.15 - 1));

    // Horizontal padding test (AppTheme.spacingMd)
    final contentFinder = find.text('Sheet Content');
    expect(contentFinder, findsOneWidget);
    final contentTopLeft = tester.getTopLeft(contentFinder);
    expect(contentTopLeft.dx, greaterThanOrEqualTo(AppTheme.spacingMd));
  });

  testWidgets('showAppModalBottomSheet adjusts with keyboard viewInsets', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    tester.view.viewInsets = const FakeViewPadding(bottom: 600);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.view.resetViewInsets();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showAppModalBottomSheet<void>(
                context: context,
                builder: (sheetContext) => const Text('Field'),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final paddingFinder = find.byWidgetPredicate(
      (widget) => widget is Padding && widget.padding == const EdgeInsets.only(bottom: 600),
    );
    expect(paddingFinder, findsOneWidget);
  });

  testWidgets('ExerciseForm in showAppModalBottomSheet has horizontal margin and top clearance on Poco X5 Pro', (
    tester,
  ) async {
    // Xiaomi Poco X5 Pro: 1080 x 2400 physical
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showAppModalBottomSheet<void>(
                context: context,
                builder: (sheetContext) => ExerciseForm(onSubmit: (_) {}),
              ),
              child: const Text('Open Exercise Sheet'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Exercise Sheet'));
    await tester.pumpAndSettle();

    final bottomSheetFinder = find.byType(BottomSheet);
    expect(bottomSheetFinder, findsOneWidget);

    // Verify top clearance >= 15% (does not stick to top edge/cutout)
    final sheetTopLeft = tester.getTopLeft(bottomSheetFinder);
    expect(sheetTopLeft.dy, greaterThanOrEqualTo(2400 * 0.15 - 1));

    // Verify ExerciseForm input has horizontal padding >= spacingMd from screen edge
    final fieldFinder = find.byKey(const Key('exercise_name_field'));
    expect(fieldFinder, findsOneWidget);
    final fieldTopLeft = tester.getTopLeft(fieldFinder);
    expect(fieldTopLeft.dx, greaterThanOrEqualTo(AppTheme.spacingMd));

    final fieldBottomRight = tester.getBottomRight(fieldFinder);
    expect(1080 - fieldBottomRight.dx, greaterThanOrEqualTo(AppTheme.spacingMd));
  });

  testWidgets('IntervalForm in showAppModalBottomSheet has horizontal margin and top clearance', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showAppModalBottomSheet<void>(
                context: context,
                builder: (sheetContext) => IntervalForm(
                  onSubmit: (_) {},
                  defaultColorArgb: AppTheme.workColor.toARGB32(),
                ),
              ),
              child: const Text('Open Interval Sheet'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Interval Sheet'));
    await tester.pumpAndSettle();

    final bottomSheetFinder = find.byType(BottomSheet);
    expect(bottomSheetFinder, findsOneWidget);

    // Verify top clearance >= 15%
    final sheetTopLeft = tester.getTopLeft(bottomSheetFinder);
    expect(sheetTopLeft.dy, greaterThanOrEqualTo(2400 * 0.15 - 1));

    // Verify IntervalForm field has horizontal padding >= spacingMd from screen edge
    final fieldFinder = find.byKey(const Key('interval_name_field'));
    expect(fieldFinder, findsOneWidget);
    final fieldTopLeft = tester.getTopLeft(fieldFinder);
    expect(fieldTopLeft.dx, greaterThanOrEqualTo(AppTheme.spacingMd));
  });
}

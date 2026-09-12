import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/core/l10n/app_localizations.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/repositories/preferences_repository.dart';
import 'package:interval_timer/features/pro_tier/application/pro_providers.dart';
import 'package:interval_timer/features/pro_tier/data/fake_billing_driver.dart';
import 'package:interval_timer/features/pro_tier/presentation/screens/paywall_modal_screen.dart';
import 'package:interval_timer/features/workout_builder/application/workout_providers.dart';

void main() {
  late AppDatabase db;
  late PreferencesRepository prefs;
  late FakeBillingDriver driver;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    prefs = PreferencesRepository(db);
    driver = FakeBillingDriver(preferencesRepository: prefs);
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [
        preferencesRepositoryProvider.overrideWithValue(prefs),
        billingRepositoryProvider.overrideWithValue(driver),
      ],
      child: const MaterialApp(
        locale: Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PaywallModalScreen(),
        ),
      ),
    );
  }

  testWidgets('PaywallModalScreen renders header, benefits, packages, and CTA (R4, R5, R6)', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Verify Title & Crown
    expect(find.byIcon(Icons.workspace_premium_rounded), findsWidgets);
    expect(find.text('Desbloquea Interval Timer Pro'), findsOneWidget);

    // Verify 5 Benefits
    expect(find.byIcon(Icons.fitness_center_rounded), findsOneWidget);
    expect(find.byIcon(Icons.block_rounded), findsOneWidget);
    expect(find.byIcon(Icons.sports_rounded), findsOneWidget);
    expect(find.byIcon(Icons.palette_rounded), findsOneWidget);
    expect(find.byIcon(Icons.edit_note_rounded), findsOneWidget);

    // Verify 3 Packages
    expect(find.text('Mensual'), findsOneWidget);
    expect(find.text('Anual'), findsOneWidget);
    expect(find.text('De por vida'), findsOneWidget);

    // Verify Annual highlighted with best value tag
    expect(find.text('MEJOR VALOR'), findsOneWidget);

    // Verify CTA and restore button
    expect(find.byKey(const Key('paywall_primary_cta')), findsOneWidget);
    expect(find.byKey(const Key('paywall_restore_button')), findsOneWidget);
  });

  testWidgets('Selecting a package updates the selection and CTA label (R5, R6)', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Annual is selected by default, offering free trial
    expect(find.text('COMENZAR 7 DÍAS GRATIS'), findsOneWidget);

    // Tap Lifetime package
    await tester.tap(find.text('De por vida'));
    await tester.pumpAndSettle();

    expect(find.text('DESBLOQUEAR ACCESO DE POR VIDA'), findsOneWidget);

    // Tap Monthly package
    await tester.tap(find.text('Mensual'));
    await tester.pumpAndSettle();

    expect(find.text('DESBLOQUEAR PRO'), findsOneWidget);
  });

  testWidgets('Tapping CTA executes purchase and enables Pro (R6, R8)', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(await prefs.isProUser(), isFalse);

    await tester.tap(find.byKey(const Key('paywall_primary_cta')));
    await tester.pumpAndSettle();

    expect(await prefs.isProUser(), isTrue);
  });

  testWidgets('Tapping restore purchases successfully restores Pro (R7, R12)', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    driver.hasPriorPurchase = true;
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(await prefs.isProUser(), isFalse);

    await tester.tap(find.byKey(const Key('paywall_restore_button')));
    await tester.pumpAndSettle();

    expect(await prefs.isProUser(), isTrue);
  });
}

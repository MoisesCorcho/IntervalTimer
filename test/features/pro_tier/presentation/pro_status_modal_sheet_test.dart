import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/core/l10n/app_localizations.dart';
import 'package:interval_timer/features/pro_tier/presentation/screens/pro_status_modal_sheet.dart';

void main() {
  Widget buildTestWidget({Locale locale = const Locale('es')}) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(
        body: ProStatusModalSheet(),
      ),
    );
  }

  testWidgets('ProStatusModalSheet renders active state, benefits, and dismiss button (R19)', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Verify Active Pro header
    expect(find.byIcon(Icons.verified_rounded), findsWidgets);
    expect(find.text('Pro Activo'), findsOneWidget);
    expect(find.text('Membresía Activa'), findsOneWidget);

    // Verify 6 active benefits are displayed
    expect(find.byIcon(Icons.fitness_center_rounded), findsOneWidget);
    expect(find.byIcon(Icons.straighten_rounded), findsOneWidget);
    expect(find.byIcon(Icons.block_rounded), findsOneWidget);
    expect(find.byIcon(Icons.sports_rounded), findsOneWidget);
    expect(find.byIcon(Icons.palette_rounded), findsOneWidget);
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);

    // Verify NO purchase packages, pricing, or payment CTAs
    expect(find.text('Mensual'), findsNothing);
    expect(find.text('Anual'), findsNothing);
    expect(find.text('De por vida'), findsNothing);
    expect(find.byKey(const Key('paywall_primary_cta')), findsNothing);

    // Verify management action and dismiss button
    expect(find.text('Administrar suscripción'), findsOneWidget);
    expect(find.text('Entendido'), findsOneWidget);

    // Tap dismiss button
    await tester.tap(find.text('Entendido'));
    await tester.pumpAndSettle();
  });
}

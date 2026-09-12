import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/core/l10n/app_localizations.dart';
import 'package:interval_timer/features/pro_tier/application/pro_providers.dart';
import 'package:interval_timer/features/pro_tier/presentation/widgets/pro_badge.dart';

void main() {
  Widget buildTestWidget({
    required bool isPro,
    bool hideWhenPro = true,
    bool compact = false,
    VoidCallback? onTap,
  }) {
    return ProviderScope(
      overrides: [
        isProUserProvider.overrideWith((ref) => Stream.value(isPro)),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ProBadge(
            hideWhenPro: hideWhenPro,
            compact: compact,
            onTap: onTap,
          ),
        ),
      ),
    );
  }

  testWidgets('ProBadge is visible when user is Free', (tester) async {
    await tester.pumpWidget(buildTestWidget(isPro: false));
    await tester.pumpAndSettle();

    expect(find.byType(ProBadge), findsOneWidget);
    expect(find.text('PRO'), findsOneWidget);
    expect(find.byIcon(Icons.workspace_premium_rounded), findsOneWidget);
  });

  testWidgets('ProBadge hides when user is Pro and hideWhenPro is true', (tester) async {
    await tester.pumpWidget(buildTestWidget(isPro: true, hideWhenPro: true));
    await tester.pumpAndSettle();

    expect(find.text('PRO'), findsNothing);
    expect(find.byIcon(Icons.workspace_premium_rounded), findsNothing);
  });

  testWidgets('ProBadge remains visible when hideWhenPro is false', (tester) async {
    await tester.pumpWidget(buildTestWidget(isPro: true, hideWhenPro: false));
    await tester.pumpAndSettle();

    expect(find.text('PRO'), findsOneWidget);
    expect(find.byIcon(Icons.workspace_premium_rounded), findsOneWidget);
  });

  testWidgets('ProBadge in compact mode renders only the icon without PRO text', (tester) async {
    await tester.pumpWidget(buildTestWidget(isPro: false, compact: true));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.workspace_premium_rounded), findsOneWidget);
    expect(find.text('PRO'), findsNothing);
  });

  testWidgets('ProBadge invokes custom onTap callback when pressed', (tester) async {
    var tapped = false;
    await tester.pumpWidget(buildTestWidget(isPro: false, onTap: () => tapped = true));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ProBadge));
    await tester.pump();

    expect(tapped, isTrue);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/core/branding/app_branding.dart';
import 'package:interval_timer/core/l10n/app_localizations.dart';
import 'package:interval_timer/features/session_summary/domain/session_complete_models.dart';
import 'package:interval_timer/features/session_summary/presentation/session_share_card.dart';

void main() {
  const testData = ShareCardData(
    displayName: 'HIIT Tabata',
    totalDurationSeconds: 1200,
    trainingSeconds: 800,
    restSeconds: 400,
    setsCount: 8,
    estimatedKcal: 250,
    currentStreakDays: 5,
    template: ShareTemplateStyle.solidDark,
  );

  Widget buildSubject({ShareCardData data = testData}) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(
          child: SessionShareCard(data: data),
        ),
      ),
    );
  }

  group('SessionShareCard branding integration', () {
    testWidgets('solidDark template renders branding logo pointing to official app_icon.png',
        (tester) async {
      await tester.pumpWidget(buildSubject(
        data: testData.copyWith(template: ShareTemplateStyle.solidDark),
      ));
      await tester.pumpAndSettle();

      final imageFinders = find.byType(Image);
      expect(imageFinders, findsAtLeastNWidgets(1));

      // Verify every logo rendered in the card references AppBranding.logoAsset
      for (final element in imageFinders.evaluate()) {
        final imageWidget = element.widget as Image;
        if (imageWidget.image is AssetImage) {
          final assetImage = imageWidget.image as AssetImage;
          expect(assetImage.assetName, AppBranding.logoAsset);
          expect(assetImage.assetName, 'assets/branding/app_icon.png');
        }
      }
    });

    testWidgets('solidBrand template renders branding logo pointing to official app_icon.png',
        (tester) async {
      await tester.pumpWidget(buildSubject(
        data: testData.copyWith(template: ShareTemplateStyle.solidBrand),
      ));
      await tester.pumpAndSettle();

      final imageFinders = find.byType(Image);
      expect(imageFinders, findsAtLeastNWidgets(1));

      for (final element in imageFinders.evaluate()) {
        final imageWidget = element.widget as Image;
        if (imageWidget.image is AssetImage) {
          final assetImage = imageWidget.image as AssetImage;
          expect(assetImage.assetName, AppBranding.logoAsset);
          expect(assetImage.assetName, 'assets/branding/app_icon.png');
        }
      }
    });

    testWidgets('transparent template renders branding logo pointing to official app_icon.png',
        (tester) async {
      await tester.pumpWidget(buildSubject(
        data: testData.copyWith(template: ShareTemplateStyle.transparent),
      ));
      await tester.pumpAndSettle();

      final imageFinders = find.byType(Image);
      expect(imageFinders, findsOneWidget);

      final imageWidget = tester.widget<Image>(imageFinders);
      expect(imageWidget.image, isA<AssetImage>());
      final assetImage = imageWidget.image as AssetImage;
      expect(assetImage.assetName, AppBranding.logoAsset);
      expect(assetImage.assetName, 'assets/branding/app_icon.png');
    });
  });
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/core/branding/app_branding.dart';

void main() {
  group('AppBranding', () {
    test('logoAsset points to the official app_icon.png', () {
      expect(AppBranding.logoAsset, 'assets/branding/app_icon.png');
    });

    test('official logo asset exists on disk', () {
      final file = File(AppBranding.logoAsset);
      expect(file.existsSync(), isTrue,
          reason: 'The app icon asset must exist at ${AppBranding.logoAsset}');
    });

    test('old legacy logo asset is completely removed', () {
      final oldLogo = File('assets/branding/app_logo.png');
      expect(oldLogo.existsSync(), isFalse,
          reason: 'Legacy app_logo.png must have no trace in the codebase');
    });

    testWidgets('logo widget renders Image.asset with logoAsset', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppBranding.logo(size: 48),
          ),
        ),
      );

      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);

      final imageWidget = tester.widget<Image>(imageFinder);
      expect(imageWidget.image, isA<AssetImage>());
      final assetImage = imageWidget.image as AssetImage;
      expect(assetImage.assetName, AppBranding.logoAsset);
    });
  });
}

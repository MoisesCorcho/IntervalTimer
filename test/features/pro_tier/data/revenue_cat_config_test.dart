import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/features/pro_tier/data/revenue_cat_config.dart';

void main() {
  group('RevenueCatConfig', () {
    test('has expected entitlement identifier', () {
      expect(RevenueCatConfig.entitlementId, equals('pro'));
    });

    test('isConfigured returns false when no environment keys are injected', () {
      // In default test runner without dart-define, keys should be empty
      expect(RevenueCatConfig.apiKeyAndroid, isEmpty);
      expect(RevenueCatConfig.apiKeyIos, isEmpty);
      expect(RevenueCatConfig.isConfigured, isFalse);
    });
  });
}

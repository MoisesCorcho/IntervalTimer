import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/features/monetization/infrastructure/admob_ad_service.dart';

void main() {
  group('AdMobAdService initialization tests', () {
    test('initialize invokes mobileAdsInitializer and sets initialized status', () async {
      var initCalls = 0;
      final service = AdMobAdService(
        temporaryPassRepository: null,
        mobileAdsInitializer: () async {
          initCalls++;
        },
      );

      expect(service.isInitialized, isFalse);
      await service.initialize();
      expect(service.isInitialized, isTrue);
      expect(initCalls, equals(1));
    });

    test('initialize is idempotent when called multiple times concurrently', () async {
      var initCalls = 0;
      final service = AdMobAdService(
        temporaryPassRepository: null,
        mobileAdsInitializer: () async {
          initCalls++;
        },
      );

      await Future.wait<void>([
        service.initialize(),
        service.initialize(),
        service.ensureInitialized(),
      ]);

      expect(service.isInitialized, isTrue);
      expect(initCalls, equals(1));
    });

    test('ensureInitialized lazily triggers initialize if not already done', () async {
      var initCalls = 0;
      final service = AdMobAdService(
        temporaryPassRepository: null,
        mobileAdsInitializer: () async {
          initCalls++;
        },
      );

      expect(service.isInitialized, isFalse);
      await service.ensureInitialized();
      expect(service.isInitialized, isTrue);
      expect(initCalls, equals(1));
    });

    test('initialize handles exceptions gracefully without crashing', () async {
      final service = AdMobAdService(
        temporaryPassRepository: null,
        mobileAdsInitializer: () async {
          throw Exception('AdMob platform channel not available');
        },
      );

      await expectLater(service.initialize(), completes);
      expect(service.isInitialized, isFalse);
    });
  });
}

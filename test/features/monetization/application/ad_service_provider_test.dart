import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/features/monetization/application/monetization_providers.dart';
import 'package:interval_timer/features/monetization/infrastructure/fake_ad_service.dart';

void main() {
  group('shouldEnableAdMob policy', () {
    test('returns false on web regardless of release mode or forceAdMob', () {
      expect(
        shouldEnableAdMob(
          platform: TargetPlatform.android,
          isWeb: true,
          isReleaseMode: true,
          forceAdMob: true,
        ),
        isFalse,
      );
    });

    test('returns false on desktop platforms (windows, macos, linux)', () {
      for (final platform in [
        TargetPlatform.windows,
        TargetPlatform.macOS,
        TargetPlatform.linux,
      ]) {
        expect(
          shouldEnableAdMob(
            platform: platform,
            isWeb: false,
            isReleaseMode: true,
            forceAdMob: true,
          ),
          isFalse,
          reason: 'Expected false for desktop platform: $platform',
        );
      }
    });

    test('returns true on Android only in release mode or when forceAdMob is true', () {
      // Debug without forceAdMob -> false
      expect(
        shouldEnableAdMob(
          platform: TargetPlatform.android,
          isWeb: false,
          isReleaseMode: false,
          forceAdMob: false,
        ),
        isFalse,
      );

      // Release without forceAdMob -> true
      expect(
        shouldEnableAdMob(
          platform: TargetPlatform.android,
          isWeb: false,
          isReleaseMode: true,
          forceAdMob: false,
        ),
        isTrue,
      );

      // Debug with forceAdMob -> true
      expect(
        shouldEnableAdMob(
          platform: TargetPlatform.android,
          isWeb: false,
          isReleaseMode: false,
          forceAdMob: true,
        ),
        isTrue,
      );
    });

    test('returns true on iOS only in release mode or when forceAdMob is true', () {
      expect(
        shouldEnableAdMob(
          platform: TargetPlatform.iOS,
          isWeb: false,
          isReleaseMode: false,
          forceAdMob: false,
        ),
        isFalse,
      );

      expect(
        shouldEnableAdMob(
          platform: TargetPlatform.iOS,
          isWeb: false,
          isReleaseMode: true,
          forceAdMob: false,
        ),
        isTrue,
      );

      expect(
        shouldEnableAdMob(
          platform: TargetPlatform.iOS,
          isWeb: false,
          isReleaseMode: false,
          forceAdMob: true,
        ),
        isTrue,
      );
    });
  });

  group('adServiceProvider platform binding', () {
    test('defaults to FakeAdService in test environment', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final adService = container.read(adServiceProvider);
      expect(adService, isA<FakeAdService>());
    });

    test('adServiceBootstrapProvider triggers adService.initialize()', () async {
      var initialized = false;
      final container = ProviderContainer(
        overrides: [
          adServiceProvider.overrideWith((ref) => _SpyAdService(() {
                initialized = true;
              })),
        ],
      );
      addTearDown(container.dispose);

      container.read(adServiceBootstrapProvider);
      // Wait microtasks
      await Future<void>.delayed(Duration.zero);

      expect(initialized, isTrue);
    });
  });
}

class _SpyAdService extends FakeAdService {
  final VoidCallback onInitialize;

  _SpyAdService(this.onInitialize) : super(temporaryPassRepository: null);

  @override
  Future<void> initialize() async {
    onInitialize();
  }
}

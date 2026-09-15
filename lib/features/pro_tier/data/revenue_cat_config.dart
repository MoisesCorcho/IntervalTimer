import 'package:flutter/foundation.dart';

/// Centralized configuration and compile-time environment variables for RevenueCat.
abstract final class RevenueCatConfig {
  /// Default entitlement identifier configured in RevenueCat dashboard.
  static const entitlementId = 'pro';

  /// Android Public API key passed via `--dart-define=REVENUECAT_API_KEY_ANDROID=goog_...`
  static const apiKeyAndroid = String.fromEnvironment('REVENUECAT_API_KEY_ANDROID');

  /// iOS Public API key passed via `--dart-define=REVENUECAT_API_KEY_IOS=appl_...`
  static const apiKeyIos = String.fromEnvironment('REVENUECAT_API_KEY_IOS');

  /// Resolves the appropriate RevenueCat API key for the current runtime platform.
  static String get apiKey {
    if (kIsWeb) return '';
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => apiKeyAndroid,
      TargetPlatform.iOS => apiKeyIos,
      _ => '',
    };
  }

  /// Whether valid RevenueCat credentials have been injected into the build.
  static bool get isConfigured => apiKey.isNotEmpty;
}

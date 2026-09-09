import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/features/settings/application/settings_providers.dart';
import 'package:interval_timer/features/settings/domain/app_language.dart';

/// Exposes the user-selected [AppLanguage] (system, es, en).
final appLanguageProvider = Provider<AppLanguage>((ref) {
  final settings = ref.watch(settingsControllerProvider).valueOrNull;
  return settings?.appLanguage ?? AppLanguage.system;
});

/// Pure resolution function: resolves [AppLanguage] to a concrete, supported [Locale].
///
/// If [appLanguage] is [AppLanguage.system], checks [systemLocale] (or platform locale).
/// If system language is Spanish ('es'), returns `Locale('es')`.
/// Otherwise, returns `Locale('en')` as safe default fallback (R2, R10).
Locale resolveEffectiveLocale(AppLanguage appLanguage, [Locale? systemLocale]) {
  switch (appLanguage) {
    case AppLanguage.es:
      return const Locale('es');
    case AppLanguage.en:
      return const Locale('en');
    case AppLanguage.system:
      final sys = systemLocale ?? ui.PlatformDispatcher.instance.locale;
      if (sys.languageCode == 'es') {
        return const Locale('es');
      }
      return const Locale('en');
  }
}

/// Exposes the resolved [Locale] to be consumed by `MaterialApp.router`, `SystemTtsEngine`,
/// and catalog repositories.
final effectiveLocaleProvider = Provider<Locale>((ref) {
  final lang = ref.watch(appLanguageProvider);
  return resolveEffectiveLocale(lang);
});

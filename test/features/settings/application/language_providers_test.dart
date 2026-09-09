import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/features/settings/application/language_providers.dart';
import 'package:interval_timer/features/settings/application/settings_controller.dart';
import 'package:interval_timer/features/settings/application/settings_providers.dart';
import 'package:interval_timer/features/settings/domain/app_language.dart';
import 'package:interval_timer/features/settings/domain/app_settings.dart';

void main() {
  group('resolveEffectiveLocale (F28 R2, R3, R10)', () {
    test('returns Locale("es") when AppLanguage.es is set', () {
      expect(
        resolveEffectiveLocale(AppLanguage.es, const Locale('fr')),
        equals(const Locale('es')),
      );
    });

    test('returns Locale("en") when AppLanguage.en is set', () {
      expect(
        resolveEffectiveLocale(AppLanguage.en, const Locale('es')),
        equals(const Locale('en')),
      );
    });

    test('resolves system language "es" when AppLanguage.system is set (R2)', () {
      expect(
        resolveEffectiveLocale(AppLanguage.system, const Locale('es', 'MX')),
        equals(const Locale('es')),
      );
      expect(
        resolveEffectiveLocale(AppLanguage.system, const Locale('es', 'ES')),
        equals(const Locale('es')),
      );
    });

    test('falls back to "en" for unsupported system locales (fr, de, pt) (R10)', () {
      expect(
        resolveEffectiveLocale(AppLanguage.system, const Locale('fr', 'FR')),
        equals(const Locale('en')),
      );
      expect(
        resolveEffectiveLocale(AppLanguage.system, const Locale('de')),
        equals(const Locale('en')),
      );
      expect(
        resolveEffectiveLocale(AppLanguage.system, const Locale('pt', 'BR')),
        equals(const Locale('en')),
      );
    });
  });

  group('effectiveLocaleProvider with Riverpod container', () {
    test('reflects AppSettings from settingsControllerProvider', () async {
      final container = ProviderContainer(
        overrides: [
          settingsControllerProvider.overrideWith(
            () => _FakeSettingsController(
              const AppSettings(prepSeconds: 10, appLanguage: AppLanguage.es),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(settingsControllerProvider.future);

      expect(container.read(appLanguageProvider), AppLanguage.es);
      expect(container.read(effectiveLocaleProvider), const Locale('es'));
    });
  });
}

class _FakeSettingsController extends SettingsController {
  _FakeSettingsController(this._initialSettings);

  final AppSettings _initialSettings;

  @override
  Future<AppSettings> build() async => _initialSettings;
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ARB Parity & Completeness Test (F28 R1)', () {
    late Map<String, dynamic> enJson;
    late Map<String, dynamic> esJson;

    setUpAll(() {
      final enFile = File('lib/core/l10n/app_en.arb');
      final esFile = File('lib/core/l10n/app_es.arb');

      expect(enFile.existsSync(), isTrue, reason: 'app_en.arb must exist');
      expect(esFile.existsSync(), isTrue, reason: 'app_es.arb must exist');

      enJson = jsonDecode(enFile.readAsStringSync()) as Map<String, dynamic>;
      esJson = jsonDecode(esFile.readAsStringSync()) as Map<String, dynamic>;
    });

    test('has 100% key parity between English and Spanish ARB files', () {
      final enKeys = enJson.keys
          .where((k) => !k.startsWith('@'))
          .toSet();
      final esKeys = esJson.keys
          .where((k) => !k.startsWith('@'))
          .toSet();

      final missingInEs = enKeys.difference(esKeys);
      final missingInEn = esKeys.difference(enKeys);

      expect(
        missingInEs,
        isEmpty,
        reason: 'Keys present in app_en.arb but missing in app_es.arb: $missingInEs',
      );
      expect(
        missingInEn,
        isEmpty,
        reason: 'Keys present in app_es.arb but missing in app_en.arb: $missingInEn',
      );
    });

    test('placeholder definitions match in all parameterized messages', () {
      final placeholderRegex = RegExp(r'\{([a-zA-Z0-9_]+)\}');

      for (final key in enJson.keys.where((k) => !k.startsWith('@'))) {
        final enVal = enJson[key];
        final esVal = esJson[key];

        if (enVal is String && esVal is String) {
          final enPlaceholders = placeholderRegex
              .allMatches(enVal)
              .map((m) => m.group(1))
              .toSet();
          final esPlaceholders = placeholderRegex
              .allMatches(esVal)
              .map((m) => m.group(1))
              .toSet();

          expect(
            esPlaceholders,
            equals(enPlaceholders),
            reason: 'Placeholders for key "$key" do not match. EN: $enPlaceholders, ES: $esPlaceholders',
          );
        }
      }
    });
  });
}

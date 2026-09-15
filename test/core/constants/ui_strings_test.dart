import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';

void main() {
  group('UiStrings', () {
    test('appTitle is configured to Repulse', () {
      expect(UiStrings.appTitle, equals('Repulse'));
    });
  });
}

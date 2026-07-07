import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/core/utils/contrast_text_color.dart';

void main() {
  test('contrastTextColor meets WCAG AA ratio >= 4.5', () {
    final backgrounds = [
      Colors.white,
      Colors.black,
      const Color(0xFF4CAF50),
      const Color(0xFFFFC107),
      const Color(0xFF2196F3),
    ];

    for (final bg in backgrounds) {
      final text = contrastTextColor(bg);
      final ratio = contrastRatio(text, bg);
      expect(ratio, greaterThanOrEqualTo(4.5));
    }
  });
}
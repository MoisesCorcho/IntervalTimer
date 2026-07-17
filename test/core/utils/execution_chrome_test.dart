import 'package:flutter/material.dart' hide Interval;
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/core/utils/execution_chrome.dart';
import 'package:interval_timer/data/models/interval.dart';
import 'package:interval_timer/data/models/interval_type.dart';

void main() {
  group('executionBackgroundColor', () {
    test('work/rest ignore light stored colorArgb and use brand swatches', () {
      final work = Interval(
        id: 'w',
        name: 'Work',
        durationSeconds: 30,
        colorArgb: 0xFF4CAF50, // light Material 500
        type: IntervalType.work,
      );
      final rest = Interval(
        id: 'r',
        name: 'Rest',
        durationSeconds: 15,
        colorArgb: 0xFF2196F3,
        type: IntervalType.rest,
      );

      expect(
        executionBackgroundColor(
          interval: work,
          prepFallback: Colors.grey,
        ),
        AppTheme.workColor,
      );
      expect(
        executionBackgroundColor(
          interval: rest,
          prepFallback: Colors.grey,
        ),
        AppTheme.restColor,
      );
    });

    test('custom keeps user colorArgb', () {
      const customArgb = 0xFFABCDEF;
      final custom = Interval(
        id: 'c',
        name: 'Custom',
        durationSeconds: 10,
        colorArgb: customArgb,
        type: IntervalType.custom,
      );
      expect(
        executionBackgroundColor(
          interval: custom,
          prepFallback: Colors.grey,
        ),
        const Color(customArgb),
      );
    });

    test('null interval uses prep fallback', () {
      expect(
        executionBackgroundColor(
          interval: null,
          prepFallback: const Color(0xFF123456),
        ),
        const Color(0xFF123456),
      );
    });
  });

  group('executionChromeColor', () {
    test('work rest stretch are always white', () {
      for (final type in [
        IntervalType.work,
        IntervalType.rest,
        IntervalType.stretch,
      ]) {
        expect(
          executionChromeColor(
            background: const Color(0xFF4CAF50),
            type: type,
          ),
          Colors.white,
        );
      }
    });

    test('warmup is black on amber', () {
      expect(
        executionChromeColor(
          background: AppTheme.warmupColor,
          type: IntervalType.warmup,
        ),
        Colors.black,
      );
    });
  });
}

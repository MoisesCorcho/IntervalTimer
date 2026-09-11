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

    test('isPreparation true always returns AppTheme.prepColor', () {
      final work = Interval(
        id: 'w',
        name: 'Work',
        durationSeconds: 30,
        colorArgb: 0xFF4CAF50,
        type: IntervalType.work,
      );
      expect(
        executionBackgroundColor(
          interval: work,
          isPreparation: true,
          prepFallback: Colors.grey,
        ),
        AppTheme.prepColor,
      );
    });

    test('custom workColor and restColor are used when provided', () {
      const customWork = Color(0xFFC62828);
      const customRest = Color(0xFF6A1B9A);
      final work = Interval(
        id: 'w',
        name: 'Work',
        durationSeconds: 30,
        colorArgb: 0xFF2E7D32,
        type: IntervalType.work,
      );
      final rest = Interval(
        id: 'r',
        name: 'Rest',
        durationSeconds: 15,
        colorArgb: 0xFF1565C0,
        type: IntervalType.rest,
      );

      expect(
        executionBackgroundColor(
          interval: work,
          workColor: customWork,
          restColor: customRest,
          prepFallback: Colors.grey,
        ),
        customWork,
      );
      expect(
        executionBackgroundColor(
          interval: rest,
          workColor: customWork,
          restColor: customRest,
          prepFallback: Colors.grey,
        ),
        customRest,
      );
    });

    test('null interval uses prep fallback when not in preparation', () {
      expect(
        executionBackgroundColor(
          interval: null,
          prepFallback: const Color(0xFF123456),
        ),
        const Color(0xFF123456),
      );
    });
  });

  group('AppTheme phase presets', () {
    test('contains 10 athletic colors including default work and rest', () {
      expect(AppTheme.phaseColorPresets.length, 10);
      expect(AppTheme.phaseColorPresets.contains(AppTheme.workColor), isTrue);
      expect(AppTheme.phaseColorPresets.contains(AppTheme.restColor), isTrue);
      expect(AppTheme.prepColor, const Color(0xFF2E3239));
    });
  });

  group('executionChromeColor', () {
    test('work, rest, prep, and stretch consistently use Colors.white', () {
      // Default work color -> white text
      expect(
        executionChromeColor(
          background: AppTheme.workColor,
          type: IntervalType.work,
        ),
        Colors.white,
      );

      // Light work color preset (e.g. Amber/Gold) -> stays white as configured
      expect(
        executionChromeColor(
          background: const Color(0xFFFF8F00),
          type: IntervalType.work,
        ),
        Colors.white,
      );

      // Rest color -> white text
      expect(
        executionChromeColor(
          background: AppTheme.restColor,
          type: IntervalType.rest,
        ),
        Colors.white,
      );

      // Prep color -> white text
      expect(
        executionChromeColor(
          background: AppTheme.prepColor,
          type: null,
          isPreparation: true,
        ),
        Colors.white,
      );

      // Stretch -> white text
      expect(
        executionChromeColor(
          background: AppTheme.stretchColor,
          type: IntervalType.stretch,
        ),
        Colors.white,
      );
    });

    test('custom interval dynamically resolves contrastTextColor', () {
      // Dark custom background -> white text
      expect(
        executionChromeColor(
          background: const Color(0xFF102030),
          type: IntervalType.custom,
        ),
        Colors.white,
      );

      // Light custom background -> black text
      expect(
        executionChromeColor(
          background: const Color(0xFFFFFFEE),
          type: IntervalType.custom,
        ),
        Colors.black,
      );
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

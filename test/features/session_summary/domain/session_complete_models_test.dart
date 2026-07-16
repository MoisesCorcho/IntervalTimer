import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/features/session_summary/domain/session_complete_models.dart';
import 'package:interval_timer/features/session_summary/domain/session_phase_breakdown.dart';

void main() {
  group('ShareCardData / note helpers', () {
    test('maps displayName, total, kcal, streak from view', () {
      final view = SessionCompleteViewData.fromBreakdown(
        sourceId: 's1',
        displayName: 'HIIT',
        totalDurationSeconds: 600,
        breakdown: const SessionPhaseBreakdown(
          trainingSeconds: 400,
          restSeconds: 200,
          setsCount: 4,
        ),
        estimatedKcal: 42,
        currentStreakDays: 3,
        setsCount: 4,
        sessionLogId: 'log-1',
      );
      final card = ShareCardData.fromView(view);
      expect(card.displayName, 'HIIT');
      expect(card.totalDurationSeconds, 600);
      expect(card.trainingSeconds, 400);
      expect(card.restSeconds, 200);
      expect(card.setsCount, 4);
      expect(card.estimatedKcal, 42);
      expect(card.currentStreakDays, 3);
      expect(card.template, ShareTemplateStyle.transparent);
    });

    test('sanitizeNoteDraft rejects > 500 when strict', () {
      final long = 'a' * 501;
      expect(sanitizeNoteDraft(long), isNull);
      expect(sanitizeNoteDraft(long, strict: false)?.length, 500);
      expect(sanitizeNoteDraft('ok')?.length, 2);
    });
  });
}

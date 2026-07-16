import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/features/session_summary/application/session_summary_controller.dart';
import 'package:interval_timer/features/session_summary/domain/session_complete_models.dart';
import 'package:interval_timer/features/session_summary/domain/share_sheet_driver.dart';

final shareSheetDriverProvider = Provider<ShareSheetDriver>((ref) {
  return PluginShareSheetDriver();
});

final sessionSummaryControllerProvider =
    NotifierProvider<SessionSummaryController, SessionSummaryState>(
  SessionSummaryController.new,
);

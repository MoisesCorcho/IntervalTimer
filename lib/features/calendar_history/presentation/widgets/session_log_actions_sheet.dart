import 'package:flutter/material.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/core/utils/session_duration_format.dart';
import 'package:interval_timer/data/models/session_log.dart';

Future<SessionLogAction?> showSessionLogActionsSheet({
  required BuildContext context,
  required SessionLog log,
}) {
  return showModalBottomSheet<SessionLogAction>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return SessionLogActionsSheet(log: log);
    },
  );
}

enum SessionLogAction { start, delete }

class SessionLogActionsSheet extends StatelessWidget {
  const SessionLogActionsSheet({super.key, required this.log});

  final SessionLog log;

  String get _title {
    if (log.displayName.trim().isNotEmpty) return log.displayName;
    final time = SessionDurationFormat.formatTimeOfDay(log.endedAt);
    return UiStrings.historyFallbackTitle.replaceAll('{time}', time);
  }

  @override
  Widget build(BuildContext context) {
    final duration = SessionDurationFormat.format(log.totalDurationSeconds);
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              key: const Key('history_sheet_header'),
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    duration,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              key: const Key('history_sheet_start'),
              leading: const Icon(Icons.play_arrow),
              title: const Text(UiStrings.historyStart),
              onTap: () => Navigator.pop(context, SessionLogAction.start),
            ),
            ListTile(
              key: const Key('history_sheet_delete'),
              leading: Icon(
                Icons.delete_outline,
                color: theme.colorScheme.error,
              ),
              title: Text(
                UiStrings.historyDelete,
                style: TextStyle(color: theme.colorScheme.error),
              ),
              onTap: () => Navigator.pop(context, SessionLogAction.delete),
            ),
          ],
        ),
      ),
    );
  }
}

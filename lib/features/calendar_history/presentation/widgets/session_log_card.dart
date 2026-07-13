import 'package:flutter/material.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/core/utils/session_duration_format.dart';
import 'package:interval_timer/data/models/session_log.dart';

class SessionLogCard extends StatelessWidget {
  const SessionLogCard({
    super.key,
    required this.log,
    required this.onOverflow,
    required this.onNoteTap,
  });

  final SessionLog log;
  final VoidCallback onOverflow;
  final VoidCallback onNoteTap;

  String get _title {
    if (log.displayName.trim().isNotEmpty) return log.displayName;
    final time = SessionDurationFormat.formatTimeOfDay(log.endedAt);
    return UiStrings.historyFallbackTitle.replaceAll('{time}', time);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final duration = SessionDurationFormat.format(log.totalDurationSeconds);
    final exercises = UiStrings.historyExerciseCount
        .replaceAll('{count}', '${log.itemCount}');
    final hasNote = log.note != null && log.note!.trim().isNotEmpty;

    return Card(
      key: Key('session_log_card_${log.id}'),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    _title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  key: Key('session_log_overflow_${log.id}'),
                  tooltip: 'Más opciones',
                  onPressed: onOverflow,
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Chip(
                  label: Text(duration),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                Chip(
                  label: Text(exercises),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
            const SizedBox(height: 8),
            InkWell(
              key: Key('session_log_note_${log.id}'),
              onTap: onNoteTap,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      hasNote ? Icons.sentiment_satisfied_alt : Icons.edit_note,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        hasNote ? log.note! : UiStrings.historyAddNote,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: hasNote
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

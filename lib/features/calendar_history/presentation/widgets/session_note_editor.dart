import 'package:flutter/material.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/data/repositories/session_log_repository.dart';
import 'package:interval_timer/shared/widgets/app_primary_button.dart';
import 'package:interval_timer/shared/widgets/dialog_actions_row.dart';

Future<String?> showSessionNoteEditor({
  required BuildContext context,
  String? initialNote,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      return _SessionNoteEditorSheet(initialNote: initialNote);
    },
  );
}

class _SessionNoteEditorSheet extends StatefulWidget {
  const _SessionNoteEditorSheet({this.initialNote});

  final String? initialNote;

  @override
  State<_SessionNoteEditorSheet> createState() =>
      _SessionNoteEditorSheetState();
}

class _SessionNoteEditorSheetState extends State<_SessionNoteEditorSheet> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNote ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final text = _controller.text;
    if (text.length > SessionLogRepository.maxNoteLength) {
      setState(() => _error = UiStrings.historyNoteTooLong);
      return;
    }
    Navigator.pop(context, text);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            UiStrings.historyEditNoteTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('history_note_field'),
            controller: _controller,
            maxLines: 5,
            maxLength: SessionLogRepository.maxNoteLength,
            decoration: InputDecoration(
              hintText: UiStrings.historyAddNote,
              errorText: _error,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DialogActionsRow(
            children: [
              AppSecondaryButton(
                compact: true,
                onPressed: () => Navigator.pop(context),
                label: UiStrings.cancel,
              ),
              AppPrimaryButton(
                key: const Key('history_note_save'),
                compact: true,
                onPressed: _save,
                label: UiStrings.save,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

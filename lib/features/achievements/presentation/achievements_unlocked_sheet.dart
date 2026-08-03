import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/features/achievements/application/achievements_providers.dart';
import 'package:interval_timer/features/achievements/domain/achievement_def.dart';
import 'package:interval_timer/shared/widgets/app_primary_button.dart';

/// Single multi-unlock celebration sheet (F13 R7).
Future<void> showAchievementsUnlockedSheet({
  required BuildContext context,
  required List<AchievementDef> unlocked,
  VoidCallback? onClosed,
}) {
  if (unlocked.isEmpty) {
    onClosed?.call();
    return Future.value();
  }

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) {
      return _AchievementsUnlockedSheetBody(unlocked: unlocked);
    },
  ).whenComplete(() => onClosed?.call());
}

class _AchievementsUnlockedSheetBody extends ConsumerWidget {
  const _AchievementsUnlockedSheetBody({
    required this.unlocked,
  });

  final List<AchievementDef> unlocked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom;

    return SafeArea(
      child: Padding(
        key: const Key('achievements_unlocked_sheet'),
        padding: EdgeInsets.fromLTRB(
          AppTheme.spacingLg,
          AppTheme.spacingSm,
          AppTheme.spacingLg,
          bottom + AppTheme.spacingMd,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              UiStrings.achievementsSheetTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.4,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: unlocked.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppTheme.spacingSm),
                itemBuilder: (context, index) {
                  final def = unlocked[index];
                  return ListTile(
                    key: Key('celebration_item_${def.id}'),
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(def.icon, color: theme.colorScheme.primary),
                    ),
                    title: Text(UiStrings.achievementTitle(def.id)),
                    subtitle: Text(UiStrings.achievementDescription(def.id)),
                  );
                },
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            AppPrimaryButton(
              key: const Key('achievements_sheet_close'),
              expand: true,
              label: UiStrings.achievementsSheetClose,
              icon: Icons.celebration_rounded,
              onPressed: () {
                ref
                    .read(achievementsControllerProvider.notifier)
                    .clearPendingCelebration();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

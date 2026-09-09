import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interval_timer/core/l10n/l10n_extension.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/features/achievements/application/achievements_providers.dart';

/// History entry that opens the achievements collection (F13 R2).
class AchievementsEntryTile extends ConsumerWidget {
  const AchievementsEntryTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final unlocksAsync = ref.watch(unlockedAchievementsProvider);
    final unlockedCount = unlocksAsync.valueOrNull?.length ?? 0;
    final total = ref.watch(achievementCatalogProvider).length;

    return Padding(
      key: const Key('achievements_entry_tile'),
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: InkWell(
          key: const Key('achievements_entry_ink'),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          onTap: () => context.push('/history/achievements'),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppTheme.buttonMinHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMd,
                vertical: AppTheme.spacingSm,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.emoji_events_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.achievementsEntryTitle,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          unlocksAsync.hasError
                              ? l10n.achievementsEntrySubtitle
                              : '$unlockedCount / $total · ${l10n.achievementsEntrySubtitle}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

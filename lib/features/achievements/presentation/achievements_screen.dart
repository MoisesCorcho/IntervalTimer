import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/core/l10n/l10n_extension.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/features/achievements/application/achievements_providers.dart';
import 'package:interval_timer/features/achievements/presentation/achievement_tile.dart';
import 'package:interval_timer/features/stats/application/stats_providers.dart';

/// Full catalog list with locked/unlocked progress (F13 R3, R9, R10).
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final progressAsync = ref.watch(achievementProgressProvider);

    return Scaffold(
      key: const Key('achievements_screen'),
      appBar: AppBar(
        title: Text(l10n.achievementsTitle),
      ),
      body: progressAsync.when(
        loading: () => const Center(
          child: SizedBox(
            key: Key('achievements_loading'),
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        error: (_, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.achievementsError,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: AppTheme.spacingMd),
                TextButton(
                  key: const Key('achievements_retry'),
                  onPressed: () {
                    ref.invalidate(sessionLogsForStatsProvider);
                    ref.invalidate(unlockedAchievementsProvider);
                  },
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                child: Text(
                  l10n.achievementsEmptyHint,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // Unlocked first, then pending by catalog order.
          final sorted = [...items]..sort((a, b) {
              if (a.isUnlocked != b.isUnlocked) {
                return a.isUnlocked ? -1 : 1;
              }
              return 0;
            });

          return ListView.separated(
            key: const Key('achievements_list'),
            padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
            itemCount: sorted.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return AchievementTile(progress: sorted[index]);
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/features/achievements/application/achievements_providers.dart';
import 'package:interval_timer/features/achievements/presentation/achievement_tile.dart';
import 'package:interval_timer/features/stats/application/stats_providers.dart';

/// Full catalog list with locked/unlocked progress (F13 R3, R9, R10).
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(achievementProgressProvider);

    return Scaffold(
      key: const Key('achievements_screen'),
      appBar: AppBar(
        title: const Text(UiStrings.achievementsTitle),
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
                  UiStrings.achievementsError,
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
                  child: const Text(UiStrings.retry),
                ),
              ],
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppTheme.spacingLg),
                child: Text(
                  UiStrings.achievementsEmptyHint,
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

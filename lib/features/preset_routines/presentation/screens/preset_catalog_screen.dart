import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interval_timer/core/l10n/l10n_extension.dart';
import 'package:interval_timer/data/models/favorite_routine.dart';
import 'package:interval_timer/features/preset_routines/application/preset_providers.dart';
import 'package:interval_timer/features/preset_routines/domain/models/enums.dart';
import 'package:interval_timer/features/preset_routines/domain/models/preset_routine.dart';
import 'package:interval_timer/features/preset_routines/presentation/widgets/exercise_media_widget.dart';
import 'package:interval_timer/features/preset_routines/presentation/widgets/preset_hero_carousel.dart';
import 'package:interval_timer/shared/widgets/favorite_toggle_button.dart';

class PresetCatalogScreen extends ConsumerWidget {
  const PresetCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(presetCatalogProvider);
    final filteredAsync = ref.watch(filteredPresetsProvider);
    final selectedCategory = ref.watch(selectedPresetCategoryProvider);
    final favoritesOnly = ref.watch(presetFavoritesOnlyFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.presetRoutinesTitle),
      ),
      body: catalogAsync.when(
        data: (allPresets) {
          final featuredPresets = allPresets.where((p) => p.isFeatured).toList();

          return CustomScrollView(
            slivers: [
              // Hero Carousel section for featured presets
              if (featuredPresets.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Text(
                      context.l10n.featuredToday,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: PresetHeroCarousel(presets: featuredPresets),
                ),
              ],

              // Category Filter Chips
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: _PresetCategoryFilterChips(
                    selectedCategory: selectedCategory,
                    favoritesOnly: favoritesOnly,
                    onSelected: (cat) {
                      ref.read(selectedPresetCategoryProvider.notifier).state = cat;
                    },
                    onFavoritesToggled: (val) {
                      ref.read(presetFavoritesOnlyFilterProvider.notifier).state = val;
                    },
                  ),
                ),
              ),

              // Filtered Preset List Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    favoritesOnly
                        ? (selectedCategory == null
                            ? '${context.l10n.favoritesTitle} (${filteredAsync.value?.length ?? 0})'
                            : '${selectedCategory.label} - ${context.l10n.favoritesTitle} (${filteredAsync.value?.length ?? 0})')
                        : (selectedCategory == null
                            ? '${context.l10n.allRoutines} (${allPresets.length})'
                            : '${selectedCategory.label} (${filteredAsync.value?.length ?? 0})'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Filtered Preset Grid / List
              filteredAsync.when(
                data: (presets) {
                  if (presets.isEmpty) {
                    final emptyMsg = favoritesOnly
                        ? (selectedCategory == null
                            ? context.l10n.noFavoritePresets
                            : context.l10n.noCategoryFavoritePresets)
                        : context.l10n.noCategoryPresets;
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Text(emptyMsg),
                        ),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final preset = presets[index];
                          return _PresetCard(preset: preset);
                        },
                        childCount: presets.length,
                      ),
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, stack) => SliverToBoxAdapter(
                  child: Center(child: Text('Error al filtrarPresets: $err')),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          key: const Key('catalog_error_widget'),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 56, color: Colors.redAccent),
                const SizedBox(height: 16),
                Text(
                  context.l10n.errorLoadingPresetCatalog,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  err.toString(),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  key: const Key('catalog_retry_button'),
                  onPressed: () => ref.refresh(presetCatalogProvider),
                  icon: const Icon(Icons.refresh),
                  label: Text(context.l10n.retry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PresetCategoryFilterChips extends StatelessWidget {
  final PresetCategory? selectedCategory;
  final bool favoritesOnly;
  final ValueChanged<PresetCategory?> onSelected;
  final ValueChanged<bool> onFavoritesToggled;

  const _PresetCategoryFilterChips({
    required this.selectedCategory,
    required this.favoritesOnly,
    required this.onSelected,
    required this.onFavoritesToggled,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          FilterChip(
            key: const Key('filter_chip_favorites'),
            avatar: Icon(
              Icons.star,
              size: 16,
              color: favoritesOnly ? Colors.amber : Colors.grey,
            ),
            label: Text(context.l10n.favoritesTitle),
            selected: favoritesOnly,
            onSelected: onFavoritesToggled,
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            key: const Key('category_chip_all'),
            label: Text(context.l10n.filterAll),
            selected: selectedCategory == null,
            onSelected: (selected) {
              if (selected) onSelected(null);
            },
          ),
          const SizedBox(width: 8),
          ...PresetCategory.values.map((cat) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                key: Key('category_chip_${cat.id}'),
                label: Text(cat.label),
                selected: selectedCategory == cat,
                onSelected: (selected) {
                  onSelected(selected ? cat : null);
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _PresetCard extends StatelessWidget {
  final PresetRoutine preset;

  const _PresetCard({required this.preset});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalSec = preset.calculateTotalDurationSeconds();
    final mins = totalSec ~/ 60;
    final secs = totalSec % 60;
    final timeStr = secs > 0 ? '${mins}m ${secs}s' : '${mins}m';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/presets/${preset.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Image Thumbnail
              SizedBox(
                width: 80,
                height: 80,
                child: ExerciseMediaWidget(
                  category: preset.category,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 14),

              // Routine info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      preset.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      preset.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _BadgeChip(
                          icon: Icons.timer_outlined,
                          label: timeStr,
                        ),
                        _BadgeChip(
                          icon: Icons.fitness_center_outlined,
                          label: context.l10n.exerciseCountShort(preset.exercises.length),
                        ),
                        _BadgeChip(
                          icon: Icons.speed,
                          label: preset.difficulty.label,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              FavoriteToggleButton(
                targetId: preset.id,
                targetType: FavoriteTargetType.preset,
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BadgeChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
        ),
      ],
    );
  }
}

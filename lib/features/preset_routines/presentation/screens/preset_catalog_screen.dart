import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interval_timer/features/preset_routines/application/preset_providers.dart';
import 'package:interval_timer/features/preset_routines/domain/models/enums.dart';
import 'package:interval_timer/features/preset_routines/domain/models/preset_routine.dart';
import 'package:interval_timer/features/preset_routines/presentation/widgets/exercise_media_widget.dart';
import 'package:interval_timer/features/preset_routines/presentation/widgets/preset_hero_carousel.dart';

class PresetCatalogScreen extends ConsumerWidget {
  const PresetCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(presetCatalogProvider);
    final filteredAsync = ref.watch(filteredPresetsProvider);
    final selectedCategory = ref.watch(selectedPresetCategoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rutinas Preestablecidas'),
      ),
      body: catalogAsync.when(
        data: (allPresets) {
          final featuredPresets = allPresets.where((p) => p.isFeatured).toList();

          return CustomScrollView(
            slivers: [
              // Hero Carousel section for featured presets
              if (featuredPresets.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Text(
                      'Destacadas del Día',
                      style: TextStyle(
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
                    onSelected: (cat) {
                      ref.read(selectedPresetCategoryProvider.notifier).state = cat;
                    },
                  ),
                ),
              ),

              // Filtered Preset List Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    selectedCategory == null
                        ? 'Todas las Rutinas (${allPresets.length})'
                        : '${selectedCategory.label} (${filteredAsync.value?.length ?? 0})',
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
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Text('No hay rutinas disponibles para esta categoría.'),
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
                const Text(
                  'Error al cargar el catálogo de rutinas.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                  label: const Text('Reintentar'),
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
  final ValueChanged<PresetCategory?> onSelected;

  const _PresetCategoryFilterChips({
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          ChoiceChip(
            key: const Key('category_chip_all'),
            label: const Text('Todos'),
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
                          label: '${preset.exercises.length} ejer.',
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

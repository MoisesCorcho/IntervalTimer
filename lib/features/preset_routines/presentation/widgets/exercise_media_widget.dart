import 'package:flutter/material.dart';
import 'package:interval_timer/features/preset_routines/domain/models/enums.dart';
import 'package:interval_timer/features/preset_routines/domain/models/exercise.dart';

class ExerciseMediaWidget extends StatelessWidget {
  final Exercise? exercise;
  final PresetCategory category;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const ExerciseMediaWidget({
    super.key,
    this.exercise,
    this.category = PresetCategory.fullBody,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveCategory = exercise?.category ?? category;
    final primaryPath = exercise?.mediaPath;
    final categoryPath = 'assets/media/categories/cat_${effectiveCategory.id}.png';

    Widget mediaWidget;

    if (primaryPath != null && primaryPath.isNotEmpty) {
      mediaWidget = Image.asset(
        primaryPath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildCategoryFallback(categoryPath);
        },
      );
    } else {
      mediaWidget = _buildCategoryFallback(categoryPath);
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: mediaWidget,
      );
    }

    return mediaWidget;
  }

  Widget _buildCategoryFallback(String categoryPath) {
    return Image.asset(
      categoryPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return _buildSystemIconFallback();
      },
    );
  }

  Widget _buildSystemIconFallback() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade800,
      alignment: Alignment.center,
      child: const Icon(
        Icons.fitness_center,
        color: Colors.white70,
        size: 32,
      ),
    );
  }
}

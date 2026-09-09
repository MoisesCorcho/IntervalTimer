import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/core/l10n/l10n_extension.dart';
import 'package:interval_timer/data/models/favorite_routine.dart';
import 'package:interval_timer/features/favorites/application/favorite_providers.dart';

class FavoriteToggleButton extends ConsumerStatefulWidget {
  const FavoriteToggleButton({
    super.key,
    required this.targetId,
    required this.targetType,
    this.iconSize = 24.0,
    this.activeColor = Colors.amber,
    this.inactiveColor,
  });

  final String targetId;
  final FavoriteTargetType targetType;
  final double iconSize;
  final Color activeColor;
  final Color? inactiveColor;

  @override
  ConsumerState<FavoriteToggleButton> createState() =>
      _FavoriteToggleButtonState();
}

class _FavoriteToggleButtonState extends ConsumerState<FavoriteToggleButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.35)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.35, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    _controller.forward(from: 0.0);
    await ref.read(favoriteRepositoryProvider).toggleFavorite(
          targetId: widget.targetId,
          targetType: widget.targetType,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isFavorite = ref.watch(isFavoriteProvider(widget.targetId));
    final tooltip = isFavorite
        ? l10n.removeFromFavorites
        : l10n.markAsFavorite;

    final inactive = widget.inactiveColor ??
        Theme.of(context).iconTheme.color?.withValues(alpha: 0.6) ??
        Colors.grey;

    return IconButton(
      key: Key('favorite_toggle_${widget.targetId}'),
      iconSize: widget.iconSize,
      tooltip: tooltip,
      onPressed: _handleTap,
      icon: ScaleTransition(
        scale: _scaleAnimation,
        child: Icon(
          isFavorite ? Icons.star : Icons.star_border,
          color: isFavorite ? widget.activeColor : inactive,
          semanticLabel: tooltip,
        ),
      ),
    );
  }
}

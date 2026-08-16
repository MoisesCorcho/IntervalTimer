import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/data/models/favorite_routine.dart';
import 'package:interval_timer/data/repositories/favorite_repository.dart';
import 'package:interval_timer/features/favorites/application/favorite_providers.dart';
import 'package:interval_timer/shared/widgets/favorite_toggle_button.dart';

class FakeFavoriteRepository implements FavoriteRepository {
  final Set<String> _favoriteIds = {};
  final _controller = StreamController<Set<String>>.broadcast();

  @override
  Future<void> deleteByTargetId(String targetId) async {
    _favoriteIds.remove(targetId);
    _controller.add(Set.from(_favoriteIds));
  }

  @override
  Future<List<FavoriteRoutine>> getAllFavorites() async {
    return _favoriteIds
        .map(
          (id) => FavoriteRoutine(
            id: id,
            targetId: id,
            targetType: FavoriteTargetType.preset,
            createdAt: DateTime.now(),
          ),
        )
        .toList();
  }

  @override
  Future<bool> isFavorite(String targetId, FavoriteTargetType targetType) async {
    return _favoriteIds.contains(targetId);
  }

  @override
  Future<bool> toggleFavorite({
    required String targetId,
    required FavoriteTargetType targetType,
  }) async {
    if (_favoriteIds.contains(targetId)) {
      _favoriteIds.remove(targetId);
      _controller.add(Set.from(_favoriteIds));
      return false;
    } else {
      _favoriteIds.add(targetId);
      _controller.add(Set.from(_favoriteIds));
      return true;
    }
  }

  @override
  Stream<List<FavoriteRoutine>> watchAllFavorites() {
    return _controller.stream.map(
      (set) => set
          .map(
            (id) => FavoriteRoutine(
              id: id,
              targetId: id,
              targetType: FavoriteTargetType.preset,
              createdAt: DateTime.now(),
            ),
          )
          .toList(),
    );
  }

  @override
  Stream<Set<String>> watchFavoriteTargetIds() {
    return Stream.value(_favoriteIds).concatWith([_controller.stream]);
  }

  void dispose() {
    _controller.close();
  }
}

extension _StreamConcat<T> on Stream<T> {
  Stream<T> concatWith(Iterable<Stream<T>> others) async* {
    yield* this;
    for (final s in others) {
      yield* s;
    }
  }
}

void main() {
  late FakeFavoriteRepository favoriteRepo;

  setUp(() {
    favoriteRepo = FakeFavoriteRepository();
  });

  tearDown(() {
    favoriteRepo.dispose();
  });

  Widget buildWidget({
    required String targetId,
    required FavoriteTargetType targetType,
  }) {
    return ProviderScope(
      overrides: [
        favoriteRepositoryProvider.overrideWithValue(favoriteRepo),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Center(
            child: FavoriteToggleButton(
              targetId: targetId,
              targetType: targetType,
            ),
          ),
        ),
      ),
    );
  }

  group('FavoriteToggleButton Widget', () {
    testWidgets(
        'renders star_border initially and switches to star on tap',
        (tester) async {
      await tester.pumpWidget(
        buildWidget(
          targetId: 'preset-1',
          targetType: FavoriteTargetType.preset,
        ),
      );
      await tester.pumpAndSettle();

      // Initial state: not favorited -> Icons.star_border
      expect(find.byIcon(Icons.star_border), findsOneWidget);
      expect(find.byIcon(Icons.star), findsNothing);

      // Tap button
      await tester.tap(find.byType(FavoriteToggleButton));
      await tester.pumpAndSettle();

      // Now favorited -> Icons.star
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.star_border), findsNothing);

      // Check repo state
      final isFav = await favoriteRepo.isFavorite(
        'preset-1',
        FavoriteTargetType.preset,
      );
      expect(isFav, isTrue);

      // Tap again to unfavorite
      await tester.tap(find.byType(FavoriteToggleButton));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star_border), findsOneWidget);
      expect(find.byIcon(Icons.star), findsNothing);
    });

    testWidgets('shows correct tooltip for add and remove', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          targetId: 'preset-2',
          targetType: FavoriteTargetType.preset,
        ),
      );
      await tester.pumpAndSettle();

      // Initial tooltip
      final iconButtonInitial = tester.widget<IconButton>(
        find.descendant(
          of: find.byType(FavoriteToggleButton),
          matching: find.byType(IconButton),
        ),
      );
      expect(iconButtonInitial.tooltip, UiStrings.markAsFavorite);

      // Tap to favorite
      await tester.tap(find.byType(FavoriteToggleButton));
      await tester.pumpAndSettle();

      final iconButtonFavorited = tester.widget<IconButton>(
        find.descendant(
          of: find.byType(FavoriteToggleButton),
          matching: find.byType(IconButton),
        ),
      );
      expect(iconButtonFavorited.tooltip, UiStrings.removeFromFavorites);
    });
  });
}

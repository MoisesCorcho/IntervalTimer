import 'dart:async';

import 'package:interval_timer/data/models/favorite_routine.dart';
import 'package:interval_timer/data/repositories/favorite_repository.dart';

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

import 'package:freezed_annotation/freezed_annotation.dart';

part 'favorite_routine.freezed.dart';

enum FavoriteTargetType {
  preset,
  workout,
}

@freezed
abstract class FavoriteRoutine with _$FavoriteRoutine {
  const factory FavoriteRoutine({
    required String id,
    required String targetId,
    required FavoriteTargetType targetType,
    required DateTime createdAt,
  }) = _FavoriteRoutine;
}

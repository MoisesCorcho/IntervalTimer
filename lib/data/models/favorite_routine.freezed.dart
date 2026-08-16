// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'favorite_routine.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FavoriteRoutine {

 String get id; String get targetId; FavoriteTargetType get targetType; DateTime get createdAt;
/// Create a copy of FavoriteRoutine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FavoriteRoutineCopyWith<FavoriteRoutine> get copyWith => _$FavoriteRoutineCopyWithImpl<FavoriteRoutine>(this as FavoriteRoutine, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FavoriteRoutine&&(identical(other.id, id) || other.id == id)&&(identical(other.targetId, targetId) || other.targetId == targetId)&&(identical(other.targetType, targetType) || other.targetType == targetType)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,targetId,targetType,createdAt);

@override
String toString() {
  return 'FavoriteRoutine(id: $id, targetId: $targetId, targetType: $targetType, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $FavoriteRoutineCopyWith<$Res>  {
  factory $FavoriteRoutineCopyWith(FavoriteRoutine value, $Res Function(FavoriteRoutine) _then) = _$FavoriteRoutineCopyWithImpl;
@useResult
$Res call({
 String id, String targetId, FavoriteTargetType targetType, DateTime createdAt
});




}
/// @nodoc
class _$FavoriteRoutineCopyWithImpl<$Res>
    implements $FavoriteRoutineCopyWith<$Res> {
  _$FavoriteRoutineCopyWithImpl(this._self, this._then);

  final FavoriteRoutine _self;
  final $Res Function(FavoriteRoutine) _then;

/// Create a copy of FavoriteRoutine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? targetId = null,Object? targetType = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,targetId: null == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as String,targetType: null == targetType ? _self.targetType : targetType // ignore: cast_nullable_to_non_nullable
as FavoriteTargetType,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FavoriteRoutine].
extension FavoriteRoutinePatterns on FavoriteRoutine {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FavoriteRoutine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FavoriteRoutine() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FavoriteRoutine value)  $default,){
final _that = this;
switch (_that) {
case _FavoriteRoutine():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FavoriteRoutine value)?  $default,){
final _that = this;
switch (_that) {
case _FavoriteRoutine() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String targetId,  FavoriteTargetType targetType,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FavoriteRoutine() when $default != null:
return $default(_that.id,_that.targetId,_that.targetType,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String targetId,  FavoriteTargetType targetType,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _FavoriteRoutine():
return $default(_that.id,_that.targetId,_that.targetType,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String targetId,  FavoriteTargetType targetType,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _FavoriteRoutine() when $default != null:
return $default(_that.id,_that.targetId,_that.targetType,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _FavoriteRoutine implements FavoriteRoutine {
  const _FavoriteRoutine({required this.id, required this.targetId, required this.targetType, required this.createdAt});
  

@override final  String id;
@override final  String targetId;
@override final  FavoriteTargetType targetType;
@override final  DateTime createdAt;

/// Create a copy of FavoriteRoutine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FavoriteRoutineCopyWith<_FavoriteRoutine> get copyWith => __$FavoriteRoutineCopyWithImpl<_FavoriteRoutine>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FavoriteRoutine&&(identical(other.id, id) || other.id == id)&&(identical(other.targetId, targetId) || other.targetId == targetId)&&(identical(other.targetType, targetType) || other.targetType == targetType)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,targetId,targetType,createdAt);

@override
String toString() {
  return 'FavoriteRoutine(id: $id, targetId: $targetId, targetType: $targetType, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$FavoriteRoutineCopyWith<$Res> implements $FavoriteRoutineCopyWith<$Res> {
  factory _$FavoriteRoutineCopyWith(_FavoriteRoutine value, $Res Function(_FavoriteRoutine) _then) = __$FavoriteRoutineCopyWithImpl;
@override @useResult
$Res call({
 String id, String targetId, FavoriteTargetType targetType, DateTime createdAt
});




}
/// @nodoc
class __$FavoriteRoutineCopyWithImpl<$Res>
    implements _$FavoriteRoutineCopyWith<$Res> {
  __$FavoriteRoutineCopyWithImpl(this._self, this._then);

  final _FavoriteRoutine _self;
  final $Res Function(_FavoriteRoutine) _then;

/// Create a copy of FavoriteRoutine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? targetId = null,Object? targetType = null,Object? createdAt = null,}) {
  return _then(_FavoriteRoutine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,targetId: null == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as String,targetType: null == targetType ? _self.targetType : targetType // ignore: cast_nullable_to_non_nullable
as FavoriteTargetType,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on

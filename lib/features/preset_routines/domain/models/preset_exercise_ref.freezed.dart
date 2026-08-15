// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'preset_exercise_ref.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PresetExerciseRef {

 String get exerciseId; int get sets; int get workSeconds; int get restSeconds;
/// Create a copy of PresetExerciseRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PresetExerciseRefCopyWith<PresetExerciseRef> get copyWith => _$PresetExerciseRefCopyWithImpl<PresetExerciseRef>(this as PresetExerciseRef, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PresetExerciseRef&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.workSeconds, workSeconds) || other.workSeconds == workSeconds)&&(identical(other.restSeconds, restSeconds) || other.restSeconds == restSeconds));
}


@override
int get hashCode => Object.hash(runtimeType,exerciseId,sets,workSeconds,restSeconds);

@override
String toString() {
  return 'PresetExerciseRef(exerciseId: $exerciseId, sets: $sets, workSeconds: $workSeconds, restSeconds: $restSeconds)';
}


}

/// @nodoc
abstract mixin class $PresetExerciseRefCopyWith<$Res>  {
  factory $PresetExerciseRefCopyWith(PresetExerciseRef value, $Res Function(PresetExerciseRef) _then) = _$PresetExerciseRefCopyWithImpl;
@useResult
$Res call({
 String exerciseId, int sets, int workSeconds, int restSeconds
});




}
/// @nodoc
class _$PresetExerciseRefCopyWithImpl<$Res>
    implements $PresetExerciseRefCopyWith<$Res> {
  _$PresetExerciseRefCopyWithImpl(this._self, this._then);

  final PresetExerciseRef _self;
  final $Res Function(PresetExerciseRef) _then;

/// Create a copy of PresetExerciseRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? exerciseId = null,Object? sets = null,Object? workSeconds = null,Object? restSeconds = null,}) {
  return _then(_self.copyWith(
exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int,workSeconds: null == workSeconds ? _self.workSeconds : workSeconds // ignore: cast_nullable_to_non_nullable
as int,restSeconds: null == restSeconds ? _self.restSeconds : restSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PresetExerciseRef].
extension PresetExerciseRefPatterns on PresetExerciseRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PresetExerciseRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PresetExerciseRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PresetExerciseRef value)  $default,){
final _that = this;
switch (_that) {
case _PresetExerciseRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PresetExerciseRef value)?  $default,){
final _that = this;
switch (_that) {
case _PresetExerciseRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String exerciseId,  int sets,  int workSeconds,  int restSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PresetExerciseRef() when $default != null:
return $default(_that.exerciseId,_that.sets,_that.workSeconds,_that.restSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String exerciseId,  int sets,  int workSeconds,  int restSeconds)  $default,) {final _that = this;
switch (_that) {
case _PresetExerciseRef():
return $default(_that.exerciseId,_that.sets,_that.workSeconds,_that.restSeconds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String exerciseId,  int sets,  int workSeconds,  int restSeconds)?  $default,) {final _that = this;
switch (_that) {
case _PresetExerciseRef() when $default != null:
return $default(_that.exerciseId,_that.sets,_that.workSeconds,_that.restSeconds);case _:
  return null;

}
}

}

/// @nodoc


class _PresetExerciseRef extends PresetExerciseRef {
  const _PresetExerciseRef({required this.exerciseId, required this.sets, required this.workSeconds, required this.restSeconds}): super._();
  

@override final  String exerciseId;
@override final  int sets;
@override final  int workSeconds;
@override final  int restSeconds;

/// Create a copy of PresetExerciseRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PresetExerciseRefCopyWith<_PresetExerciseRef> get copyWith => __$PresetExerciseRefCopyWithImpl<_PresetExerciseRef>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PresetExerciseRef&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.workSeconds, workSeconds) || other.workSeconds == workSeconds)&&(identical(other.restSeconds, restSeconds) || other.restSeconds == restSeconds));
}


@override
int get hashCode => Object.hash(runtimeType,exerciseId,sets,workSeconds,restSeconds);

@override
String toString() {
  return 'PresetExerciseRef(exerciseId: $exerciseId, sets: $sets, workSeconds: $workSeconds, restSeconds: $restSeconds)';
}


}

/// @nodoc
abstract mixin class _$PresetExerciseRefCopyWith<$Res> implements $PresetExerciseRefCopyWith<$Res> {
  factory _$PresetExerciseRefCopyWith(_PresetExerciseRef value, $Res Function(_PresetExerciseRef) _then) = __$PresetExerciseRefCopyWithImpl;
@override @useResult
$Res call({
 String exerciseId, int sets, int workSeconds, int restSeconds
});




}
/// @nodoc
class __$PresetExerciseRefCopyWithImpl<$Res>
    implements _$PresetExerciseRefCopyWith<$Res> {
  __$PresetExerciseRefCopyWithImpl(this._self, this._then);

  final _PresetExerciseRef _self;
  final $Res Function(_PresetExerciseRef) _then;

/// Create a copy of PresetExerciseRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? exerciseId = null,Object? sets = null,Object? workSeconds = null,Object? restSeconds = null,}) {
  return _then(_PresetExerciseRef(
exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int,workSeconds: null == workSeconds ? _self.workSeconds : workSeconds // ignore: cast_nullable_to_non_nullable
as int,restSeconds: null == restSeconds ? _self.restSeconds : restSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on

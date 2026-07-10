// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_exercise.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WorkoutExercise {

 String get id; String get workoutId; int get position; String get name; int get sets; int get workSeconds; int get restSeconds; int get restAfterExerciseSeconds;
/// Create a copy of WorkoutExercise
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkoutExerciseCopyWith<WorkoutExercise> get copyWith => _$WorkoutExerciseCopyWithImpl<WorkoutExercise>(this as WorkoutExercise, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkoutExercise&&(identical(other.id, id) || other.id == id)&&(identical(other.workoutId, workoutId) || other.workoutId == workoutId)&&(identical(other.position, position) || other.position == position)&&(identical(other.name, name) || other.name == name)&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.workSeconds, workSeconds) || other.workSeconds == workSeconds)&&(identical(other.restSeconds, restSeconds) || other.restSeconds == restSeconds)&&(identical(other.restAfterExerciseSeconds, restAfterExerciseSeconds) || other.restAfterExerciseSeconds == restAfterExerciseSeconds));
}


@override
int get hashCode => Object.hash(runtimeType,id,workoutId,position,name,sets,workSeconds,restSeconds,restAfterExerciseSeconds);

@override
String toString() {
  return 'WorkoutExercise(id: $id, workoutId: $workoutId, position: $position, name: $name, sets: $sets, workSeconds: $workSeconds, restSeconds: $restSeconds, restAfterExerciseSeconds: $restAfterExerciseSeconds)';
}


}

/// @nodoc
abstract mixin class $WorkoutExerciseCopyWith<$Res>  {
  factory $WorkoutExerciseCopyWith(WorkoutExercise value, $Res Function(WorkoutExercise) _then) = _$WorkoutExerciseCopyWithImpl;
@useResult
$Res call({
 String id, String workoutId, int position, String name, int sets, int workSeconds, int restSeconds, int restAfterExerciseSeconds
});




}
/// @nodoc
class _$WorkoutExerciseCopyWithImpl<$Res>
    implements $WorkoutExerciseCopyWith<$Res> {
  _$WorkoutExerciseCopyWithImpl(this._self, this._then);

  final WorkoutExercise _self;
  final $Res Function(WorkoutExercise) _then;

/// Create a copy of WorkoutExercise
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? workoutId = null,Object? position = null,Object? name = null,Object? sets = null,Object? workSeconds = null,Object? restSeconds = null,Object? restAfterExerciseSeconds = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,workoutId: null == workoutId ? _self.workoutId : workoutId // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int,workSeconds: null == workSeconds ? _self.workSeconds : workSeconds // ignore: cast_nullable_to_non_nullable
as int,restSeconds: null == restSeconds ? _self.restSeconds : restSeconds // ignore: cast_nullable_to_non_nullable
as int,restAfterExerciseSeconds: null == restAfterExerciseSeconds ? _self.restAfterExerciseSeconds : restAfterExerciseSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkoutExercise].
extension WorkoutExercisePatterns on WorkoutExercise {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkoutExercise value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkoutExercise() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkoutExercise value)  $default,){
final _that = this;
switch (_that) {
case _WorkoutExercise():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkoutExercise value)?  $default,){
final _that = this;
switch (_that) {
case _WorkoutExercise() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String workoutId,  int position,  String name,  int sets,  int workSeconds,  int restSeconds,  int restAfterExerciseSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkoutExercise() when $default != null:
return $default(_that.id,_that.workoutId,_that.position,_that.name,_that.sets,_that.workSeconds,_that.restSeconds,_that.restAfterExerciseSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String workoutId,  int position,  String name,  int sets,  int workSeconds,  int restSeconds,  int restAfterExerciseSeconds)  $default,) {final _that = this;
switch (_that) {
case _WorkoutExercise():
return $default(_that.id,_that.workoutId,_that.position,_that.name,_that.sets,_that.workSeconds,_that.restSeconds,_that.restAfterExerciseSeconds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String workoutId,  int position,  String name,  int sets,  int workSeconds,  int restSeconds,  int restAfterExerciseSeconds)?  $default,) {final _that = this;
switch (_that) {
case _WorkoutExercise() when $default != null:
return $default(_that.id,_that.workoutId,_that.position,_that.name,_that.sets,_that.workSeconds,_that.restSeconds,_that.restAfterExerciseSeconds);case _:
  return null;

}
}

}

/// @nodoc


class _WorkoutExercise implements WorkoutExercise {
  const _WorkoutExercise({required this.id, required this.workoutId, required this.position, required this.name, required this.sets, required this.workSeconds, required this.restSeconds, this.restAfterExerciseSeconds = 0});
  

@override final  String id;
@override final  String workoutId;
@override final  int position;
@override final  String name;
@override final  int sets;
@override final  int workSeconds;
@override final  int restSeconds;
@override@JsonKey() final  int restAfterExerciseSeconds;

/// Create a copy of WorkoutExercise
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkoutExerciseCopyWith<_WorkoutExercise> get copyWith => __$WorkoutExerciseCopyWithImpl<_WorkoutExercise>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkoutExercise&&(identical(other.id, id) || other.id == id)&&(identical(other.workoutId, workoutId) || other.workoutId == workoutId)&&(identical(other.position, position) || other.position == position)&&(identical(other.name, name) || other.name == name)&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.workSeconds, workSeconds) || other.workSeconds == workSeconds)&&(identical(other.restSeconds, restSeconds) || other.restSeconds == restSeconds)&&(identical(other.restAfterExerciseSeconds, restAfterExerciseSeconds) || other.restAfterExerciseSeconds == restAfterExerciseSeconds));
}


@override
int get hashCode => Object.hash(runtimeType,id,workoutId,position,name,sets,workSeconds,restSeconds,restAfterExerciseSeconds);

@override
String toString() {
  return 'WorkoutExercise(id: $id, workoutId: $workoutId, position: $position, name: $name, sets: $sets, workSeconds: $workSeconds, restSeconds: $restSeconds, restAfterExerciseSeconds: $restAfterExerciseSeconds)';
}


}

/// @nodoc
abstract mixin class _$WorkoutExerciseCopyWith<$Res> implements $WorkoutExerciseCopyWith<$Res> {
  factory _$WorkoutExerciseCopyWith(_WorkoutExercise value, $Res Function(_WorkoutExercise) _then) = __$WorkoutExerciseCopyWithImpl;
@override @useResult
$Res call({
 String id, String workoutId, int position, String name, int sets, int workSeconds, int restSeconds, int restAfterExerciseSeconds
});




}
/// @nodoc
class __$WorkoutExerciseCopyWithImpl<$Res>
    implements _$WorkoutExerciseCopyWith<$Res> {
  __$WorkoutExerciseCopyWithImpl(this._self, this._then);

  final _WorkoutExercise _self;
  final $Res Function(_WorkoutExercise) _then;

/// Create a copy of WorkoutExercise
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? workoutId = null,Object? position = null,Object? name = null,Object? sets = null,Object? workSeconds = null,Object? restSeconds = null,Object? restAfterExerciseSeconds = null,}) {
  return _then(_WorkoutExercise(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,workoutId: null == workoutId ? _self.workoutId : workoutId // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int,workSeconds: null == workSeconds ? _self.workSeconds : workSeconds // ignore: cast_nullable_to_non_nullable
as int,restSeconds: null == restSeconds ? _self.restSeconds : restSeconds // ignore: cast_nullable_to_non_nullable
as int,restAfterExerciseSeconds: null == restAfterExerciseSeconds ? _self.restAfterExerciseSeconds : restAfterExerciseSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on

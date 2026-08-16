// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'preset_routine.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PresetRoutine {

 String get id; String get title; String get description; PresetCategory get category; DifficultyLevel get difficulty; bool get isFeatured; int get restBetweenExercisesSeconds; List<PresetExerciseRef> get exercises;
/// Create a copy of PresetRoutine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PresetRoutineCopyWith<PresetRoutine> get copyWith => _$PresetRoutineCopyWithImpl<PresetRoutine>(this as PresetRoutine, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PresetRoutine&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.isFeatured, isFeatured) || other.isFeatured == isFeatured)&&(identical(other.restBetweenExercisesSeconds, restBetweenExercisesSeconds) || other.restBetweenExercisesSeconds == restBetweenExercisesSeconds)&&const DeepCollectionEquality().equals(other.exercises, exercises));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,description,category,difficulty,isFeatured,restBetweenExercisesSeconds,const DeepCollectionEquality().hash(exercises));

@override
String toString() {
  return 'PresetRoutine(id: $id, title: $title, description: $description, category: $category, difficulty: $difficulty, isFeatured: $isFeatured, restBetweenExercisesSeconds: $restBetweenExercisesSeconds, exercises: $exercises)';
}


}

/// @nodoc
abstract mixin class $PresetRoutineCopyWith<$Res>  {
  factory $PresetRoutineCopyWith(PresetRoutine value, $Res Function(PresetRoutine) _then) = _$PresetRoutineCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, PresetCategory category, DifficultyLevel difficulty, bool isFeatured, int restBetweenExercisesSeconds, List<PresetExerciseRef> exercises
});




}
/// @nodoc
class _$PresetRoutineCopyWithImpl<$Res>
    implements $PresetRoutineCopyWith<$Res> {
  _$PresetRoutineCopyWithImpl(this._self, this._then);

  final PresetRoutine _self;
  final $Res Function(PresetRoutine) _then;

/// Create a copy of PresetRoutine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? category = null,Object? difficulty = null,Object? isFeatured = null,Object? restBetweenExercisesSeconds = null,Object? exercises = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as PresetCategory,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as DifficultyLevel,isFeatured: null == isFeatured ? _self.isFeatured : isFeatured // ignore: cast_nullable_to_non_nullable
as bool,restBetweenExercisesSeconds: null == restBetweenExercisesSeconds ? _self.restBetweenExercisesSeconds : restBetweenExercisesSeconds // ignore: cast_nullable_to_non_nullable
as int,exercises: null == exercises ? _self.exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<PresetExerciseRef>,
  ));
}

}


/// Adds pattern-matching-related methods to [PresetRoutine].
extension PresetRoutinePatterns on PresetRoutine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PresetRoutine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PresetRoutine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PresetRoutine value)  $default,){
final _that = this;
switch (_that) {
case _PresetRoutine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PresetRoutine value)?  $default,){
final _that = this;
switch (_that) {
case _PresetRoutine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  PresetCategory category,  DifficultyLevel difficulty,  bool isFeatured,  int restBetweenExercisesSeconds,  List<PresetExerciseRef> exercises)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PresetRoutine() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.category,_that.difficulty,_that.isFeatured,_that.restBetweenExercisesSeconds,_that.exercises);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  PresetCategory category,  DifficultyLevel difficulty,  bool isFeatured,  int restBetweenExercisesSeconds,  List<PresetExerciseRef> exercises)  $default,) {final _that = this;
switch (_that) {
case _PresetRoutine():
return $default(_that.id,_that.title,_that.description,_that.category,_that.difficulty,_that.isFeatured,_that.restBetweenExercisesSeconds,_that.exercises);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  PresetCategory category,  DifficultyLevel difficulty,  bool isFeatured,  int restBetweenExercisesSeconds,  List<PresetExerciseRef> exercises)?  $default,) {final _that = this;
switch (_that) {
case _PresetRoutine() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.category,_that.difficulty,_that.isFeatured,_that.restBetweenExercisesSeconds,_that.exercises);case _:
  return null;

}
}

}

/// @nodoc


class _PresetRoutine extends PresetRoutine {
  const _PresetRoutine({required this.id, required this.title, required this.description, required this.category, required this.difficulty, this.isFeatured = false, required this.restBetweenExercisesSeconds, required final  List<PresetExerciseRef> exercises}): _exercises = exercises,super._();
  

@override final  String id;
@override final  String title;
@override final  String description;
@override final  PresetCategory category;
@override final  DifficultyLevel difficulty;
@override@JsonKey() final  bool isFeatured;
@override final  int restBetweenExercisesSeconds;
 final  List<PresetExerciseRef> _exercises;
@override List<PresetExerciseRef> get exercises {
  if (_exercises is EqualUnmodifiableListView) return _exercises;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exercises);
}


/// Create a copy of PresetRoutine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PresetRoutineCopyWith<_PresetRoutine> get copyWith => __$PresetRoutineCopyWithImpl<_PresetRoutine>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PresetRoutine&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.isFeatured, isFeatured) || other.isFeatured == isFeatured)&&(identical(other.restBetweenExercisesSeconds, restBetweenExercisesSeconds) || other.restBetweenExercisesSeconds == restBetweenExercisesSeconds)&&const DeepCollectionEquality().equals(other._exercises, _exercises));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,description,category,difficulty,isFeatured,restBetweenExercisesSeconds,const DeepCollectionEquality().hash(_exercises));

@override
String toString() {
  return 'PresetRoutine(id: $id, title: $title, description: $description, category: $category, difficulty: $difficulty, isFeatured: $isFeatured, restBetweenExercisesSeconds: $restBetweenExercisesSeconds, exercises: $exercises)';
}


}

/// @nodoc
abstract mixin class _$PresetRoutineCopyWith<$Res> implements $PresetRoutineCopyWith<$Res> {
  factory _$PresetRoutineCopyWith(_PresetRoutine value, $Res Function(_PresetRoutine) _then) = __$PresetRoutineCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, PresetCategory category, DifficultyLevel difficulty, bool isFeatured, int restBetweenExercisesSeconds, List<PresetExerciseRef> exercises
});




}
/// @nodoc
class __$PresetRoutineCopyWithImpl<$Res>
    implements _$PresetRoutineCopyWith<$Res> {
  __$PresetRoutineCopyWithImpl(this._self, this._then);

  final _PresetRoutine _self;
  final $Res Function(_PresetRoutine) _then;

/// Create a copy of PresetRoutine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? category = null,Object? difficulty = null,Object? isFeatured = null,Object? restBetweenExercisesSeconds = null,Object? exercises = null,}) {
  return _then(_PresetRoutine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as PresetCategory,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as DifficultyLevel,isFeatured: null == isFeatured ? _self.isFeatured : isFeatured // ignore: cast_nullable_to_non_nullable
as bool,restBetweenExercisesSeconds: null == restBetweenExercisesSeconds ? _self.restBetweenExercisesSeconds : restBetweenExercisesSeconds // ignore: cast_nullable_to_non_nullable
as int,exercises: null == exercises ? _self._exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<PresetExerciseRef>,
  ));
}


}

// dart format on

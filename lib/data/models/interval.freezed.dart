// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'interval.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Interval {

 String get id; String get name; int get durationSeconds; int get colorArgb; IntervalType get type;
/// Create a copy of Interval
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IntervalCopyWith<Interval> get copyWith => _$IntervalCopyWithImpl<Interval>(this as Interval, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Interval&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.colorArgb, colorArgb) || other.colorArgb == colorArgb)&&(identical(other.type, type) || other.type == type));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,durationSeconds,colorArgb,type);

@override
String toString() {
  return 'Interval(id: $id, name: $name, durationSeconds: $durationSeconds, colorArgb: $colorArgb, type: $type)';
}


}

/// @nodoc
abstract mixin class $IntervalCopyWith<$Res>  {
  factory $IntervalCopyWith(Interval value, $Res Function(Interval) _then) = _$IntervalCopyWithImpl;
@useResult
$Res call({
 String id, String name, int durationSeconds, int colorArgb, IntervalType type
});




}
/// @nodoc
class _$IntervalCopyWithImpl<$Res>
    implements $IntervalCopyWith<$Res> {
  _$IntervalCopyWithImpl(this._self, this._then);

  final Interval _self;
  final $Res Function(Interval) _then;

/// Create a copy of Interval
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? durationSeconds = null,Object? colorArgb = null,Object? type = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,colorArgb: null == colorArgb ? _self.colorArgb : colorArgb // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as IntervalType,
  ));
}

}


/// Adds pattern-matching-related methods to [Interval].
extension IntervalPatterns on Interval {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Interval value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Interval() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Interval value)  $default,){
final _that = this;
switch (_that) {
case _Interval():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Interval value)?  $default,){
final _that = this;
switch (_that) {
case _Interval() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  int durationSeconds,  int colorArgb,  IntervalType type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Interval() when $default != null:
return $default(_that.id,_that.name,_that.durationSeconds,_that.colorArgb,_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  int durationSeconds,  int colorArgb,  IntervalType type)  $default,) {final _that = this;
switch (_that) {
case _Interval():
return $default(_that.id,_that.name,_that.durationSeconds,_that.colorArgb,_that.type);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  int durationSeconds,  int colorArgb,  IntervalType type)?  $default,) {final _that = this;
switch (_that) {
case _Interval() when $default != null:
return $default(_that.id,_that.name,_that.durationSeconds,_that.colorArgb,_that.type);case _:
  return null;

}
}

}

/// @nodoc


class _Interval implements Interval {
  const _Interval({required this.id, required this.name, required this.durationSeconds, required this.colorArgb, this.type = IntervalType.work});
  

@override final  String id;
@override final  String name;
@override final  int durationSeconds;
@override final  int colorArgb;
@override@JsonKey() final  IntervalType type;

/// Create a copy of Interval
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IntervalCopyWith<_Interval> get copyWith => __$IntervalCopyWithImpl<_Interval>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Interval&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.colorArgb, colorArgb) || other.colorArgb == colorArgb)&&(identical(other.type, type) || other.type == type));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,durationSeconds,colorArgb,type);

@override
String toString() {
  return 'Interval(id: $id, name: $name, durationSeconds: $durationSeconds, colorArgb: $colorArgb, type: $type)';
}


}

/// @nodoc
abstract mixin class _$IntervalCopyWith<$Res> implements $IntervalCopyWith<$Res> {
  factory _$IntervalCopyWith(_Interval value, $Res Function(_Interval) _then) = __$IntervalCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, int durationSeconds, int colorArgb, IntervalType type
});




}
/// @nodoc
class __$IntervalCopyWithImpl<$Res>
    implements _$IntervalCopyWith<$Res> {
  __$IntervalCopyWithImpl(this._self, this._then);

  final _Interval _self;
  final $Res Function(_Interval) _then;

/// Create a copy of Interval
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? durationSeconds = null,Object? colorArgb = null,Object? type = null,}) {
  return _then(_Interval(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,colorArgb: null == colorArgb ? _self.colorArgb : colorArgb // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as IntervalType,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'routine_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RoutineItem {

 Interval get interval;
/// Create a copy of RoutineItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoutineItemCopyWith<RoutineItem> get copyWith => _$RoutineItemCopyWithImpl<RoutineItem>(this as RoutineItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoutineItem&&(identical(other.interval, interval) || other.interval == interval));
}


@override
int get hashCode => Object.hash(runtimeType,interval);

@override
String toString() {
  return 'RoutineItem(interval: $interval)';
}


}

/// @nodoc
abstract mixin class $RoutineItemCopyWith<$Res>  {
  factory $RoutineItemCopyWith(RoutineItem value, $Res Function(RoutineItem) _then) = _$RoutineItemCopyWithImpl;
@useResult
$Res call({
 Interval interval
});


$IntervalCopyWith<$Res> get interval;

}
/// @nodoc
class _$RoutineItemCopyWithImpl<$Res>
    implements $RoutineItemCopyWith<$Res> {
  _$RoutineItemCopyWithImpl(this._self, this._then);

  final RoutineItem _self;
  final $Res Function(RoutineItem) _then;

/// Create a copy of RoutineItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? interval = null,}) {
  return _then(_self.copyWith(
interval: null == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as Interval,
  ));
}
/// Create a copy of RoutineItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IntervalCopyWith<$Res> get interval {
  
  return $IntervalCopyWith<$Res>(_self.interval, (value) {
    return _then(_self.copyWith(interval: value));
  });
}
}


/// Adds pattern-matching-related methods to [RoutineItem].
extension RoutineItemPatterns on RoutineItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( IntervalRoutineItem value)?  interval,required TResult orElse(),}){
final _that = this;
switch (_that) {
case IntervalRoutineItem() when interval != null:
return interval(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( IntervalRoutineItem value)  interval,}){
final _that = this;
switch (_that) {
case IntervalRoutineItem():
return interval(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( IntervalRoutineItem value)?  interval,}){
final _that = this;
switch (_that) {
case IntervalRoutineItem() when interval != null:
return interval(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( Interval interval)?  interval,required TResult orElse(),}) {final _that = this;
switch (_that) {
case IntervalRoutineItem() when interval != null:
return interval(_that.interval);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( Interval interval)  interval,}) {final _that = this;
switch (_that) {
case IntervalRoutineItem():
return interval(_that.interval);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( Interval interval)?  interval,}) {final _that = this;
switch (_that) {
case IntervalRoutineItem() when interval != null:
return interval(_that.interval);case _:
  return null;

}
}

}

/// @nodoc


class IntervalRoutineItem implements RoutineItem {
  const IntervalRoutineItem(this.interval);
  

@override final  Interval interval;

/// Create a copy of RoutineItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IntervalRoutineItemCopyWith<IntervalRoutineItem> get copyWith => _$IntervalRoutineItemCopyWithImpl<IntervalRoutineItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IntervalRoutineItem&&(identical(other.interval, interval) || other.interval == interval));
}


@override
int get hashCode => Object.hash(runtimeType,interval);

@override
String toString() {
  return 'RoutineItem.interval(interval: $interval)';
}


}

/// @nodoc
abstract mixin class $IntervalRoutineItemCopyWith<$Res> implements $RoutineItemCopyWith<$Res> {
  factory $IntervalRoutineItemCopyWith(IntervalRoutineItem value, $Res Function(IntervalRoutineItem) _then) = _$IntervalRoutineItemCopyWithImpl;
@override @useResult
$Res call({
 Interval interval
});


@override $IntervalCopyWith<$Res> get interval;

}
/// @nodoc
class _$IntervalRoutineItemCopyWithImpl<$Res>
    implements $IntervalRoutineItemCopyWith<$Res> {
  _$IntervalRoutineItemCopyWithImpl(this._self, this._then);

  final IntervalRoutineItem _self;
  final $Res Function(IntervalRoutineItem) _then;

/// Create a copy of RoutineItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? interval = null,}) {
  return _then(IntervalRoutineItem(
null == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as Interval,
  ));
}

/// Create a copy of RoutineItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IntervalCopyWith<$Res> get interval {
  
  return $IntervalCopyWith<$Res>(_self.interval, (value) {
    return _then(_self.copyWith(interval: value));
  });
}
}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timer_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TimerState {

 TimerStatus get status; Routine? get routine; int get currentIndex; int get remainingMs; int get currentIntervalDurationMs; bool get isPausePending; DateTime? get segmentStartTimestamp; int get pausedAccumulatedMs; DateTime? get sessionStartTimestamp; int get tick;/// Snapshot of prep seconds taken at [TimerController.start] (R20).
 int get sessionPrepSeconds; SegmentKind get segmentKind;
/// Create a copy of TimerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimerStateCopyWith<TimerState> get copyWith => _$TimerStateCopyWithImpl<TimerState>(this as TimerState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimerState&&(identical(other.status, status) || other.status == status)&&(identical(other.routine, routine) || other.routine == routine)&&(identical(other.currentIndex, currentIndex) || other.currentIndex == currentIndex)&&(identical(other.remainingMs, remainingMs) || other.remainingMs == remainingMs)&&(identical(other.currentIntervalDurationMs, currentIntervalDurationMs) || other.currentIntervalDurationMs == currentIntervalDurationMs)&&(identical(other.isPausePending, isPausePending) || other.isPausePending == isPausePending)&&(identical(other.segmentStartTimestamp, segmentStartTimestamp) || other.segmentStartTimestamp == segmentStartTimestamp)&&(identical(other.pausedAccumulatedMs, pausedAccumulatedMs) || other.pausedAccumulatedMs == pausedAccumulatedMs)&&(identical(other.sessionStartTimestamp, sessionStartTimestamp) || other.sessionStartTimestamp == sessionStartTimestamp)&&(identical(other.tick, tick) || other.tick == tick)&&(identical(other.sessionPrepSeconds, sessionPrepSeconds) || other.sessionPrepSeconds == sessionPrepSeconds)&&(identical(other.segmentKind, segmentKind) || other.segmentKind == segmentKind));
}


@override
int get hashCode => Object.hash(runtimeType,status,routine,currentIndex,remainingMs,currentIntervalDurationMs,isPausePending,segmentStartTimestamp,pausedAccumulatedMs,sessionStartTimestamp,tick,sessionPrepSeconds,segmentKind);

@override
String toString() {
  return 'TimerState(status: $status, routine: $routine, currentIndex: $currentIndex, remainingMs: $remainingMs, currentIntervalDurationMs: $currentIntervalDurationMs, isPausePending: $isPausePending, segmentStartTimestamp: $segmentStartTimestamp, pausedAccumulatedMs: $pausedAccumulatedMs, sessionStartTimestamp: $sessionStartTimestamp, tick: $tick, sessionPrepSeconds: $sessionPrepSeconds, segmentKind: $segmentKind)';
}


}

/// @nodoc
abstract mixin class $TimerStateCopyWith<$Res>  {
  factory $TimerStateCopyWith(TimerState value, $Res Function(TimerState) _then) = _$TimerStateCopyWithImpl;
@useResult
$Res call({
 TimerStatus status, Routine? routine, int currentIndex, int remainingMs, int currentIntervalDurationMs, bool isPausePending, DateTime? segmentStartTimestamp, int pausedAccumulatedMs, DateTime? sessionStartTimestamp, int tick, int sessionPrepSeconds, SegmentKind segmentKind
});


$RoutineCopyWith<$Res>? get routine;

}
/// @nodoc
class _$TimerStateCopyWithImpl<$Res>
    implements $TimerStateCopyWith<$Res> {
  _$TimerStateCopyWithImpl(this._self, this._then);

  final TimerState _self;
  final $Res Function(TimerState) _then;

/// Create a copy of TimerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? routine = freezed,Object? currentIndex = null,Object? remainingMs = null,Object? currentIntervalDurationMs = null,Object? isPausePending = null,Object? segmentStartTimestamp = freezed,Object? pausedAccumulatedMs = null,Object? sessionStartTimestamp = freezed,Object? tick = null,Object? sessionPrepSeconds = null,Object? segmentKind = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TimerStatus,routine: freezed == routine ? _self.routine : routine // ignore: cast_nullable_to_non_nullable
as Routine?,currentIndex: null == currentIndex ? _self.currentIndex : currentIndex // ignore: cast_nullable_to_non_nullable
as int,remainingMs: null == remainingMs ? _self.remainingMs : remainingMs // ignore: cast_nullable_to_non_nullable
as int,currentIntervalDurationMs: null == currentIntervalDurationMs ? _self.currentIntervalDurationMs : currentIntervalDurationMs // ignore: cast_nullable_to_non_nullable
as int,isPausePending: null == isPausePending ? _self.isPausePending : isPausePending // ignore: cast_nullable_to_non_nullable
as bool,segmentStartTimestamp: freezed == segmentStartTimestamp ? _self.segmentStartTimestamp : segmentStartTimestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,pausedAccumulatedMs: null == pausedAccumulatedMs ? _self.pausedAccumulatedMs : pausedAccumulatedMs // ignore: cast_nullable_to_non_nullable
as int,sessionStartTimestamp: freezed == sessionStartTimestamp ? _self.sessionStartTimestamp : sessionStartTimestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,tick: null == tick ? _self.tick : tick // ignore: cast_nullable_to_non_nullable
as int,sessionPrepSeconds: null == sessionPrepSeconds ? _self.sessionPrepSeconds : sessionPrepSeconds // ignore: cast_nullable_to_non_nullable
as int,segmentKind: null == segmentKind ? _self.segmentKind : segmentKind // ignore: cast_nullable_to_non_nullable
as SegmentKind,
  ));
}
/// Create a copy of TimerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RoutineCopyWith<$Res>? get routine {
    if (_self.routine == null) {
    return null;
  }

  return $RoutineCopyWith<$Res>(_self.routine!, (value) {
    return _then(_self.copyWith(routine: value));
  });
}
}


/// Adds pattern-matching-related methods to [TimerState].
extension TimerStatePatterns on TimerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimerState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimerState value)  $default,){
final _that = this;
switch (_that) {
case _TimerState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimerState value)?  $default,){
final _that = this;
switch (_that) {
case _TimerState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TimerStatus status,  Routine? routine,  int currentIndex,  int remainingMs,  int currentIntervalDurationMs,  bool isPausePending,  DateTime? segmentStartTimestamp,  int pausedAccumulatedMs,  DateTime? sessionStartTimestamp,  int tick,  int sessionPrepSeconds,  SegmentKind segmentKind)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TimerState() when $default != null:
return $default(_that.status,_that.routine,_that.currentIndex,_that.remainingMs,_that.currentIntervalDurationMs,_that.isPausePending,_that.segmentStartTimestamp,_that.pausedAccumulatedMs,_that.sessionStartTimestamp,_that.tick,_that.sessionPrepSeconds,_that.segmentKind);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TimerStatus status,  Routine? routine,  int currentIndex,  int remainingMs,  int currentIntervalDurationMs,  bool isPausePending,  DateTime? segmentStartTimestamp,  int pausedAccumulatedMs,  DateTime? sessionStartTimestamp,  int tick,  int sessionPrepSeconds,  SegmentKind segmentKind)  $default,) {final _that = this;
switch (_that) {
case _TimerState():
return $default(_that.status,_that.routine,_that.currentIndex,_that.remainingMs,_that.currentIntervalDurationMs,_that.isPausePending,_that.segmentStartTimestamp,_that.pausedAccumulatedMs,_that.sessionStartTimestamp,_that.tick,_that.sessionPrepSeconds,_that.segmentKind);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TimerStatus status,  Routine? routine,  int currentIndex,  int remainingMs,  int currentIntervalDurationMs,  bool isPausePending,  DateTime? segmentStartTimestamp,  int pausedAccumulatedMs,  DateTime? sessionStartTimestamp,  int tick,  int sessionPrepSeconds,  SegmentKind segmentKind)?  $default,) {final _that = this;
switch (_that) {
case _TimerState() when $default != null:
return $default(_that.status,_that.routine,_that.currentIndex,_that.remainingMs,_that.currentIntervalDurationMs,_that.isPausePending,_that.segmentStartTimestamp,_that.pausedAccumulatedMs,_that.sessionStartTimestamp,_that.tick,_that.sessionPrepSeconds,_that.segmentKind);case _:
  return null;

}
}

}

/// @nodoc


class _TimerState extends TimerState {
  const _TimerState({this.status = TimerStatus.idle, this.routine, this.currentIndex = 0, this.remainingMs = 0, this.currentIntervalDurationMs = 0, this.isPausePending = false, this.segmentStartTimestamp, this.pausedAccumulatedMs = 0, this.sessionStartTimestamp, this.tick = 0, this.sessionPrepSeconds = 0, this.segmentKind = SegmentKind.interval}): super._();
  

@override@JsonKey() final  TimerStatus status;
@override final  Routine? routine;
@override@JsonKey() final  int currentIndex;
@override@JsonKey() final  int remainingMs;
@override@JsonKey() final  int currentIntervalDurationMs;
@override@JsonKey() final  bool isPausePending;
@override final  DateTime? segmentStartTimestamp;
@override@JsonKey() final  int pausedAccumulatedMs;
@override final  DateTime? sessionStartTimestamp;
@override@JsonKey() final  int tick;
/// Snapshot of prep seconds taken at [TimerController.start] (R20).
@override@JsonKey() final  int sessionPrepSeconds;
@override@JsonKey() final  SegmentKind segmentKind;

/// Create a copy of TimerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimerStateCopyWith<_TimerState> get copyWith => __$TimerStateCopyWithImpl<_TimerState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimerState&&(identical(other.status, status) || other.status == status)&&(identical(other.routine, routine) || other.routine == routine)&&(identical(other.currentIndex, currentIndex) || other.currentIndex == currentIndex)&&(identical(other.remainingMs, remainingMs) || other.remainingMs == remainingMs)&&(identical(other.currentIntervalDurationMs, currentIntervalDurationMs) || other.currentIntervalDurationMs == currentIntervalDurationMs)&&(identical(other.isPausePending, isPausePending) || other.isPausePending == isPausePending)&&(identical(other.segmentStartTimestamp, segmentStartTimestamp) || other.segmentStartTimestamp == segmentStartTimestamp)&&(identical(other.pausedAccumulatedMs, pausedAccumulatedMs) || other.pausedAccumulatedMs == pausedAccumulatedMs)&&(identical(other.sessionStartTimestamp, sessionStartTimestamp) || other.sessionStartTimestamp == sessionStartTimestamp)&&(identical(other.tick, tick) || other.tick == tick)&&(identical(other.sessionPrepSeconds, sessionPrepSeconds) || other.sessionPrepSeconds == sessionPrepSeconds)&&(identical(other.segmentKind, segmentKind) || other.segmentKind == segmentKind));
}


@override
int get hashCode => Object.hash(runtimeType,status,routine,currentIndex,remainingMs,currentIntervalDurationMs,isPausePending,segmentStartTimestamp,pausedAccumulatedMs,sessionStartTimestamp,tick,sessionPrepSeconds,segmentKind);

@override
String toString() {
  return 'TimerState(status: $status, routine: $routine, currentIndex: $currentIndex, remainingMs: $remainingMs, currentIntervalDurationMs: $currentIntervalDurationMs, isPausePending: $isPausePending, segmentStartTimestamp: $segmentStartTimestamp, pausedAccumulatedMs: $pausedAccumulatedMs, sessionStartTimestamp: $sessionStartTimestamp, tick: $tick, sessionPrepSeconds: $sessionPrepSeconds, segmentKind: $segmentKind)';
}


}

/// @nodoc
abstract mixin class _$TimerStateCopyWith<$Res> implements $TimerStateCopyWith<$Res> {
  factory _$TimerStateCopyWith(_TimerState value, $Res Function(_TimerState) _then) = __$TimerStateCopyWithImpl;
@override @useResult
$Res call({
 TimerStatus status, Routine? routine, int currentIndex, int remainingMs, int currentIntervalDurationMs, bool isPausePending, DateTime? segmentStartTimestamp, int pausedAccumulatedMs, DateTime? sessionStartTimestamp, int tick, int sessionPrepSeconds, SegmentKind segmentKind
});


@override $RoutineCopyWith<$Res>? get routine;

}
/// @nodoc
class __$TimerStateCopyWithImpl<$Res>
    implements _$TimerStateCopyWith<$Res> {
  __$TimerStateCopyWithImpl(this._self, this._then);

  final _TimerState _self;
  final $Res Function(_TimerState) _then;

/// Create a copy of TimerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? routine = freezed,Object? currentIndex = null,Object? remainingMs = null,Object? currentIntervalDurationMs = null,Object? isPausePending = null,Object? segmentStartTimestamp = freezed,Object? pausedAccumulatedMs = null,Object? sessionStartTimestamp = freezed,Object? tick = null,Object? sessionPrepSeconds = null,Object? segmentKind = null,}) {
  return _then(_TimerState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TimerStatus,routine: freezed == routine ? _self.routine : routine // ignore: cast_nullable_to_non_nullable
as Routine?,currentIndex: null == currentIndex ? _self.currentIndex : currentIndex // ignore: cast_nullable_to_non_nullable
as int,remainingMs: null == remainingMs ? _self.remainingMs : remainingMs // ignore: cast_nullable_to_non_nullable
as int,currentIntervalDurationMs: null == currentIntervalDurationMs ? _self.currentIntervalDurationMs : currentIntervalDurationMs // ignore: cast_nullable_to_non_nullable
as int,isPausePending: null == isPausePending ? _self.isPausePending : isPausePending // ignore: cast_nullable_to_non_nullable
as bool,segmentStartTimestamp: freezed == segmentStartTimestamp ? _self.segmentStartTimestamp : segmentStartTimestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,pausedAccumulatedMs: null == pausedAccumulatedMs ? _self.pausedAccumulatedMs : pausedAccumulatedMs // ignore: cast_nullable_to_non_nullable
as int,sessionStartTimestamp: freezed == sessionStartTimestamp ? _self.sessionStartTimestamp : sessionStartTimestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,tick: null == tick ? _self.tick : tick // ignore: cast_nullable_to_non_nullable
as int,sessionPrepSeconds: null == sessionPrepSeconds ? _self.sessionPrepSeconds : sessionPrepSeconds // ignore: cast_nullable_to_non_nullable
as int,segmentKind: null == segmentKind ? _self.segmentKind : segmentKind // ignore: cast_nullable_to_non_nullable
as SegmentKind,
  ));
}

/// Create a copy of TimerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RoutineCopyWith<$Res>? get routine {
    if (_self.routine == null) {
    return null;
  }

  return $RoutineCopyWith<$Res>(_self.routine!, (value) {
    return _then(_self.copyWith(routine: value));
  });
}
}

// dart format on

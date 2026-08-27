// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'season.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Season {

 String get id; String get label; DateTime get launchDate; DateTime get deliveryDeadline; bool get enrollmentOpen; int get refundFee; bool get isCurrent;
/// Create a copy of Season
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SeasonCopyWith<Season> get copyWith => _$SeasonCopyWithImpl<Season>(this as Season, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Season&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.launchDate, launchDate) || other.launchDate == launchDate)&&(identical(other.deliveryDeadline, deliveryDeadline) || other.deliveryDeadline == deliveryDeadline)&&(identical(other.enrollmentOpen, enrollmentOpen) || other.enrollmentOpen == enrollmentOpen)&&(identical(other.refundFee, refundFee) || other.refundFee == refundFee)&&(identical(other.isCurrent, isCurrent) || other.isCurrent == isCurrent));
}


@override
int get hashCode => Object.hash(runtimeType,id,label,launchDate,deliveryDeadline,enrollmentOpen,refundFee,isCurrent);

@override
String toString() {
  return 'Season(id: $id, label: $label, launchDate: $launchDate, deliveryDeadline: $deliveryDeadline, enrollmentOpen: $enrollmentOpen, refundFee: $refundFee, isCurrent: $isCurrent)';
}


}

/// @nodoc
abstract mixin class $SeasonCopyWith<$Res>  {
  factory $SeasonCopyWith(Season value, $Res Function(Season) _then) = _$SeasonCopyWithImpl;
@useResult
$Res call({
 String id, String label, DateTime launchDate, DateTime deliveryDeadline, bool enrollmentOpen, int refundFee, bool isCurrent
});




}
/// @nodoc
class _$SeasonCopyWithImpl<$Res>
    implements $SeasonCopyWith<$Res> {
  _$SeasonCopyWithImpl(this._self, this._then);

  final Season _self;
  final $Res Function(Season) _then;

/// Create a copy of Season
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? launchDate = null,Object? deliveryDeadline = null,Object? enrollmentOpen = null,Object? refundFee = null,Object? isCurrent = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,launchDate: null == launchDate ? _self.launchDate : launchDate // ignore: cast_nullable_to_non_nullable
as DateTime,deliveryDeadline: null == deliveryDeadline ? _self.deliveryDeadline : deliveryDeadline // ignore: cast_nullable_to_non_nullable
as DateTime,enrollmentOpen: null == enrollmentOpen ? _self.enrollmentOpen : enrollmentOpen // ignore: cast_nullable_to_non_nullable
as bool,refundFee: null == refundFee ? _self.refundFee : refundFee // ignore: cast_nullable_to_non_nullable
as int,isCurrent: null == isCurrent ? _self.isCurrent : isCurrent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Season].
extension SeasonPatterns on Season {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Season value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Season() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Season value)  $default,){
final _that = this;
switch (_that) {
case _Season():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Season value)?  $default,){
final _that = this;
switch (_that) {
case _Season() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String label,  DateTime launchDate,  DateTime deliveryDeadline,  bool enrollmentOpen,  int refundFee,  bool isCurrent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Season() when $default != null:
return $default(_that.id,_that.label,_that.launchDate,_that.deliveryDeadline,_that.enrollmentOpen,_that.refundFee,_that.isCurrent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String label,  DateTime launchDate,  DateTime deliveryDeadline,  bool enrollmentOpen,  int refundFee,  bool isCurrent)  $default,) {final _that = this;
switch (_that) {
case _Season():
return $default(_that.id,_that.label,_that.launchDate,_that.deliveryDeadline,_that.enrollmentOpen,_that.refundFee,_that.isCurrent);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String label,  DateTime launchDate,  DateTime deliveryDeadline,  bool enrollmentOpen,  int refundFee,  bool isCurrent)?  $default,) {final _that = this;
switch (_that) {
case _Season() when $default != null:
return $default(_that.id,_that.label,_that.launchDate,_that.deliveryDeadline,_that.enrollmentOpen,_that.refundFee,_that.isCurrent);case _:
  return null;

}
}

}

/// @nodoc


class _Season implements Season {
  const _Season({required this.id, required this.label, required this.launchDate, required this.deliveryDeadline, required this.enrollmentOpen, required this.refundFee, required this.isCurrent});
  

@override final  String id;
@override final  String label;
@override final  DateTime launchDate;
@override final  DateTime deliveryDeadline;
@override final  bool enrollmentOpen;
@override final  int refundFee;
@override final  bool isCurrent;

/// Create a copy of Season
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SeasonCopyWith<_Season> get copyWith => __$SeasonCopyWithImpl<_Season>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Season&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.launchDate, launchDate) || other.launchDate == launchDate)&&(identical(other.deliveryDeadline, deliveryDeadline) || other.deliveryDeadline == deliveryDeadline)&&(identical(other.enrollmentOpen, enrollmentOpen) || other.enrollmentOpen == enrollmentOpen)&&(identical(other.refundFee, refundFee) || other.refundFee == refundFee)&&(identical(other.isCurrent, isCurrent) || other.isCurrent == isCurrent));
}


@override
int get hashCode => Object.hash(runtimeType,id,label,launchDate,deliveryDeadline,enrollmentOpen,refundFee,isCurrent);

@override
String toString() {
  return 'Season(id: $id, label: $label, launchDate: $launchDate, deliveryDeadline: $deliveryDeadline, enrollmentOpen: $enrollmentOpen, refundFee: $refundFee, isCurrent: $isCurrent)';
}


}

/// @nodoc
abstract mixin class _$SeasonCopyWith<$Res> implements $SeasonCopyWith<$Res> {
  factory _$SeasonCopyWith(_Season value, $Res Function(_Season) _then) = __$SeasonCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, DateTime launchDate, DateTime deliveryDeadline, bool enrollmentOpen, int refundFee, bool isCurrent
});




}
/// @nodoc
class __$SeasonCopyWithImpl<$Res>
    implements _$SeasonCopyWith<$Res> {
  __$SeasonCopyWithImpl(this._self, this._then);

  final _Season _self;
  final $Res Function(_Season) _then;

/// Create a copy of Season
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? launchDate = null,Object? deliveryDeadline = null,Object? enrollmentOpen = null,Object? refundFee = null,Object? isCurrent = null,}) {
  return _then(_Season(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,launchDate: null == launchDate ? _self.launchDate : launchDate // ignore: cast_nullable_to_non_nullable
as DateTime,deliveryDeadline: null == deliveryDeadline ? _self.deliveryDeadline : deliveryDeadline // ignore: cast_nullable_to_non_nullable
as DateTime,enrollmentOpen: null == enrollmentOpen ? _self.enrollmentOpen : enrollmentOpen // ignore: cast_nullable_to_non_nullable
as bool,refundFee: null == refundFee ? _self.refundFee : refundFee // ignore: cast_nullable_to_non_nullable
as int,isCurrent: null == isCurrent ? _self.isCurrent : isCurrent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on

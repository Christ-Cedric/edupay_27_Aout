// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'refund_month_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RefundMonthSummary {

 int get approvedCount; double get approvedAmount; double get feesRetained;
/// Create a copy of RefundMonthSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RefundMonthSummaryCopyWith<RefundMonthSummary> get copyWith => _$RefundMonthSummaryCopyWithImpl<RefundMonthSummary>(this as RefundMonthSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RefundMonthSummary&&(identical(other.approvedCount, approvedCount) || other.approvedCount == approvedCount)&&(identical(other.approvedAmount, approvedAmount) || other.approvedAmount == approvedAmount)&&(identical(other.feesRetained, feesRetained) || other.feesRetained == feesRetained));
}


@override
int get hashCode => Object.hash(runtimeType,approvedCount,approvedAmount,feesRetained);

@override
String toString() {
  return 'RefundMonthSummary(approvedCount: $approvedCount, approvedAmount: $approvedAmount, feesRetained: $feesRetained)';
}


}

/// @nodoc
abstract mixin class $RefundMonthSummaryCopyWith<$Res>  {
  factory $RefundMonthSummaryCopyWith(RefundMonthSummary value, $Res Function(RefundMonthSummary) _then) = _$RefundMonthSummaryCopyWithImpl;
@useResult
$Res call({
 int approvedCount, double approvedAmount, double feesRetained
});




}
/// @nodoc
class _$RefundMonthSummaryCopyWithImpl<$Res>
    implements $RefundMonthSummaryCopyWith<$Res> {
  _$RefundMonthSummaryCopyWithImpl(this._self, this._then);

  final RefundMonthSummary _self;
  final $Res Function(RefundMonthSummary) _then;

/// Create a copy of RefundMonthSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? approvedCount = null,Object? approvedAmount = null,Object? feesRetained = null,}) {
  return _then(_self.copyWith(
approvedCount: null == approvedCount ? _self.approvedCount : approvedCount // ignore: cast_nullable_to_non_nullable
as int,approvedAmount: null == approvedAmount ? _self.approvedAmount : approvedAmount // ignore: cast_nullable_to_non_nullable
as double,feesRetained: null == feesRetained ? _self.feesRetained : feesRetained // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [RefundMonthSummary].
extension RefundMonthSummaryPatterns on RefundMonthSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RefundMonthSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RefundMonthSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RefundMonthSummary value)  $default,){
final _that = this;
switch (_that) {
case _RefundMonthSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RefundMonthSummary value)?  $default,){
final _that = this;
switch (_that) {
case _RefundMonthSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int approvedCount,  double approvedAmount,  double feesRetained)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RefundMonthSummary() when $default != null:
return $default(_that.approvedCount,_that.approvedAmount,_that.feesRetained);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int approvedCount,  double approvedAmount,  double feesRetained)  $default,) {final _that = this;
switch (_that) {
case _RefundMonthSummary():
return $default(_that.approvedCount,_that.approvedAmount,_that.feesRetained);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int approvedCount,  double approvedAmount,  double feesRetained)?  $default,) {final _that = this;
switch (_that) {
case _RefundMonthSummary() when $default != null:
return $default(_that.approvedCount,_that.approvedAmount,_that.feesRetained);case _:
  return null;

}
}

}

/// @nodoc


class _RefundMonthSummary implements RefundMonthSummary {
  const _RefundMonthSummary({required this.approvedCount, required this.approvedAmount, required this.feesRetained});
  

@override final  int approvedCount;
@override final  double approvedAmount;
@override final  double feesRetained;

/// Create a copy of RefundMonthSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RefundMonthSummaryCopyWith<_RefundMonthSummary> get copyWith => __$RefundMonthSummaryCopyWithImpl<_RefundMonthSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RefundMonthSummary&&(identical(other.approvedCount, approvedCount) || other.approvedCount == approvedCount)&&(identical(other.approvedAmount, approvedAmount) || other.approvedAmount == approvedAmount)&&(identical(other.feesRetained, feesRetained) || other.feesRetained == feesRetained));
}


@override
int get hashCode => Object.hash(runtimeType,approvedCount,approvedAmount,feesRetained);

@override
String toString() {
  return 'RefundMonthSummary(approvedCount: $approvedCount, approvedAmount: $approvedAmount, feesRetained: $feesRetained)';
}


}

/// @nodoc
abstract mixin class _$RefundMonthSummaryCopyWith<$Res> implements $RefundMonthSummaryCopyWith<$Res> {
  factory _$RefundMonthSummaryCopyWith(_RefundMonthSummary value, $Res Function(_RefundMonthSummary) _then) = __$RefundMonthSummaryCopyWithImpl;
@override @useResult
$Res call({
 int approvedCount, double approvedAmount, double feesRetained
});




}
/// @nodoc
class __$RefundMonthSummaryCopyWithImpl<$Res>
    implements _$RefundMonthSummaryCopyWith<$Res> {
  __$RefundMonthSummaryCopyWithImpl(this._self, this._then);

  final _RefundMonthSummary _self;
  final $Res Function(_RefundMonthSummary) _then;

/// Create a copy of RefundMonthSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? approvedCount = null,Object? approvedAmount = null,Object? feesRetained = null,}) {
  return _then(_RefundMonthSummary(
approvedCount: null == approvedCount ? _self.approvedCount : approvedCount // ignore: cast_nullable_to_non_nullable
as int,approvedAmount: null == approvedAmount ? _self.approvedAmount : approvedAmount // ignore: cast_nullable_to_non_nullable
as double,feesRetained: null == feesRetained ? _self.feesRetained : feesRetained // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on

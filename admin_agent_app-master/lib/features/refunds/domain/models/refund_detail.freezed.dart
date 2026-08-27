// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'refund_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RefundDetail {

 String get id; String get reference; String get familyName; double get amount; String get reason; RefundStatus get status; String? get processedByAdminName; DateTime get createdAt;
/// Create a copy of RefundDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RefundDetailCopyWith<RefundDetail> get copyWith => _$RefundDetailCopyWithImpl<RefundDetail>(this as RefundDetail, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RefundDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.familyName, familyName) || other.familyName == familyName)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.status, status) || other.status == status)&&(identical(other.processedByAdminName, processedByAdminName) || other.processedByAdminName == processedByAdminName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,reference,familyName,amount,reason,status,processedByAdminName,createdAt);

@override
String toString() {
  return 'RefundDetail(id: $id, reference: $reference, familyName: $familyName, amount: $amount, reason: $reason, status: $status, processedByAdminName: $processedByAdminName, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $RefundDetailCopyWith<$Res>  {
  factory $RefundDetailCopyWith(RefundDetail value, $Res Function(RefundDetail) _then) = _$RefundDetailCopyWithImpl;
@useResult
$Res call({
 String id, String reference, String familyName, double amount, String reason, RefundStatus status, String? processedByAdminName, DateTime createdAt
});




}
/// @nodoc
class _$RefundDetailCopyWithImpl<$Res>
    implements $RefundDetailCopyWith<$Res> {
  _$RefundDetailCopyWithImpl(this._self, this._then);

  final RefundDetail _self;
  final $Res Function(RefundDetail) _then;

/// Create a copy of RefundDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reference = null,Object? familyName = null,Object? amount = null,Object? reason = null,Object? status = null,Object? processedByAdminName = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reference: null == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String,familyName: null == familyName ? _self.familyName : familyName // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RefundStatus,processedByAdminName: freezed == processedByAdminName ? _self.processedByAdminName : processedByAdminName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [RefundDetail].
extension RefundDetailPatterns on RefundDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RefundDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RefundDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RefundDetail value)  $default,){
final _that = this;
switch (_that) {
case _RefundDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RefundDetail value)?  $default,){
final _that = this;
switch (_that) {
case _RefundDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String reference,  String familyName,  double amount,  String reason,  RefundStatus status,  String? processedByAdminName,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RefundDetail() when $default != null:
return $default(_that.id,_that.reference,_that.familyName,_that.amount,_that.reason,_that.status,_that.processedByAdminName,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String reference,  String familyName,  double amount,  String reason,  RefundStatus status,  String? processedByAdminName,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _RefundDetail():
return $default(_that.id,_that.reference,_that.familyName,_that.amount,_that.reason,_that.status,_that.processedByAdminName,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String reference,  String familyName,  double amount,  String reason,  RefundStatus status,  String? processedByAdminName,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _RefundDetail() when $default != null:
return $default(_that.id,_that.reference,_that.familyName,_that.amount,_that.reason,_that.status,_that.processedByAdminName,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _RefundDetail implements RefundDetail {
  const _RefundDetail({required this.id, required this.reference, required this.familyName, required this.amount, required this.reason, required this.status, this.processedByAdminName, required this.createdAt});
  

@override final  String id;
@override final  String reference;
@override final  String familyName;
@override final  double amount;
@override final  String reason;
@override final  RefundStatus status;
@override final  String? processedByAdminName;
@override final  DateTime createdAt;

/// Create a copy of RefundDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RefundDetailCopyWith<_RefundDetail> get copyWith => __$RefundDetailCopyWithImpl<_RefundDetail>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RefundDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.familyName, familyName) || other.familyName == familyName)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.status, status) || other.status == status)&&(identical(other.processedByAdminName, processedByAdminName) || other.processedByAdminName == processedByAdminName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,reference,familyName,amount,reason,status,processedByAdminName,createdAt);

@override
String toString() {
  return 'RefundDetail(id: $id, reference: $reference, familyName: $familyName, amount: $amount, reason: $reason, status: $status, processedByAdminName: $processedByAdminName, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$RefundDetailCopyWith<$Res> implements $RefundDetailCopyWith<$Res> {
  factory _$RefundDetailCopyWith(_RefundDetail value, $Res Function(_RefundDetail) _then) = __$RefundDetailCopyWithImpl;
@override @useResult
$Res call({
 String id, String reference, String familyName, double amount, String reason, RefundStatus status, String? processedByAdminName, DateTime createdAt
});




}
/// @nodoc
class __$RefundDetailCopyWithImpl<$Res>
    implements _$RefundDetailCopyWith<$Res> {
  __$RefundDetailCopyWithImpl(this._self, this._then);

  final _RefundDetail _self;
  final $Res Function(_RefundDetail) _then;

/// Create a copy of RefundDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reference = null,Object? familyName = null,Object? amount = null,Object? reason = null,Object? status = null,Object? processedByAdminName = freezed,Object? createdAt = null,}) {
  return _then(_RefundDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reference: null == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String,familyName: null == familyName ? _self.familyName : familyName // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RefundStatus,processedByAdminName: freezed == processedByAdminName ? _self.processedByAdminName : processedByAdminName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on

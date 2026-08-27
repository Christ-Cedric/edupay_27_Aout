// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'supply.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Supply {

 String get id; String get category; String get label; String get unit; double get unitPrice;
/// Create a copy of Supply
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SupplyCopyWith<Supply> get copyWith => _$SupplyCopyWithImpl<Supply>(this as Supply, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Supply&&(identical(other.id, id) || other.id == id)&&(identical(other.category, category) || other.category == category)&&(identical(other.label, label) || other.label == label)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice));
}


@override
int get hashCode => Object.hash(runtimeType,id,category,label,unit,unitPrice);

@override
String toString() {
  return 'Supply(id: $id, category: $category, label: $label, unit: $unit, unitPrice: $unitPrice)';
}


}

/// @nodoc
abstract mixin class $SupplyCopyWith<$Res>  {
  factory $SupplyCopyWith(Supply value, $Res Function(Supply) _then) = _$SupplyCopyWithImpl;
@useResult
$Res call({
 String id, String category, String label, String unit, double unitPrice
});




}
/// @nodoc
class _$SupplyCopyWithImpl<$Res>
    implements $SupplyCopyWith<$Res> {
  _$SupplyCopyWithImpl(this._self, this._then);

  final Supply _self;
  final $Res Function(Supply) _then;

/// Create a copy of Supply
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? category = null,Object? label = null,Object? unit = null,Object? unitPrice = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [Supply].
extension SupplyPatterns on Supply {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Supply value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Supply() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Supply value)  $default,){
final _that = this;
switch (_that) {
case _Supply():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Supply value)?  $default,){
final _that = this;
switch (_that) {
case _Supply() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String category,  String label,  String unit,  double unitPrice)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Supply() when $default != null:
return $default(_that.id,_that.category,_that.label,_that.unit,_that.unitPrice);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String category,  String label,  String unit,  double unitPrice)  $default,) {final _that = this;
switch (_that) {
case _Supply():
return $default(_that.id,_that.category,_that.label,_that.unit,_that.unitPrice);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String category,  String label,  String unit,  double unitPrice)?  $default,) {final _that = this;
switch (_that) {
case _Supply() when $default != null:
return $default(_that.id,_that.category,_that.label,_that.unit,_that.unitPrice);case _:
  return null;

}
}

}

/// @nodoc


class _Supply implements Supply {
  const _Supply({required this.id, required this.category, required this.label, required this.unit, required this.unitPrice});
  

@override final  String id;
@override final  String category;
@override final  String label;
@override final  String unit;
@override final  double unitPrice;

/// Create a copy of Supply
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SupplyCopyWith<_Supply> get copyWith => __$SupplyCopyWithImpl<_Supply>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Supply&&(identical(other.id, id) || other.id == id)&&(identical(other.category, category) || other.category == category)&&(identical(other.label, label) || other.label == label)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice));
}


@override
int get hashCode => Object.hash(runtimeType,id,category,label,unit,unitPrice);

@override
String toString() {
  return 'Supply(id: $id, category: $category, label: $label, unit: $unit, unitPrice: $unitPrice)';
}


}

/// @nodoc
abstract mixin class _$SupplyCopyWith<$Res> implements $SupplyCopyWith<$Res> {
  factory _$SupplyCopyWith(_Supply value, $Res Function(_Supply) _then) = __$SupplyCopyWithImpl;
@override @useResult
$Res call({
 String id, String category, String label, String unit, double unitPrice
});




}
/// @nodoc
class __$SupplyCopyWithImpl<$Res>
    implements _$SupplyCopyWith<$Res> {
  __$SupplyCopyWithImpl(this._self, this._then);

  final _Supply _self;
  final $Res Function(_Supply) _then;

/// Create a copy of Supply
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? category = null,Object? label = null,Object? unit = null,Object? unitPrice = null,}) {
  return _then(_Supply(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on

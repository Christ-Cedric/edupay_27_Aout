// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'kit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$KitItem {

 String get category; String get label; int get quantity; String get unit; double get unitPrice;
/// Create a copy of KitItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KitItemCopyWith<KitItem> get copyWith => _$KitItemCopyWithImpl<KitItem>(this as KitItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KitItem&&(identical(other.category, category) || other.category == category)&&(identical(other.label, label) || other.label == label)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice));
}


@override
int get hashCode => Object.hash(runtimeType,category,label,quantity,unit,unitPrice);

@override
String toString() {
  return 'KitItem(category: $category, label: $label, quantity: $quantity, unit: $unit, unitPrice: $unitPrice)';
}


}

/// @nodoc
abstract mixin class $KitItemCopyWith<$Res>  {
  factory $KitItemCopyWith(KitItem value, $Res Function(KitItem) _then) = _$KitItemCopyWithImpl;
@useResult
$Res call({
 String category, String label, int quantity, String unit, double unitPrice
});




}
/// @nodoc
class _$KitItemCopyWithImpl<$Res>
    implements $KitItemCopyWith<$Res> {
  _$KitItemCopyWithImpl(this._self, this._then);

  final KitItem _self;
  final $Res Function(KitItem) _then;

/// Create a copy of KitItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? category = null,Object? label = null,Object? quantity = null,Object? unit = null,Object? unitPrice = null,}) {
  return _then(_self.copyWith(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [KitItem].
extension KitItemPatterns on KitItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KitItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KitItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KitItem value)  $default,){
final _that = this;
switch (_that) {
case _KitItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KitItem value)?  $default,){
final _that = this;
switch (_that) {
case _KitItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String category,  String label,  int quantity,  String unit,  double unitPrice)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KitItem() when $default != null:
return $default(_that.category,_that.label,_that.quantity,_that.unit,_that.unitPrice);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String category,  String label,  int quantity,  String unit,  double unitPrice)  $default,) {final _that = this;
switch (_that) {
case _KitItem():
return $default(_that.category,_that.label,_that.quantity,_that.unit,_that.unitPrice);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String category,  String label,  int quantity,  String unit,  double unitPrice)?  $default,) {final _that = this;
switch (_that) {
case _KitItem() when $default != null:
return $default(_that.category,_that.label,_that.quantity,_that.unit,_that.unitPrice);case _:
  return null;

}
}

}

/// @nodoc


class _KitItem implements KitItem {
  const _KitItem({required this.category, required this.label, required this.quantity, required this.unit, required this.unitPrice});
  

@override final  String category;
@override final  String label;
@override final  int quantity;
@override final  String unit;
@override final  double unitPrice;

/// Create a copy of KitItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KitItemCopyWith<_KitItem> get copyWith => __$KitItemCopyWithImpl<_KitItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KitItem&&(identical(other.category, category) || other.category == category)&&(identical(other.label, label) || other.label == label)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice));
}


@override
int get hashCode => Object.hash(runtimeType,category,label,quantity,unit,unitPrice);

@override
String toString() {
  return 'KitItem(category: $category, label: $label, quantity: $quantity, unit: $unit, unitPrice: $unitPrice)';
}


}

/// @nodoc
abstract mixin class _$KitItemCopyWith<$Res> implements $KitItemCopyWith<$Res> {
  factory _$KitItemCopyWith(_KitItem value, $Res Function(_KitItem) _then) = __$KitItemCopyWithImpl;
@override @useResult
$Res call({
 String category, String label, int quantity, String unit, double unitPrice
});




}
/// @nodoc
class __$KitItemCopyWithImpl<$Res>
    implements _$KitItemCopyWith<$Res> {
  __$KitItemCopyWithImpl(this._self, this._then);

  final _KitItem _self;
  final $Res Function(_KitItem) _then;

/// Create a copy of KitItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? category = null,Object? label = null,Object? quantity = null,Object? unit = null,Object? unitPrice = null,}) {
  return _then(_KitItem(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
mixin _$Kit {

 String get id; KitLevel get level; SchoolLevel get schoolLevel; double get price; List<KitItem> get items;
/// Create a copy of Kit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KitCopyWith<Kit> get copyWith => _$KitCopyWithImpl<Kit>(this as Kit, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Kit&&(identical(other.id, id) || other.id == id)&&(identical(other.level, level) || other.level == level)&&(identical(other.schoolLevel, schoolLevel) || other.schoolLevel == schoolLevel)&&(identical(other.price, price) || other.price == price)&&const DeepCollectionEquality().equals(other.items, items));
}


@override
int get hashCode => Object.hash(runtimeType,id,level,schoolLevel,price,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'Kit(id: $id, level: $level, schoolLevel: $schoolLevel, price: $price, items: $items)';
}


}

/// @nodoc
abstract mixin class $KitCopyWith<$Res>  {
  factory $KitCopyWith(Kit value, $Res Function(Kit) _then) = _$KitCopyWithImpl;
@useResult
$Res call({
 String id, KitLevel level, SchoolLevel schoolLevel, double price, List<KitItem> items
});




}
/// @nodoc
class _$KitCopyWithImpl<$Res>
    implements $KitCopyWith<$Res> {
  _$KitCopyWithImpl(this._self, this._then);

  final Kit _self;
  final $Res Function(Kit) _then;

/// Create a copy of Kit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? level = null,Object? schoolLevel = null,Object? price = null,Object? items = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as KitLevel,schoolLevel: null == schoolLevel ? _self.schoolLevel : schoolLevel // ignore: cast_nullable_to_non_nullable
as SchoolLevel,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<KitItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [Kit].
extension KitPatterns on Kit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Kit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Kit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Kit value)  $default,){
final _that = this;
switch (_that) {
case _Kit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Kit value)?  $default,){
final _that = this;
switch (_that) {
case _Kit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  KitLevel level,  SchoolLevel schoolLevel,  double price,  List<KitItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Kit() when $default != null:
return $default(_that.id,_that.level,_that.schoolLevel,_that.price,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  KitLevel level,  SchoolLevel schoolLevel,  double price,  List<KitItem> items)  $default,) {final _that = this;
switch (_that) {
case _Kit():
return $default(_that.id,_that.level,_that.schoolLevel,_that.price,_that.items);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  KitLevel level,  SchoolLevel schoolLevel,  double price,  List<KitItem> items)?  $default,) {final _that = this;
switch (_that) {
case _Kit() when $default != null:
return $default(_that.id,_that.level,_that.schoolLevel,_that.price,_that.items);case _:
  return null;

}
}

}

/// @nodoc


class _Kit implements Kit {
  const _Kit({required this.id, required this.level, required this.schoolLevel, required this.price, required final  List<KitItem> items}): _items = items;
  

@override final  String id;
@override final  KitLevel level;
@override final  SchoolLevel schoolLevel;
@override final  double price;
 final  List<KitItem> _items;
@override List<KitItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of Kit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KitCopyWith<_Kit> get copyWith => __$KitCopyWithImpl<_Kit>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Kit&&(identical(other.id, id) || other.id == id)&&(identical(other.level, level) || other.level == level)&&(identical(other.schoolLevel, schoolLevel) || other.schoolLevel == schoolLevel)&&(identical(other.price, price) || other.price == price)&&const DeepCollectionEquality().equals(other._items, _items));
}


@override
int get hashCode => Object.hash(runtimeType,id,level,schoolLevel,price,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'Kit(id: $id, level: $level, schoolLevel: $schoolLevel, price: $price, items: $items)';
}


}

/// @nodoc
abstract mixin class _$KitCopyWith<$Res> implements $KitCopyWith<$Res> {
  factory _$KitCopyWith(_Kit value, $Res Function(_Kit) _then) = __$KitCopyWithImpl;
@override @useResult
$Res call({
 String id, KitLevel level, SchoolLevel schoolLevel, double price, List<KitItem> items
});




}
/// @nodoc
class __$KitCopyWithImpl<$Res>
    implements _$KitCopyWith<$Res> {
  __$KitCopyWithImpl(this._self, this._then);

  final _Kit _self;
  final $Res Function(_Kit) _then;

/// Create a copy of Kit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? level = null,Object? schoolLevel = null,Object? price = null,Object? items = null,}) {
  return _then(_Kit(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as KitLevel,schoolLevel: null == schoolLevel ? _self.schoolLevel : schoolLevel // ignore: cast_nullable_to_non_nullable
as SchoolLevel,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<KitItem>,
  ));
}


}

// dart format on

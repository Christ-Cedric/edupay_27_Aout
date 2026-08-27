// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'family.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FamilyChild {

 String get id; String get firstName; String get level; String get school; String? get kitId; double? get targetAmount; double? get savedAmount;
/// Create a copy of FamilyChild
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FamilyChildCopyWith<FamilyChild> get copyWith => _$FamilyChildCopyWithImpl<FamilyChild>(this as FamilyChild, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FamilyChild&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.level, level) || other.level == level)&&(identical(other.school, school) || other.school == school)&&(identical(other.kitId, kitId) || other.kitId == kitId)&&(identical(other.targetAmount, targetAmount) || other.targetAmount == targetAmount)&&(identical(other.savedAmount, savedAmount) || other.savedAmount == savedAmount));
}


@override
int get hashCode => Object.hash(runtimeType,id,firstName,level,school,kitId,targetAmount,savedAmount);

@override
String toString() {
  return 'FamilyChild(id: $id, firstName: $firstName, level: $level, school: $school, kitId: $kitId, targetAmount: $targetAmount, savedAmount: $savedAmount)';
}


}

/// @nodoc
abstract mixin class $FamilyChildCopyWith<$Res>  {
  factory $FamilyChildCopyWith(FamilyChild value, $Res Function(FamilyChild) _then) = _$FamilyChildCopyWithImpl;
@useResult
$Res call({
 String id, String firstName, String level, String school, String? kitId, double? targetAmount, double? savedAmount
});




}
/// @nodoc
class _$FamilyChildCopyWithImpl<$Res>
    implements $FamilyChildCopyWith<$Res> {
  _$FamilyChildCopyWithImpl(this._self, this._then);

  final FamilyChild _self;
  final $Res Function(FamilyChild) _then;

/// Create a copy of FamilyChild
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? firstName = null,Object? level = null,Object? school = null,Object? kitId = freezed,Object? targetAmount = freezed,Object? savedAmount = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as String,school: null == school ? _self.school : school // ignore: cast_nullable_to_non_nullable
as String,kitId: freezed == kitId ? _self.kitId : kitId // ignore: cast_nullable_to_non_nullable
as String?,targetAmount: freezed == targetAmount ? _self.targetAmount : targetAmount // ignore: cast_nullable_to_non_nullable
as double?,savedAmount: freezed == savedAmount ? _self.savedAmount : savedAmount // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [FamilyChild].
extension FamilyChildPatterns on FamilyChild {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FamilyChild value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FamilyChild() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FamilyChild value)  $default,){
final _that = this;
switch (_that) {
case _FamilyChild():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FamilyChild value)?  $default,){
final _that = this;
switch (_that) {
case _FamilyChild() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String firstName,  String level,  String school,  String? kitId,  double? targetAmount,  double? savedAmount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FamilyChild() when $default != null:
return $default(_that.id,_that.firstName,_that.level,_that.school,_that.kitId,_that.targetAmount,_that.savedAmount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String firstName,  String level,  String school,  String? kitId,  double? targetAmount,  double? savedAmount)  $default,) {final _that = this;
switch (_that) {
case _FamilyChild():
return $default(_that.id,_that.firstName,_that.level,_that.school,_that.kitId,_that.targetAmount,_that.savedAmount);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String firstName,  String level,  String school,  String? kitId,  double? targetAmount,  double? savedAmount)?  $default,) {final _that = this;
switch (_that) {
case _FamilyChild() when $default != null:
return $default(_that.id,_that.firstName,_that.level,_that.school,_that.kitId,_that.targetAmount,_that.savedAmount);case _:
  return null;

}
}

}

/// @nodoc


class _FamilyChild implements FamilyChild {
  const _FamilyChild({required this.id, required this.firstName, required this.level, required this.school, this.kitId, this.targetAmount, this.savedAmount});
  

@override final  String id;
@override final  String firstName;
@override final  String level;
@override final  String school;
@override final  String? kitId;
@override final  double? targetAmount;
@override final  double? savedAmount;

/// Create a copy of FamilyChild
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FamilyChildCopyWith<_FamilyChild> get copyWith => __$FamilyChildCopyWithImpl<_FamilyChild>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FamilyChild&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.level, level) || other.level == level)&&(identical(other.school, school) || other.school == school)&&(identical(other.kitId, kitId) || other.kitId == kitId)&&(identical(other.targetAmount, targetAmount) || other.targetAmount == targetAmount)&&(identical(other.savedAmount, savedAmount) || other.savedAmount == savedAmount));
}


@override
int get hashCode => Object.hash(runtimeType,id,firstName,level,school,kitId,targetAmount,savedAmount);

@override
String toString() {
  return 'FamilyChild(id: $id, firstName: $firstName, level: $level, school: $school, kitId: $kitId, targetAmount: $targetAmount, savedAmount: $savedAmount)';
}


}

/// @nodoc
abstract mixin class _$FamilyChildCopyWith<$Res> implements $FamilyChildCopyWith<$Res> {
  factory _$FamilyChildCopyWith(_FamilyChild value, $Res Function(_FamilyChild) _then) = __$FamilyChildCopyWithImpl;
@override @useResult
$Res call({
 String id, String firstName, String level, String school, String? kitId, double? targetAmount, double? savedAmount
});




}
/// @nodoc
class __$FamilyChildCopyWithImpl<$Res>
    implements _$FamilyChildCopyWith<$Res> {
  __$FamilyChildCopyWithImpl(this._self, this._then);

  final _FamilyChild _self;
  final $Res Function(_FamilyChild) _then;

/// Create a copy of FamilyChild
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? firstName = null,Object? level = null,Object? school = null,Object? kitId = freezed,Object? targetAmount = freezed,Object? savedAmount = freezed,}) {
  return _then(_FamilyChild(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as String,school: null == school ? _self.school : school // ignore: cast_nullable_to_non_nullable
as String,kitId: freezed == kitId ? _self.kitId : kitId // ignore: cast_nullable_to_non_nullable
as String?,targetAmount: freezed == targetAmount ? _self.targetAmount : targetAmount // ignore: cast_nullable_to_non_nullable
as double?,savedAmount: freezed == savedAmount ? _self.savedAmount : savedAmount // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

/// @nodoc
mixin _$Family {

 String get id; String get fullName; String get phone; String get city; SavingsPlan get plan; double get balance; double get targetAmount; List<FamilyChild> get children; FamilyStatus get status; DeliveryStatus get deliveryStatus; DateTime get registeredAt; String? get assignedAgentName; String? get rejectionReason; String? get district;
/// Create a copy of Family
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FamilyCopyWith<Family> get copyWith => _$FamilyCopyWithImpl<Family>(this as Family, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Family&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.city, city) || other.city == city)&&(identical(other.plan, plan) || other.plan == plan)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.targetAmount, targetAmount) || other.targetAmount == targetAmount)&&const DeepCollectionEquality().equals(other.children, children)&&(identical(other.status, status) || other.status == status)&&(identical(other.deliveryStatus, deliveryStatus) || other.deliveryStatus == deliveryStatus)&&(identical(other.registeredAt, registeredAt) || other.registeredAt == registeredAt)&&(identical(other.assignedAgentName, assignedAgentName) || other.assignedAgentName == assignedAgentName)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.district, district) || other.district == district));
}


@override
int get hashCode => Object.hash(runtimeType,id,fullName,phone,city,plan,balance,targetAmount,const DeepCollectionEquality().hash(children),status,deliveryStatus,registeredAt,assignedAgentName,rejectionReason,district);

@override
String toString() {
  return 'Family(id: $id, fullName: $fullName, phone: $phone, city: $city, plan: $plan, balance: $balance, targetAmount: $targetAmount, children: $children, status: $status, deliveryStatus: $deliveryStatus, registeredAt: $registeredAt, assignedAgentName: $assignedAgentName, rejectionReason: $rejectionReason, district: $district)';
}


}

/// @nodoc
abstract mixin class $FamilyCopyWith<$Res>  {
  factory $FamilyCopyWith(Family value, $Res Function(Family) _then) = _$FamilyCopyWithImpl;
@useResult
$Res call({
 String id, String fullName, String phone, String city, SavingsPlan plan, double balance, double targetAmount, List<FamilyChild> children, FamilyStatus status, DeliveryStatus deliveryStatus, DateTime registeredAt, String? assignedAgentName, String? rejectionReason, String? district
});




}
/// @nodoc
class _$FamilyCopyWithImpl<$Res>
    implements $FamilyCopyWith<$Res> {
  _$FamilyCopyWithImpl(this._self, this._then);

  final Family _self;
  final $Res Function(Family) _then;

/// Create a copy of Family
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullName = null,Object? phone = null,Object? city = null,Object? plan = null,Object? balance = null,Object? targetAmount = null,Object? children = null,Object? status = null,Object? deliveryStatus = null,Object? registeredAt = null,Object? assignedAgentName = freezed,Object? rejectionReason = freezed,Object? district = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as SavingsPlan,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,targetAmount: null == targetAmount ? _self.targetAmount : targetAmount // ignore: cast_nullable_to_non_nullable
as double,children: null == children ? _self.children : children // ignore: cast_nullable_to_non_nullable
as List<FamilyChild>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FamilyStatus,deliveryStatus: null == deliveryStatus ? _self.deliveryStatus : deliveryStatus // ignore: cast_nullable_to_non_nullable
as DeliveryStatus,registeredAt: null == registeredAt ? _self.registeredAt : registeredAt // ignore: cast_nullable_to_non_nullable
as DateTime,assignedAgentName: freezed == assignedAgentName ? _self.assignedAgentName : assignedAgentName // ignore: cast_nullable_to_non_nullable
as String?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,district: freezed == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Family].
extension FamilyPatterns on Family {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Family value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Family() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Family value)  $default,){
final _that = this;
switch (_that) {
case _Family():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Family value)?  $default,){
final _that = this;
switch (_that) {
case _Family() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fullName,  String phone,  String city,  SavingsPlan plan,  double balance,  double targetAmount,  List<FamilyChild> children,  FamilyStatus status,  DeliveryStatus deliveryStatus,  DateTime registeredAt,  String? assignedAgentName,  String? rejectionReason,  String? district)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Family() when $default != null:
return $default(_that.id,_that.fullName,_that.phone,_that.city,_that.plan,_that.balance,_that.targetAmount,_that.children,_that.status,_that.deliveryStatus,_that.registeredAt,_that.assignedAgentName,_that.rejectionReason,_that.district);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fullName,  String phone,  String city,  SavingsPlan plan,  double balance,  double targetAmount,  List<FamilyChild> children,  FamilyStatus status,  DeliveryStatus deliveryStatus,  DateTime registeredAt,  String? assignedAgentName,  String? rejectionReason,  String? district)  $default,) {final _that = this;
switch (_that) {
case _Family():
return $default(_that.id,_that.fullName,_that.phone,_that.city,_that.plan,_that.balance,_that.targetAmount,_that.children,_that.status,_that.deliveryStatus,_that.registeredAt,_that.assignedAgentName,_that.rejectionReason,_that.district);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fullName,  String phone,  String city,  SavingsPlan plan,  double balance,  double targetAmount,  List<FamilyChild> children,  FamilyStatus status,  DeliveryStatus deliveryStatus,  DateTime registeredAt,  String? assignedAgentName,  String? rejectionReason,  String? district)?  $default,) {final _that = this;
switch (_that) {
case _Family() when $default != null:
return $default(_that.id,_that.fullName,_that.phone,_that.city,_that.plan,_that.balance,_that.targetAmount,_that.children,_that.status,_that.deliveryStatus,_that.registeredAt,_that.assignedAgentName,_that.rejectionReason,_that.district);case _:
  return null;

}
}

}

/// @nodoc


class _Family implements Family {
  const _Family({required this.id, required this.fullName, required this.phone, required this.city, required this.plan, required this.balance, required this.targetAmount, required final  List<FamilyChild> children, required this.status, required this.deliveryStatus, required this.registeredAt, this.assignedAgentName, this.rejectionReason, this.district}): _children = children;
  

@override final  String id;
@override final  String fullName;
@override final  String phone;
@override final  String city;
@override final  SavingsPlan plan;
@override final  double balance;
@override final  double targetAmount;
 final  List<FamilyChild> _children;
@override List<FamilyChild> get children {
  if (_children is EqualUnmodifiableListView) return _children;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_children);
}

@override final  FamilyStatus status;
@override final  DeliveryStatus deliveryStatus;
@override final  DateTime registeredAt;
@override final  String? assignedAgentName;
@override final  String? rejectionReason;
@override final  String? district;

/// Create a copy of Family
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FamilyCopyWith<_Family> get copyWith => __$FamilyCopyWithImpl<_Family>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Family&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.city, city) || other.city == city)&&(identical(other.plan, plan) || other.plan == plan)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.targetAmount, targetAmount) || other.targetAmount == targetAmount)&&const DeepCollectionEquality().equals(other._children, _children)&&(identical(other.status, status) || other.status == status)&&(identical(other.deliveryStatus, deliveryStatus) || other.deliveryStatus == deliveryStatus)&&(identical(other.registeredAt, registeredAt) || other.registeredAt == registeredAt)&&(identical(other.assignedAgentName, assignedAgentName) || other.assignedAgentName == assignedAgentName)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.district, district) || other.district == district));
}


@override
int get hashCode => Object.hash(runtimeType,id,fullName,phone,city,plan,balance,targetAmount,const DeepCollectionEquality().hash(_children),status,deliveryStatus,registeredAt,assignedAgentName,rejectionReason,district);

@override
String toString() {
  return 'Family(id: $id, fullName: $fullName, phone: $phone, city: $city, plan: $plan, balance: $balance, targetAmount: $targetAmount, children: $children, status: $status, deliveryStatus: $deliveryStatus, registeredAt: $registeredAt, assignedAgentName: $assignedAgentName, rejectionReason: $rejectionReason, district: $district)';
}


}

/// @nodoc
abstract mixin class _$FamilyCopyWith<$Res> implements $FamilyCopyWith<$Res> {
  factory _$FamilyCopyWith(_Family value, $Res Function(_Family) _then) = __$FamilyCopyWithImpl;
@override @useResult
$Res call({
 String id, String fullName, String phone, String city, SavingsPlan plan, double balance, double targetAmount, List<FamilyChild> children, FamilyStatus status, DeliveryStatus deliveryStatus, DateTime registeredAt, String? assignedAgentName, String? rejectionReason, String? district
});




}
/// @nodoc
class __$FamilyCopyWithImpl<$Res>
    implements _$FamilyCopyWith<$Res> {
  __$FamilyCopyWithImpl(this._self, this._then);

  final _Family _self;
  final $Res Function(_Family) _then;

/// Create a copy of Family
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = null,Object? phone = null,Object? city = null,Object? plan = null,Object? balance = null,Object? targetAmount = null,Object? children = null,Object? status = null,Object? deliveryStatus = null,Object? registeredAt = null,Object? assignedAgentName = freezed,Object? rejectionReason = freezed,Object? district = freezed,}) {
  return _then(_Family(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as SavingsPlan,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,targetAmount: null == targetAmount ? _self.targetAmount : targetAmount // ignore: cast_nullable_to_non_nullable
as double,children: null == children ? _self._children : children // ignore: cast_nullable_to_non_nullable
as List<FamilyChild>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FamilyStatus,deliveryStatus: null == deliveryStatus ? _self.deliveryStatus : deliveryStatus // ignore: cast_nullable_to_non_nullable
as DeliveryStatus,registeredAt: null == registeredAt ? _self.registeredAt : registeredAt // ignore: cast_nullable_to_non_nullable
as DateTime,assignedAgentName: freezed == assignedAgentName ? _self.assignedAgentName : assignedAgentName // ignore: cast_nullable_to_non_nullable
as String?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,district: freezed == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

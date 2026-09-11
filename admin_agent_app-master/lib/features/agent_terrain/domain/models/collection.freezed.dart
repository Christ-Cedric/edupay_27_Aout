// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'collection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CollectionAllocation {

 String get goalType; double get amount; String? get childName; String? get goalName;
/// Create a copy of CollectionAllocation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CollectionAllocationCopyWith<CollectionAllocation> get copyWith => _$CollectionAllocationCopyWithImpl<CollectionAllocation>(this as CollectionAllocation, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CollectionAllocation&&(identical(other.goalType, goalType) || other.goalType == goalType)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.childName, childName) || other.childName == childName)&&(identical(other.goalName, goalName) || other.goalName == goalName));
}


@override
int get hashCode => Object.hash(runtimeType,goalType,amount,childName,goalName);

@override
String toString() {
  return 'CollectionAllocation(goalType: $goalType, amount: $amount, childName: $childName, goalName: $goalName)';
}


}

/// @nodoc
abstract mixin class $CollectionAllocationCopyWith<$Res>  {
  factory $CollectionAllocationCopyWith(CollectionAllocation value, $Res Function(CollectionAllocation) _then) = _$CollectionAllocationCopyWithImpl;
@useResult
$Res call({
 String goalType, double amount, String? childName, String? goalName
});




}
/// @nodoc
class _$CollectionAllocationCopyWithImpl<$Res>
    implements $CollectionAllocationCopyWith<$Res> {
  _$CollectionAllocationCopyWithImpl(this._self, this._then);

  final CollectionAllocation _self;
  final $Res Function(CollectionAllocation) _then;

/// Create a copy of CollectionAllocation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? goalType = null,Object? amount = null,Object? childName = freezed,Object? goalName = freezed,}) {
  return _then(_self.copyWith(
goalType: null == goalType ? _self.goalType : goalType // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,childName: freezed == childName ? _self.childName : childName // ignore: cast_nullable_to_non_nullable
as String?,goalName: freezed == goalName ? _self.goalName : goalName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CollectionAllocation].
extension CollectionAllocationPatterns on CollectionAllocation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CollectionAllocation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CollectionAllocation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CollectionAllocation value)  $default,){
final _that = this;
switch (_that) {
case _CollectionAllocation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CollectionAllocation value)?  $default,){
final _that = this;
switch (_that) {
case _CollectionAllocation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String goalType,  double amount,  String? childName,  String? goalName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CollectionAllocation() when $default != null:
return $default(_that.goalType,_that.amount,_that.childName,_that.goalName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String goalType,  double amount,  String? childName,  String? goalName)  $default,) {final _that = this;
switch (_that) {
case _CollectionAllocation():
return $default(_that.goalType,_that.amount,_that.childName,_that.goalName);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String goalType,  double amount,  String? childName,  String? goalName)?  $default,) {final _that = this;
switch (_that) {
case _CollectionAllocation() when $default != null:
return $default(_that.goalType,_that.amount,_that.childName,_that.goalName);case _:
  return null;

}
}

}

/// @nodoc


class _CollectionAllocation implements CollectionAllocation {
  const _CollectionAllocation({required this.goalType, required this.amount, this.childName, this.goalName});
  

@override final  String goalType;
@override final  double amount;
@override final  String? childName;
@override final  String? goalName;

/// Create a copy of CollectionAllocation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CollectionAllocationCopyWith<_CollectionAllocation> get copyWith => __$CollectionAllocationCopyWithImpl<_CollectionAllocation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CollectionAllocation&&(identical(other.goalType, goalType) || other.goalType == goalType)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.childName, childName) || other.childName == childName)&&(identical(other.goalName, goalName) || other.goalName == goalName));
}


@override
int get hashCode => Object.hash(runtimeType,goalType,amount,childName,goalName);

@override
String toString() {
  return 'CollectionAllocation(goalType: $goalType, amount: $amount, childName: $childName, goalName: $goalName)';
}


}

/// @nodoc
abstract mixin class _$CollectionAllocationCopyWith<$Res> implements $CollectionAllocationCopyWith<$Res> {
  factory _$CollectionAllocationCopyWith(_CollectionAllocation value, $Res Function(_CollectionAllocation) _then) = __$CollectionAllocationCopyWithImpl;
@override @useResult
$Res call({
 String goalType, double amount, String? childName, String? goalName
});




}
/// @nodoc
class __$CollectionAllocationCopyWithImpl<$Res>
    implements _$CollectionAllocationCopyWith<$Res> {
  __$CollectionAllocationCopyWithImpl(this._self, this._then);

  final _CollectionAllocation _self;
  final $Res Function(_CollectionAllocation) _then;

/// Create a copy of CollectionAllocation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? goalType = null,Object? amount = null,Object? childName = freezed,Object? goalName = freezed,}) {
  return _then(_CollectionAllocation(
goalType: null == goalType ? _self.goalType : goalType // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,childName: freezed == childName ? _self.childName : childName // ignore: cast_nullable_to_non_nullable
as String?,goalName: freezed == goalName ? _self.goalName : goalName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$Collection {

 String get id; String get familyId; String get familyName; String get agentName; double get amount; CollectionMode get mode; DateTime get collectedAt; String get receiptNumber;/// Catégorie d'épargne ciblée par cet encaissement. Null = non spécifiée
/// (cotisation globale répartie sur tous les objectifs actifs).
 String? get targetGoalType; List<CollectionAllocation> get allocations;
/// Create a copy of Collection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CollectionCopyWith<Collection> get copyWith => _$CollectionCopyWithImpl<Collection>(this as Collection, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Collection&&(identical(other.id, id) || other.id == id)&&(identical(other.familyId, familyId) || other.familyId == familyId)&&(identical(other.familyName, familyName) || other.familyName == familyName)&&(identical(other.agentName, agentName) || other.agentName == agentName)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.collectedAt, collectedAt) || other.collectedAt == collectedAt)&&(identical(other.receiptNumber, receiptNumber) || other.receiptNumber == receiptNumber)&&(identical(other.targetGoalType, targetGoalType) || other.targetGoalType == targetGoalType)&&const DeepCollectionEquality().equals(other.allocations, allocations));
}


@override
int get hashCode => Object.hash(runtimeType,id,familyId,familyName,agentName,amount,mode,collectedAt,receiptNumber,targetGoalType,const DeepCollectionEquality().hash(allocations));

@override
String toString() {
  return 'Collection(id: $id, familyId: $familyId, familyName: $familyName, agentName: $agentName, amount: $amount, mode: $mode, collectedAt: $collectedAt, receiptNumber: $receiptNumber, targetGoalType: $targetGoalType, allocations: $allocations)';
}


}

/// @nodoc
abstract mixin class $CollectionCopyWith<$Res>  {
  factory $CollectionCopyWith(Collection value, $Res Function(Collection) _then) = _$CollectionCopyWithImpl;
@useResult
$Res call({
 String id, String familyId, String familyName, String agentName, double amount, CollectionMode mode, DateTime collectedAt, String receiptNumber, String? targetGoalType, List<CollectionAllocation> allocations
});




}
/// @nodoc
class _$CollectionCopyWithImpl<$Res>
    implements $CollectionCopyWith<$Res> {
  _$CollectionCopyWithImpl(this._self, this._then);

  final Collection _self;
  final $Res Function(Collection) _then;

/// Create a copy of Collection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? familyId = null,Object? familyName = null,Object? agentName = null,Object? amount = null,Object? mode = null,Object? collectedAt = null,Object? receiptNumber = null,Object? targetGoalType = freezed,Object? allocations = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,familyId: null == familyId ? _self.familyId : familyId // ignore: cast_nullable_to_non_nullable
as String,familyName: null == familyName ? _self.familyName : familyName // ignore: cast_nullable_to_non_nullable
as String,agentName: null == agentName ? _self.agentName : agentName // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as CollectionMode,collectedAt: null == collectedAt ? _self.collectedAt : collectedAt // ignore: cast_nullable_to_non_nullable
as DateTime,receiptNumber: null == receiptNumber ? _self.receiptNumber : receiptNumber // ignore: cast_nullable_to_non_nullable
as String,targetGoalType: freezed == targetGoalType ? _self.targetGoalType : targetGoalType // ignore: cast_nullable_to_non_nullable
as String?,allocations: null == allocations ? _self.allocations : allocations // ignore: cast_nullable_to_non_nullable
as List<CollectionAllocation>,
  ));
}

}


/// Adds pattern-matching-related methods to [Collection].
extension CollectionPatterns on Collection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Collection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Collection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Collection value)  $default,){
final _that = this;
switch (_that) {
case _Collection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Collection value)?  $default,){
final _that = this;
switch (_that) {
case _Collection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String familyId,  String familyName,  String agentName,  double amount,  CollectionMode mode,  DateTime collectedAt,  String receiptNumber,  String? targetGoalType,  List<CollectionAllocation> allocations)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Collection() when $default != null:
return $default(_that.id,_that.familyId,_that.familyName,_that.agentName,_that.amount,_that.mode,_that.collectedAt,_that.receiptNumber,_that.targetGoalType,_that.allocations);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String familyId,  String familyName,  String agentName,  double amount,  CollectionMode mode,  DateTime collectedAt,  String receiptNumber,  String? targetGoalType,  List<CollectionAllocation> allocations)  $default,) {final _that = this;
switch (_that) {
case _Collection():
return $default(_that.id,_that.familyId,_that.familyName,_that.agentName,_that.amount,_that.mode,_that.collectedAt,_that.receiptNumber,_that.targetGoalType,_that.allocations);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String familyId,  String familyName,  String agentName,  double amount,  CollectionMode mode,  DateTime collectedAt,  String receiptNumber,  String? targetGoalType,  List<CollectionAllocation> allocations)?  $default,) {final _that = this;
switch (_that) {
case _Collection() when $default != null:
return $default(_that.id,_that.familyId,_that.familyName,_that.agentName,_that.amount,_that.mode,_that.collectedAt,_that.receiptNumber,_that.targetGoalType,_that.allocations);case _:
  return null;

}
}

}

/// @nodoc


class _Collection implements Collection {
  const _Collection({required this.id, required this.familyId, required this.familyName, required this.agentName, required this.amount, required this.mode, required this.collectedAt, required this.receiptNumber, this.targetGoalType, final  List<CollectionAllocation> allocations = const []}): _allocations = allocations;
  

@override final  String id;
@override final  String familyId;
@override final  String familyName;
@override final  String agentName;
@override final  double amount;
@override final  CollectionMode mode;
@override final  DateTime collectedAt;
@override final  String receiptNumber;
/// Catégorie d'épargne ciblée par cet encaissement. Null = non spécifiée
/// (cotisation globale répartie sur tous les objectifs actifs).
@override final  String? targetGoalType;
 final  List<CollectionAllocation> _allocations;
@override@JsonKey() List<CollectionAllocation> get allocations {
  if (_allocations is EqualUnmodifiableListView) return _allocations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allocations);
}


/// Create a copy of Collection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CollectionCopyWith<_Collection> get copyWith => __$CollectionCopyWithImpl<_Collection>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Collection&&(identical(other.id, id) || other.id == id)&&(identical(other.familyId, familyId) || other.familyId == familyId)&&(identical(other.familyName, familyName) || other.familyName == familyName)&&(identical(other.agentName, agentName) || other.agentName == agentName)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.collectedAt, collectedAt) || other.collectedAt == collectedAt)&&(identical(other.receiptNumber, receiptNumber) || other.receiptNumber == receiptNumber)&&(identical(other.targetGoalType, targetGoalType) || other.targetGoalType == targetGoalType)&&const DeepCollectionEquality().equals(other._allocations, _allocations));
}


@override
int get hashCode => Object.hash(runtimeType,id,familyId,familyName,agentName,amount,mode,collectedAt,receiptNumber,targetGoalType,const DeepCollectionEquality().hash(_allocations));

@override
String toString() {
  return 'Collection(id: $id, familyId: $familyId, familyName: $familyName, agentName: $agentName, amount: $amount, mode: $mode, collectedAt: $collectedAt, receiptNumber: $receiptNumber, targetGoalType: $targetGoalType, allocations: $allocations)';
}


}

/// @nodoc
abstract mixin class _$CollectionCopyWith<$Res> implements $CollectionCopyWith<$Res> {
  factory _$CollectionCopyWith(_Collection value, $Res Function(_Collection) _then) = __$CollectionCopyWithImpl;
@override @useResult
$Res call({
 String id, String familyId, String familyName, String agentName, double amount, CollectionMode mode, DateTime collectedAt, String receiptNumber, String? targetGoalType, List<CollectionAllocation> allocations
});




}
/// @nodoc
class __$CollectionCopyWithImpl<$Res>
    implements _$CollectionCopyWith<$Res> {
  __$CollectionCopyWithImpl(this._self, this._then);

  final _Collection _self;
  final $Res Function(_Collection) _then;

/// Create a copy of Collection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? familyId = null,Object? familyName = null,Object? agentName = null,Object? amount = null,Object? mode = null,Object? collectedAt = null,Object? receiptNumber = null,Object? targetGoalType = freezed,Object? allocations = null,}) {
  return _then(_Collection(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,familyId: null == familyId ? _self.familyId : familyId // ignore: cast_nullable_to_non_nullable
as String,familyName: null == familyName ? _self.familyName : familyName // ignore: cast_nullable_to_non_nullable
as String,agentName: null == agentName ? _self.agentName : agentName // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as CollectionMode,collectedAt: null == collectedAt ? _self.collectedAt : collectedAt // ignore: cast_nullable_to_non_nullable
as DateTime,receiptNumber: null == receiptNumber ? _self.receiptNumber : receiptNumber // ignore: cast_nullable_to_non_nullable
as String,targetGoalType: freezed == targetGoalType ? _self.targetGoalType : targetGoalType // ignore: cast_nullable_to_non_nullable
as String?,allocations: null == allocations ? _self._allocations : allocations // ignore: cast_nullable_to_non_nullable
as List<CollectionAllocation>,
  ));
}


}

// dart format on

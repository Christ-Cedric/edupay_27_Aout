// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'agent.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Agent {

 String get id; String get fullName; String get phone; String get zone; String? get district; int get clientCount; double get commission; AgentContractType get contractType; AgentStatus get status;
/// Create a copy of Agent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AgentCopyWith<Agent> get copyWith => _$AgentCopyWithImpl<Agent>(this as Agent, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Agent&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.zone, zone) || other.zone == zone)&&(identical(other.district, district) || other.district == district)&&(identical(other.clientCount, clientCount) || other.clientCount == clientCount)&&(identical(other.commission, commission) || other.commission == commission)&&(identical(other.contractType, contractType) || other.contractType == contractType)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,id,fullName,phone,zone,district,clientCount,commission,contractType,status);

@override
String toString() {
  return 'Agent(id: $id, fullName: $fullName, phone: $phone, zone: $zone, district: $district, clientCount: $clientCount, commission: $commission, contractType: $contractType, status: $status)';
}


}

/// @nodoc
abstract mixin class $AgentCopyWith<$Res>  {
  factory $AgentCopyWith(Agent value, $Res Function(Agent) _then) = _$AgentCopyWithImpl;
@useResult
$Res call({
 String id, String fullName, String phone, String zone, String? district, int clientCount, double commission, AgentContractType contractType, AgentStatus status
});




}
/// @nodoc
class _$AgentCopyWithImpl<$Res>
    implements $AgentCopyWith<$Res> {
  _$AgentCopyWithImpl(this._self, this._then);

  final Agent _self;
  final $Res Function(Agent) _then;

/// Create a copy of Agent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullName = null,Object? phone = null,Object? zone = null,Object? district = freezed,Object? clientCount = null,Object? commission = null,Object? contractType = null,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,zone: null == zone ? _self.zone : zone // ignore: cast_nullable_to_non_nullable
as String,district: freezed == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String?,clientCount: null == clientCount ? _self.clientCount : clientCount // ignore: cast_nullable_to_non_nullable
as int,commission: null == commission ? _self.commission : commission // ignore: cast_nullable_to_non_nullable
as double,contractType: null == contractType ? _self.contractType : contractType // ignore: cast_nullable_to_non_nullable
as AgentContractType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AgentStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [Agent].
extension AgentPatterns on Agent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Agent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Agent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Agent value)  $default,){
final _that = this;
switch (_that) {
case _Agent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Agent value)?  $default,){
final _that = this;
switch (_that) {
case _Agent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fullName,  String phone,  String zone,  String? district,  int clientCount,  double commission,  AgentContractType contractType,  AgentStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Agent() when $default != null:
return $default(_that.id,_that.fullName,_that.phone,_that.zone,_that.district,_that.clientCount,_that.commission,_that.contractType,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fullName,  String phone,  String zone,  String? district,  int clientCount,  double commission,  AgentContractType contractType,  AgentStatus status)  $default,) {final _that = this;
switch (_that) {
case _Agent():
return $default(_that.id,_that.fullName,_that.phone,_that.zone,_that.district,_that.clientCount,_that.commission,_that.contractType,_that.status);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fullName,  String phone,  String zone,  String? district,  int clientCount,  double commission,  AgentContractType contractType,  AgentStatus status)?  $default,) {final _that = this;
switch (_that) {
case _Agent() when $default != null:
return $default(_that.id,_that.fullName,_that.phone,_that.zone,_that.district,_that.clientCount,_that.commission,_that.contractType,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _Agent implements Agent {
  const _Agent({required this.id, required this.fullName, required this.phone, required this.zone, this.district, required this.clientCount, required this.commission, required this.contractType, required this.status});
  

@override final  String id;
@override final  String fullName;
@override final  String phone;
@override final  String zone;
@override final  String? district;
@override final  int clientCount;
@override final  double commission;
@override final  AgentContractType contractType;
@override final  AgentStatus status;

/// Create a copy of Agent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AgentCopyWith<_Agent> get copyWith => __$AgentCopyWithImpl<_Agent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Agent&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.zone, zone) || other.zone == zone)&&(identical(other.district, district) || other.district == district)&&(identical(other.clientCount, clientCount) || other.clientCount == clientCount)&&(identical(other.commission, commission) || other.commission == commission)&&(identical(other.contractType, contractType) || other.contractType == contractType)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,id,fullName,phone,zone,district,clientCount,commission,contractType,status);

@override
String toString() {
  return 'Agent(id: $id, fullName: $fullName, phone: $phone, zone: $zone, district: $district, clientCount: $clientCount, commission: $commission, contractType: $contractType, status: $status)';
}


}

/// @nodoc
abstract mixin class _$AgentCopyWith<$Res> implements $AgentCopyWith<$Res> {
  factory _$AgentCopyWith(_Agent value, $Res Function(_Agent) _then) = __$AgentCopyWithImpl;
@override @useResult
$Res call({
 String id, String fullName, String phone, String zone, String? district, int clientCount, double commission, AgentContractType contractType, AgentStatus status
});




}
/// @nodoc
class __$AgentCopyWithImpl<$Res>
    implements _$AgentCopyWith<$Res> {
  __$AgentCopyWithImpl(this._self, this._then);

  final _Agent _self;
  final $Res Function(_Agent) _then;

/// Create a copy of Agent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = null,Object? phone = null,Object? zone = null,Object? district = freezed,Object? clientCount = null,Object? commission = null,Object? contractType = null,Object? status = null,}) {
  return _then(_Agent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,zone: null == zone ? _self.zone : zone // ignore: cast_nullable_to_non_nullable
as String,district: freezed == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String?,clientCount: null == clientCount ? _self.clientCount : clientCount // ignore: cast_nullable_to_non_nullable
as int,commission: null == commission ? _self.commission : commission // ignore: cast_nullable_to_non_nullable
as double,contractType: null == contractType ? _self.contractType : contractType // ignore: cast_nullable_to_non_nullable
as AgentContractType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AgentStatus,
  ));
}


}

// dart format on

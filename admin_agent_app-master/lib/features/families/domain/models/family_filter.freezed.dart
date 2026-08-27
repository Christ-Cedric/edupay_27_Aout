// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'family_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FamilyFilter {

 String get query; FamilyStatus? get status; String? get city; String? get assignedAgentName;
/// Create a copy of FamilyFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FamilyFilterCopyWith<FamilyFilter> get copyWith => _$FamilyFilterCopyWithImpl<FamilyFilter>(this as FamilyFilter, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FamilyFilter&&(identical(other.query, query) || other.query == query)&&(identical(other.status, status) || other.status == status)&&(identical(other.city, city) || other.city == city)&&(identical(other.assignedAgentName, assignedAgentName) || other.assignedAgentName == assignedAgentName));
}


@override
int get hashCode => Object.hash(runtimeType,query,status,city,assignedAgentName);

@override
String toString() {
  return 'FamilyFilter(query: $query, status: $status, city: $city, assignedAgentName: $assignedAgentName)';
}


}

/// @nodoc
abstract mixin class $FamilyFilterCopyWith<$Res>  {
  factory $FamilyFilterCopyWith(FamilyFilter value, $Res Function(FamilyFilter) _then) = _$FamilyFilterCopyWithImpl;
@useResult
$Res call({
 String query, FamilyStatus? status, String? city, String? assignedAgentName
});




}
/// @nodoc
class _$FamilyFilterCopyWithImpl<$Res>
    implements $FamilyFilterCopyWith<$Res> {
  _$FamilyFilterCopyWithImpl(this._self, this._then);

  final FamilyFilter _self;
  final $Res Function(FamilyFilter) _then;

/// Create a copy of FamilyFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? query = null,Object? status = freezed,Object? city = freezed,Object? assignedAgentName = freezed,}) {
  return _then(_self.copyWith(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FamilyStatus?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,assignedAgentName: freezed == assignedAgentName ? _self.assignedAgentName : assignedAgentName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FamilyFilter].
extension FamilyFilterPatterns on FamilyFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FamilyFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FamilyFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FamilyFilter value)  $default,){
final _that = this;
switch (_that) {
case _FamilyFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FamilyFilter value)?  $default,){
final _that = this;
switch (_that) {
case _FamilyFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String query,  FamilyStatus? status,  String? city,  String? assignedAgentName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FamilyFilter() when $default != null:
return $default(_that.query,_that.status,_that.city,_that.assignedAgentName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String query,  FamilyStatus? status,  String? city,  String? assignedAgentName)  $default,) {final _that = this;
switch (_that) {
case _FamilyFilter():
return $default(_that.query,_that.status,_that.city,_that.assignedAgentName);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String query,  FamilyStatus? status,  String? city,  String? assignedAgentName)?  $default,) {final _that = this;
switch (_that) {
case _FamilyFilter() when $default != null:
return $default(_that.query,_that.status,_that.city,_that.assignedAgentName);case _:
  return null;

}
}

}

/// @nodoc


class _FamilyFilter implements FamilyFilter {
  const _FamilyFilter({this.query = '', this.status, this.city, this.assignedAgentName});
  

@override@JsonKey() final  String query;
@override final  FamilyStatus? status;
@override final  String? city;
@override final  String? assignedAgentName;

/// Create a copy of FamilyFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FamilyFilterCopyWith<_FamilyFilter> get copyWith => __$FamilyFilterCopyWithImpl<_FamilyFilter>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FamilyFilter&&(identical(other.query, query) || other.query == query)&&(identical(other.status, status) || other.status == status)&&(identical(other.city, city) || other.city == city)&&(identical(other.assignedAgentName, assignedAgentName) || other.assignedAgentName == assignedAgentName));
}


@override
int get hashCode => Object.hash(runtimeType,query,status,city,assignedAgentName);

@override
String toString() {
  return 'FamilyFilter(query: $query, status: $status, city: $city, assignedAgentName: $assignedAgentName)';
}


}

/// @nodoc
abstract mixin class _$FamilyFilterCopyWith<$Res> implements $FamilyFilterCopyWith<$Res> {
  factory _$FamilyFilterCopyWith(_FamilyFilter value, $Res Function(_FamilyFilter) _then) = __$FamilyFilterCopyWithImpl;
@override @useResult
$Res call({
 String query, FamilyStatus? status, String? city, String? assignedAgentName
});




}
/// @nodoc
class __$FamilyFilterCopyWithImpl<$Res>
    implements _$FamilyFilterCopyWith<$Res> {
  __$FamilyFilterCopyWithImpl(this._self, this._then);

  final _FamilyFilter _self;
  final $Res Function(_FamilyFilter) _then;

/// Create a copy of FamilyFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? query = null,Object? status = freezed,Object? city = freezed,Object? assignedAgentName = freezed,}) {
  return _then(_FamilyFilter(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FamilyStatus?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,assignedAgentName: freezed == assignedAgentName ? _self.assignedAgentName : assignedAgentName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

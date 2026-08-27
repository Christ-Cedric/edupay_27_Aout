// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DashboardSummary {

 String get season; int get activeFamilies; double get totalCollected;/// Entre 0 et 1, ex. 0.89 pour "89%".
 double get collectionRate; int get overduePayments; int get activeAgents; int get pendingDeliveries; List<DashboardAlert> get alerts;
/// Create a copy of DashboardSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardSummaryCopyWith<DashboardSummary> get copyWith => _$DashboardSummaryCopyWithImpl<DashboardSummary>(this as DashboardSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardSummary&&(identical(other.season, season) || other.season == season)&&(identical(other.activeFamilies, activeFamilies) || other.activeFamilies == activeFamilies)&&(identical(other.totalCollected, totalCollected) || other.totalCollected == totalCollected)&&(identical(other.collectionRate, collectionRate) || other.collectionRate == collectionRate)&&(identical(other.overduePayments, overduePayments) || other.overduePayments == overduePayments)&&(identical(other.activeAgents, activeAgents) || other.activeAgents == activeAgents)&&(identical(other.pendingDeliveries, pendingDeliveries) || other.pendingDeliveries == pendingDeliveries)&&const DeepCollectionEquality().equals(other.alerts, alerts));
}


@override
int get hashCode => Object.hash(runtimeType,season,activeFamilies,totalCollected,collectionRate,overduePayments,activeAgents,pendingDeliveries,const DeepCollectionEquality().hash(alerts));

@override
String toString() {
  return 'DashboardSummary(season: $season, activeFamilies: $activeFamilies, totalCollected: $totalCollected, collectionRate: $collectionRate, overduePayments: $overduePayments, activeAgents: $activeAgents, pendingDeliveries: $pendingDeliveries, alerts: $alerts)';
}


}

/// @nodoc
abstract mixin class $DashboardSummaryCopyWith<$Res>  {
  factory $DashboardSummaryCopyWith(DashboardSummary value, $Res Function(DashboardSummary) _then) = _$DashboardSummaryCopyWithImpl;
@useResult
$Res call({
 String season, int activeFamilies, double totalCollected, double collectionRate, int overduePayments, int activeAgents, int pendingDeliveries, List<DashboardAlert> alerts
});




}
/// @nodoc
class _$DashboardSummaryCopyWithImpl<$Res>
    implements $DashboardSummaryCopyWith<$Res> {
  _$DashboardSummaryCopyWithImpl(this._self, this._then);

  final DashboardSummary _self;
  final $Res Function(DashboardSummary) _then;

/// Create a copy of DashboardSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? season = null,Object? activeFamilies = null,Object? totalCollected = null,Object? collectionRate = null,Object? overduePayments = null,Object? activeAgents = null,Object? pendingDeliveries = null,Object? alerts = null,}) {
  return _then(_self.copyWith(
season: null == season ? _self.season : season // ignore: cast_nullable_to_non_nullable
as String,activeFamilies: null == activeFamilies ? _self.activeFamilies : activeFamilies // ignore: cast_nullable_to_non_nullable
as int,totalCollected: null == totalCollected ? _self.totalCollected : totalCollected // ignore: cast_nullable_to_non_nullable
as double,collectionRate: null == collectionRate ? _self.collectionRate : collectionRate // ignore: cast_nullable_to_non_nullable
as double,overduePayments: null == overduePayments ? _self.overduePayments : overduePayments // ignore: cast_nullable_to_non_nullable
as int,activeAgents: null == activeAgents ? _self.activeAgents : activeAgents // ignore: cast_nullable_to_non_nullable
as int,pendingDeliveries: null == pendingDeliveries ? _self.pendingDeliveries : pendingDeliveries // ignore: cast_nullable_to_non_nullable
as int,alerts: null == alerts ? _self.alerts : alerts // ignore: cast_nullable_to_non_nullable
as List<DashboardAlert>,
  ));
}

}


/// Adds pattern-matching-related methods to [DashboardSummary].
extension DashboardSummaryPatterns on DashboardSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardSummary value)  $default,){
final _that = this;
switch (_that) {
case _DashboardSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardSummary value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String season,  int activeFamilies,  double totalCollected,  double collectionRate,  int overduePayments,  int activeAgents,  int pendingDeliveries,  List<DashboardAlert> alerts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardSummary() when $default != null:
return $default(_that.season,_that.activeFamilies,_that.totalCollected,_that.collectionRate,_that.overduePayments,_that.activeAgents,_that.pendingDeliveries,_that.alerts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String season,  int activeFamilies,  double totalCollected,  double collectionRate,  int overduePayments,  int activeAgents,  int pendingDeliveries,  List<DashboardAlert> alerts)  $default,) {final _that = this;
switch (_that) {
case _DashboardSummary():
return $default(_that.season,_that.activeFamilies,_that.totalCollected,_that.collectionRate,_that.overduePayments,_that.activeAgents,_that.pendingDeliveries,_that.alerts);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String season,  int activeFamilies,  double totalCollected,  double collectionRate,  int overduePayments,  int activeAgents,  int pendingDeliveries,  List<DashboardAlert> alerts)?  $default,) {final _that = this;
switch (_that) {
case _DashboardSummary() when $default != null:
return $default(_that.season,_that.activeFamilies,_that.totalCollected,_that.collectionRate,_that.overduePayments,_that.activeAgents,_that.pendingDeliveries,_that.alerts);case _:
  return null;

}
}

}

/// @nodoc


class _DashboardSummary implements DashboardSummary {
  const _DashboardSummary({required this.season, required this.activeFamilies, required this.totalCollected, required this.collectionRate, required this.overduePayments, required this.activeAgents, required this.pendingDeliveries, required final  List<DashboardAlert> alerts}): _alerts = alerts;
  

@override final  String season;
@override final  int activeFamilies;
@override final  double totalCollected;
/// Entre 0 et 1, ex. 0.89 pour "89%".
@override final  double collectionRate;
@override final  int overduePayments;
@override final  int activeAgents;
@override final  int pendingDeliveries;
 final  List<DashboardAlert> _alerts;
@override List<DashboardAlert> get alerts {
  if (_alerts is EqualUnmodifiableListView) return _alerts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_alerts);
}


/// Create a copy of DashboardSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardSummaryCopyWith<_DashboardSummary> get copyWith => __$DashboardSummaryCopyWithImpl<_DashboardSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardSummary&&(identical(other.season, season) || other.season == season)&&(identical(other.activeFamilies, activeFamilies) || other.activeFamilies == activeFamilies)&&(identical(other.totalCollected, totalCollected) || other.totalCollected == totalCollected)&&(identical(other.collectionRate, collectionRate) || other.collectionRate == collectionRate)&&(identical(other.overduePayments, overduePayments) || other.overduePayments == overduePayments)&&(identical(other.activeAgents, activeAgents) || other.activeAgents == activeAgents)&&(identical(other.pendingDeliveries, pendingDeliveries) || other.pendingDeliveries == pendingDeliveries)&&const DeepCollectionEquality().equals(other._alerts, _alerts));
}


@override
int get hashCode => Object.hash(runtimeType,season,activeFamilies,totalCollected,collectionRate,overduePayments,activeAgents,pendingDeliveries,const DeepCollectionEquality().hash(_alerts));

@override
String toString() {
  return 'DashboardSummary(season: $season, activeFamilies: $activeFamilies, totalCollected: $totalCollected, collectionRate: $collectionRate, overduePayments: $overduePayments, activeAgents: $activeAgents, pendingDeliveries: $pendingDeliveries, alerts: $alerts)';
}


}

/// @nodoc
abstract mixin class _$DashboardSummaryCopyWith<$Res> implements $DashboardSummaryCopyWith<$Res> {
  factory _$DashboardSummaryCopyWith(_DashboardSummary value, $Res Function(_DashboardSummary) _then) = __$DashboardSummaryCopyWithImpl;
@override @useResult
$Res call({
 String season, int activeFamilies, double totalCollected, double collectionRate, int overduePayments, int activeAgents, int pendingDeliveries, List<DashboardAlert> alerts
});




}
/// @nodoc
class __$DashboardSummaryCopyWithImpl<$Res>
    implements _$DashboardSummaryCopyWith<$Res> {
  __$DashboardSummaryCopyWithImpl(this._self, this._then);

  final _DashboardSummary _self;
  final $Res Function(_DashboardSummary) _then;

/// Create a copy of DashboardSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? season = null,Object? activeFamilies = null,Object? totalCollected = null,Object? collectionRate = null,Object? overduePayments = null,Object? activeAgents = null,Object? pendingDeliveries = null,Object? alerts = null,}) {
  return _then(_DashboardSummary(
season: null == season ? _self.season : season // ignore: cast_nullable_to_non_nullable
as String,activeFamilies: null == activeFamilies ? _self.activeFamilies : activeFamilies // ignore: cast_nullable_to_non_nullable
as int,totalCollected: null == totalCollected ? _self.totalCollected : totalCollected // ignore: cast_nullable_to_non_nullable
as double,collectionRate: null == collectionRate ? _self.collectionRate : collectionRate // ignore: cast_nullable_to_non_nullable
as double,overduePayments: null == overduePayments ? _self.overduePayments : overduePayments // ignore: cast_nullable_to_non_nullable
as int,activeAgents: null == activeAgents ? _self.activeAgents : activeAgents // ignore: cast_nullable_to_non_nullable
as int,pendingDeliveries: null == pendingDeliveries ? _self.pendingDeliveries : pendingDeliveries // ignore: cast_nullable_to_non_nullable
as int,alerts: null == alerts ? _self._alerts : alerts // ignore: cast_nullable_to_non_nullable
as List<DashboardAlert>,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'finance_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CityBreakdown {

 String get city; int get familyCount; double get amount;
/// Create a copy of CityBreakdown
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CityBreakdownCopyWith<CityBreakdown> get copyWith => _$CityBreakdownCopyWithImpl<CityBreakdown>(this as CityBreakdown, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CityBreakdown&&(identical(other.city, city) || other.city == city)&&(identical(other.familyCount, familyCount) || other.familyCount == familyCount)&&(identical(other.amount, amount) || other.amount == amount));
}


@override
int get hashCode => Object.hash(runtimeType,city,familyCount,amount);

@override
String toString() {
  return 'CityBreakdown(city: $city, familyCount: $familyCount, amount: $amount)';
}


}

/// @nodoc
abstract mixin class $CityBreakdownCopyWith<$Res>  {
  factory $CityBreakdownCopyWith(CityBreakdown value, $Res Function(CityBreakdown) _then) = _$CityBreakdownCopyWithImpl;
@useResult
$Res call({
 String city, int familyCount, double amount
});




}
/// @nodoc
class _$CityBreakdownCopyWithImpl<$Res>
    implements $CityBreakdownCopyWith<$Res> {
  _$CityBreakdownCopyWithImpl(this._self, this._then);

  final CityBreakdown _self;
  final $Res Function(CityBreakdown) _then;

/// Create a copy of CityBreakdown
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? city = null,Object? familyCount = null,Object? amount = null,}) {
  return _then(_self.copyWith(
city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,familyCount: null == familyCount ? _self.familyCount : familyCount // ignore: cast_nullable_to_non_nullable
as int,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [CityBreakdown].
extension CityBreakdownPatterns on CityBreakdown {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CityBreakdown value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CityBreakdown() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CityBreakdown value)  $default,){
final _that = this;
switch (_that) {
case _CityBreakdown():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CityBreakdown value)?  $default,){
final _that = this;
switch (_that) {
case _CityBreakdown() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String city,  int familyCount,  double amount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CityBreakdown() when $default != null:
return $default(_that.city,_that.familyCount,_that.amount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String city,  int familyCount,  double amount)  $default,) {final _that = this;
switch (_that) {
case _CityBreakdown():
return $default(_that.city,_that.familyCount,_that.amount);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String city,  int familyCount,  double amount)?  $default,) {final _that = this;
switch (_that) {
case _CityBreakdown() when $default != null:
return $default(_that.city,_that.familyCount,_that.amount);case _:
  return null;

}
}

}

/// @nodoc


class _CityBreakdown implements CityBreakdown {
  const _CityBreakdown({required this.city, required this.familyCount, required this.amount});
  

@override final  String city;
@override final  int familyCount;
@override final  double amount;

/// Create a copy of CityBreakdown
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CityBreakdownCopyWith<_CityBreakdown> get copyWith => __$CityBreakdownCopyWithImpl<_CityBreakdown>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CityBreakdown&&(identical(other.city, city) || other.city == city)&&(identical(other.familyCount, familyCount) || other.familyCount == familyCount)&&(identical(other.amount, amount) || other.amount == amount));
}


@override
int get hashCode => Object.hash(runtimeType,city,familyCount,amount);

@override
String toString() {
  return 'CityBreakdown(city: $city, familyCount: $familyCount, amount: $amount)';
}


}

/// @nodoc
abstract mixin class _$CityBreakdownCopyWith<$Res> implements $CityBreakdownCopyWith<$Res> {
  factory _$CityBreakdownCopyWith(_CityBreakdown value, $Res Function(_CityBreakdown) _then) = __$CityBreakdownCopyWithImpl;
@override @useResult
$Res call({
 String city, int familyCount, double amount
});




}
/// @nodoc
class __$CityBreakdownCopyWithImpl<$Res>
    implements _$CityBreakdownCopyWith<$Res> {
  __$CityBreakdownCopyWithImpl(this._self, this._then);

  final _CityBreakdown _self;
  final $Res Function(_CityBreakdown) _then;

/// Create a copy of CityBreakdown
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? city = null,Object? familyCount = null,Object? amount = null,}) {
  return _then(_CityBreakdown(
city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,familyCount: null == familyCount ? _self.familyCount : familyCount // ignore: cast_nullable_to_non_nullable
as int,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
mixin _$PlanBreakdown {

 SavingsPlan get plan; int get familyCount; double get amount;
/// Create a copy of PlanBreakdown
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlanBreakdownCopyWith<PlanBreakdown> get copyWith => _$PlanBreakdownCopyWithImpl<PlanBreakdown>(this as PlanBreakdown, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlanBreakdown&&(identical(other.plan, plan) || other.plan == plan)&&(identical(other.familyCount, familyCount) || other.familyCount == familyCount)&&(identical(other.amount, amount) || other.amount == amount));
}


@override
int get hashCode => Object.hash(runtimeType,plan,familyCount,amount);

@override
String toString() {
  return 'PlanBreakdown(plan: $plan, familyCount: $familyCount, amount: $amount)';
}


}

/// @nodoc
abstract mixin class $PlanBreakdownCopyWith<$Res>  {
  factory $PlanBreakdownCopyWith(PlanBreakdown value, $Res Function(PlanBreakdown) _then) = _$PlanBreakdownCopyWithImpl;
@useResult
$Res call({
 SavingsPlan plan, int familyCount, double amount
});




}
/// @nodoc
class _$PlanBreakdownCopyWithImpl<$Res>
    implements $PlanBreakdownCopyWith<$Res> {
  _$PlanBreakdownCopyWithImpl(this._self, this._then);

  final PlanBreakdown _self;
  final $Res Function(PlanBreakdown) _then;

/// Create a copy of PlanBreakdown
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? plan = null,Object? familyCount = null,Object? amount = null,}) {
  return _then(_self.copyWith(
plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as SavingsPlan,familyCount: null == familyCount ? _self.familyCount : familyCount // ignore: cast_nullable_to_non_nullable
as int,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [PlanBreakdown].
extension PlanBreakdownPatterns on PlanBreakdown {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlanBreakdown value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlanBreakdown() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlanBreakdown value)  $default,){
final _that = this;
switch (_that) {
case _PlanBreakdown():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlanBreakdown value)?  $default,){
final _that = this;
switch (_that) {
case _PlanBreakdown() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SavingsPlan plan,  int familyCount,  double amount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlanBreakdown() when $default != null:
return $default(_that.plan,_that.familyCount,_that.amount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SavingsPlan plan,  int familyCount,  double amount)  $default,) {final _that = this;
switch (_that) {
case _PlanBreakdown():
return $default(_that.plan,_that.familyCount,_that.amount);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SavingsPlan plan,  int familyCount,  double amount)?  $default,) {final _that = this;
switch (_that) {
case _PlanBreakdown() when $default != null:
return $default(_that.plan,_that.familyCount,_that.amount);case _:
  return null;

}
}

}

/// @nodoc


class _PlanBreakdown implements PlanBreakdown {
  const _PlanBreakdown({required this.plan, required this.familyCount, required this.amount});
  

@override final  SavingsPlan plan;
@override final  int familyCount;
@override final  double amount;

/// Create a copy of PlanBreakdown
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlanBreakdownCopyWith<_PlanBreakdown> get copyWith => __$PlanBreakdownCopyWithImpl<_PlanBreakdown>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlanBreakdown&&(identical(other.plan, plan) || other.plan == plan)&&(identical(other.familyCount, familyCount) || other.familyCount == familyCount)&&(identical(other.amount, amount) || other.amount == amount));
}


@override
int get hashCode => Object.hash(runtimeType,plan,familyCount,amount);

@override
String toString() {
  return 'PlanBreakdown(plan: $plan, familyCount: $familyCount, amount: $amount)';
}


}

/// @nodoc
abstract mixin class _$PlanBreakdownCopyWith<$Res> implements $PlanBreakdownCopyWith<$Res> {
  factory _$PlanBreakdownCopyWith(_PlanBreakdown value, $Res Function(_PlanBreakdown) _then) = __$PlanBreakdownCopyWithImpl;
@override @useResult
$Res call({
 SavingsPlan plan, int familyCount, double amount
});




}
/// @nodoc
class __$PlanBreakdownCopyWithImpl<$Res>
    implements _$PlanBreakdownCopyWith<$Res> {
  __$PlanBreakdownCopyWithImpl(this._self, this._then);

  final _PlanBreakdown _self;
  final $Res Function(_PlanBreakdown) _then;

/// Create a copy of PlanBreakdown
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? plan = null,Object? familyCount = null,Object? amount = null,}) {
  return _then(_PlanBreakdown(
plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as SavingsPlan,familyCount: null == familyCount ? _self.familyCount : familyCount // ignore: cast_nullable_to_non_nullable
as int,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
mixin _$FinanceSummary {

 double get totalCollected; int get activeFamilies; List<CityBreakdown> get byCity; List<PlanBreakdown> get byPlan;
/// Create a copy of FinanceSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FinanceSummaryCopyWith<FinanceSummary> get copyWith => _$FinanceSummaryCopyWithImpl<FinanceSummary>(this as FinanceSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FinanceSummary&&(identical(other.totalCollected, totalCollected) || other.totalCollected == totalCollected)&&(identical(other.activeFamilies, activeFamilies) || other.activeFamilies == activeFamilies)&&const DeepCollectionEquality().equals(other.byCity, byCity)&&const DeepCollectionEquality().equals(other.byPlan, byPlan));
}


@override
int get hashCode => Object.hash(runtimeType,totalCollected,activeFamilies,const DeepCollectionEquality().hash(byCity),const DeepCollectionEquality().hash(byPlan));

@override
String toString() {
  return 'FinanceSummary(totalCollected: $totalCollected, activeFamilies: $activeFamilies, byCity: $byCity, byPlan: $byPlan)';
}


}

/// @nodoc
abstract mixin class $FinanceSummaryCopyWith<$Res>  {
  factory $FinanceSummaryCopyWith(FinanceSummary value, $Res Function(FinanceSummary) _then) = _$FinanceSummaryCopyWithImpl;
@useResult
$Res call({
 double totalCollected, int activeFamilies, List<CityBreakdown> byCity, List<PlanBreakdown> byPlan
});




}
/// @nodoc
class _$FinanceSummaryCopyWithImpl<$Res>
    implements $FinanceSummaryCopyWith<$Res> {
  _$FinanceSummaryCopyWithImpl(this._self, this._then);

  final FinanceSummary _self;
  final $Res Function(FinanceSummary) _then;

/// Create a copy of FinanceSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalCollected = null,Object? activeFamilies = null,Object? byCity = null,Object? byPlan = null,}) {
  return _then(_self.copyWith(
totalCollected: null == totalCollected ? _self.totalCollected : totalCollected // ignore: cast_nullable_to_non_nullable
as double,activeFamilies: null == activeFamilies ? _self.activeFamilies : activeFamilies // ignore: cast_nullable_to_non_nullable
as int,byCity: null == byCity ? _self.byCity : byCity // ignore: cast_nullable_to_non_nullable
as List<CityBreakdown>,byPlan: null == byPlan ? _self.byPlan : byPlan // ignore: cast_nullable_to_non_nullable
as List<PlanBreakdown>,
  ));
}

}


/// Adds pattern-matching-related methods to [FinanceSummary].
extension FinanceSummaryPatterns on FinanceSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FinanceSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FinanceSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FinanceSummary value)  $default,){
final _that = this;
switch (_that) {
case _FinanceSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FinanceSummary value)?  $default,){
final _that = this;
switch (_that) {
case _FinanceSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double totalCollected,  int activeFamilies,  List<CityBreakdown> byCity,  List<PlanBreakdown> byPlan)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FinanceSummary() when $default != null:
return $default(_that.totalCollected,_that.activeFamilies,_that.byCity,_that.byPlan);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double totalCollected,  int activeFamilies,  List<CityBreakdown> byCity,  List<PlanBreakdown> byPlan)  $default,) {final _that = this;
switch (_that) {
case _FinanceSummary():
return $default(_that.totalCollected,_that.activeFamilies,_that.byCity,_that.byPlan);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double totalCollected,  int activeFamilies,  List<CityBreakdown> byCity,  List<PlanBreakdown> byPlan)?  $default,) {final _that = this;
switch (_that) {
case _FinanceSummary() when $default != null:
return $default(_that.totalCollected,_that.activeFamilies,_that.byCity,_that.byPlan);case _:
  return null;

}
}

}

/// @nodoc


class _FinanceSummary implements FinanceSummary {
  const _FinanceSummary({required this.totalCollected, required this.activeFamilies, required final  List<CityBreakdown> byCity, required final  List<PlanBreakdown> byPlan}): _byCity = byCity,_byPlan = byPlan;
  

@override final  double totalCollected;
@override final  int activeFamilies;
 final  List<CityBreakdown> _byCity;
@override List<CityBreakdown> get byCity {
  if (_byCity is EqualUnmodifiableListView) return _byCity;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_byCity);
}

 final  List<PlanBreakdown> _byPlan;
@override List<PlanBreakdown> get byPlan {
  if (_byPlan is EqualUnmodifiableListView) return _byPlan;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_byPlan);
}


/// Create a copy of FinanceSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FinanceSummaryCopyWith<_FinanceSummary> get copyWith => __$FinanceSummaryCopyWithImpl<_FinanceSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FinanceSummary&&(identical(other.totalCollected, totalCollected) || other.totalCollected == totalCollected)&&(identical(other.activeFamilies, activeFamilies) || other.activeFamilies == activeFamilies)&&const DeepCollectionEquality().equals(other._byCity, _byCity)&&const DeepCollectionEquality().equals(other._byPlan, _byPlan));
}


@override
int get hashCode => Object.hash(runtimeType,totalCollected,activeFamilies,const DeepCollectionEquality().hash(_byCity),const DeepCollectionEquality().hash(_byPlan));

@override
String toString() {
  return 'FinanceSummary(totalCollected: $totalCollected, activeFamilies: $activeFamilies, byCity: $byCity, byPlan: $byPlan)';
}


}

/// @nodoc
abstract mixin class _$FinanceSummaryCopyWith<$Res> implements $FinanceSummaryCopyWith<$Res> {
  factory _$FinanceSummaryCopyWith(_FinanceSummary value, $Res Function(_FinanceSummary) _then) = __$FinanceSummaryCopyWithImpl;
@override @useResult
$Res call({
 double totalCollected, int activeFamilies, List<CityBreakdown> byCity, List<PlanBreakdown> byPlan
});




}
/// @nodoc
class __$FinanceSummaryCopyWithImpl<$Res>
    implements _$FinanceSummaryCopyWith<$Res> {
  __$FinanceSummaryCopyWithImpl(this._self, this._then);

  final _FinanceSummary _self;
  final $Res Function(_FinanceSummary) _then;

/// Create a copy of FinanceSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalCollected = null,Object? activeFamilies = null,Object? byCity = null,Object? byPlan = null,}) {
  return _then(_FinanceSummary(
totalCollected: null == totalCollected ? _self.totalCollected : totalCollected // ignore: cast_nullable_to_non_nullable
as double,activeFamilies: null == activeFamilies ? _self.activeFamilies : activeFamilies // ignore: cast_nullable_to_non_nullable
as int,byCity: null == byCity ? _self._byCity : byCity // ignore: cast_nullable_to_non_nullable
as List<CityBreakdown>,byPlan: null == byPlan ? _self._byPlan : byPlan // ignore: cast_nullable_to_non_nullable
as List<PlanBreakdown>,
  ));
}


}

// dart format on

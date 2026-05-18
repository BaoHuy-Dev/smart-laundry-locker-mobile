// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'partner.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PartnerDashboard {

 int get partnerId; String get businessName; int get totalStores; int get activeStores; int get totalStaff; int get totalOrders; int get pendingOrders; int get completedOrders; int get canceledOrders; double get totalRevenue; double get partnerRevenue; double get platformFee; double get todayRevenue; double get monthRevenue;
/// Create a copy of PartnerDashboard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PartnerDashboardCopyWith<PartnerDashboard> get copyWith => _$PartnerDashboardCopyWithImpl<PartnerDashboard>(this as PartnerDashboard, _$identity);

  /// Serializes this PartnerDashboard to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PartnerDashboard&&(identical(other.partnerId, partnerId) || other.partnerId == partnerId)&&(identical(other.businessName, businessName) || other.businessName == businessName)&&(identical(other.totalStores, totalStores) || other.totalStores == totalStores)&&(identical(other.activeStores, activeStores) || other.activeStores == activeStores)&&(identical(other.totalStaff, totalStaff) || other.totalStaff == totalStaff)&&(identical(other.totalOrders, totalOrders) || other.totalOrders == totalOrders)&&(identical(other.pendingOrders, pendingOrders) || other.pendingOrders == pendingOrders)&&(identical(other.completedOrders, completedOrders) || other.completedOrders == completedOrders)&&(identical(other.canceledOrders, canceledOrders) || other.canceledOrders == canceledOrders)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.partnerRevenue, partnerRevenue) || other.partnerRevenue == partnerRevenue)&&(identical(other.platformFee, platformFee) || other.platformFee == platformFee)&&(identical(other.todayRevenue, todayRevenue) || other.todayRevenue == todayRevenue)&&(identical(other.monthRevenue, monthRevenue) || other.monthRevenue == monthRevenue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,partnerId,businessName,totalStores,activeStores,totalStaff,totalOrders,pendingOrders,completedOrders,canceledOrders,totalRevenue,partnerRevenue,platformFee,todayRevenue,monthRevenue);

@override
String toString() {
  return 'PartnerDashboard(partnerId: $partnerId, businessName: $businessName, totalStores: $totalStores, activeStores: $activeStores, totalStaff: $totalStaff, totalOrders: $totalOrders, pendingOrders: $pendingOrders, completedOrders: $completedOrders, canceledOrders: $canceledOrders, totalRevenue: $totalRevenue, partnerRevenue: $partnerRevenue, platformFee: $platformFee, todayRevenue: $todayRevenue, monthRevenue: $monthRevenue)';
}


}

/// @nodoc
abstract mixin class $PartnerDashboardCopyWith<$Res>  {
  factory $PartnerDashboardCopyWith(PartnerDashboard value, $Res Function(PartnerDashboard) _then) = _$PartnerDashboardCopyWithImpl;
@useResult
$Res call({
 int partnerId, String businessName, int totalStores, int activeStores, int totalStaff, int totalOrders, int pendingOrders, int completedOrders, int canceledOrders, double totalRevenue, double partnerRevenue, double platformFee, double todayRevenue, double monthRevenue
});




}
/// @nodoc
class _$PartnerDashboardCopyWithImpl<$Res>
    implements $PartnerDashboardCopyWith<$Res> {
  _$PartnerDashboardCopyWithImpl(this._self, this._then);

  final PartnerDashboard _self;
  final $Res Function(PartnerDashboard) _then;

/// Create a copy of PartnerDashboard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? partnerId = null,Object? businessName = null,Object? totalStores = null,Object? activeStores = null,Object? totalStaff = null,Object? totalOrders = null,Object? pendingOrders = null,Object? completedOrders = null,Object? canceledOrders = null,Object? totalRevenue = null,Object? partnerRevenue = null,Object? platformFee = null,Object? todayRevenue = null,Object? monthRevenue = null,}) {
  return _then(_self.copyWith(
partnerId: null == partnerId ? _self.partnerId : partnerId // ignore: cast_nullable_to_non_nullable
as int,businessName: null == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String,totalStores: null == totalStores ? _self.totalStores : totalStores // ignore: cast_nullable_to_non_nullable
as int,activeStores: null == activeStores ? _self.activeStores : activeStores // ignore: cast_nullable_to_non_nullable
as int,totalStaff: null == totalStaff ? _self.totalStaff : totalStaff // ignore: cast_nullable_to_non_nullable
as int,totalOrders: null == totalOrders ? _self.totalOrders : totalOrders // ignore: cast_nullable_to_non_nullable
as int,pendingOrders: null == pendingOrders ? _self.pendingOrders : pendingOrders // ignore: cast_nullable_to_non_nullable
as int,completedOrders: null == completedOrders ? _self.completedOrders : completedOrders // ignore: cast_nullable_to_non_nullable
as int,canceledOrders: null == canceledOrders ? _self.canceledOrders : canceledOrders // ignore: cast_nullable_to_non_nullable
as int,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,partnerRevenue: null == partnerRevenue ? _self.partnerRevenue : partnerRevenue // ignore: cast_nullable_to_non_nullable
as double,platformFee: null == platformFee ? _self.platformFee : platformFee // ignore: cast_nullable_to_non_nullable
as double,todayRevenue: null == todayRevenue ? _self.todayRevenue : todayRevenue // ignore: cast_nullable_to_non_nullable
as double,monthRevenue: null == monthRevenue ? _self.monthRevenue : monthRevenue // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [PartnerDashboard].
extension PartnerDashboardPatterns on PartnerDashboard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PartnerDashboard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PartnerDashboard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PartnerDashboard value)  $default,){
final _that = this;
switch (_that) {
case _PartnerDashboard():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PartnerDashboard value)?  $default,){
final _that = this;
switch (_that) {
case _PartnerDashboard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int partnerId,  String businessName,  int totalStores,  int activeStores,  int totalStaff,  int totalOrders,  int pendingOrders,  int completedOrders,  int canceledOrders,  double totalRevenue,  double partnerRevenue,  double platformFee,  double todayRevenue,  double monthRevenue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PartnerDashboard() when $default != null:
return $default(_that.partnerId,_that.businessName,_that.totalStores,_that.activeStores,_that.totalStaff,_that.totalOrders,_that.pendingOrders,_that.completedOrders,_that.canceledOrders,_that.totalRevenue,_that.partnerRevenue,_that.platformFee,_that.todayRevenue,_that.monthRevenue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int partnerId,  String businessName,  int totalStores,  int activeStores,  int totalStaff,  int totalOrders,  int pendingOrders,  int completedOrders,  int canceledOrders,  double totalRevenue,  double partnerRevenue,  double platformFee,  double todayRevenue,  double monthRevenue)  $default,) {final _that = this;
switch (_that) {
case _PartnerDashboard():
return $default(_that.partnerId,_that.businessName,_that.totalStores,_that.activeStores,_that.totalStaff,_that.totalOrders,_that.pendingOrders,_that.completedOrders,_that.canceledOrders,_that.totalRevenue,_that.partnerRevenue,_that.platformFee,_that.todayRevenue,_that.monthRevenue);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int partnerId,  String businessName,  int totalStores,  int activeStores,  int totalStaff,  int totalOrders,  int pendingOrders,  int completedOrders,  int canceledOrders,  double totalRevenue,  double partnerRevenue,  double platformFee,  double todayRevenue,  double monthRevenue)?  $default,) {final _that = this;
switch (_that) {
case _PartnerDashboard() when $default != null:
return $default(_that.partnerId,_that.businessName,_that.totalStores,_that.activeStores,_that.totalStaff,_that.totalOrders,_that.pendingOrders,_that.completedOrders,_that.canceledOrders,_that.totalRevenue,_that.partnerRevenue,_that.platformFee,_that.todayRevenue,_that.monthRevenue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PartnerDashboard implements PartnerDashboard {
  const _PartnerDashboard({required this.partnerId, required this.businessName, required this.totalStores, required this.activeStores, required this.totalStaff, required this.totalOrders, required this.pendingOrders, required this.completedOrders, required this.canceledOrders, required this.totalRevenue, required this.partnerRevenue, required this.platformFee, required this.todayRevenue, required this.monthRevenue});
  factory _PartnerDashboard.fromJson(Map<String, dynamic> json) => _$PartnerDashboardFromJson(json);

@override final  int partnerId;
@override final  String businessName;
@override final  int totalStores;
@override final  int activeStores;
@override final  int totalStaff;
@override final  int totalOrders;
@override final  int pendingOrders;
@override final  int completedOrders;
@override final  int canceledOrders;
@override final  double totalRevenue;
@override final  double partnerRevenue;
@override final  double platformFee;
@override final  double todayRevenue;
@override final  double monthRevenue;

/// Create a copy of PartnerDashboard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PartnerDashboardCopyWith<_PartnerDashboard> get copyWith => __$PartnerDashboardCopyWithImpl<_PartnerDashboard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PartnerDashboardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PartnerDashboard&&(identical(other.partnerId, partnerId) || other.partnerId == partnerId)&&(identical(other.businessName, businessName) || other.businessName == businessName)&&(identical(other.totalStores, totalStores) || other.totalStores == totalStores)&&(identical(other.activeStores, activeStores) || other.activeStores == activeStores)&&(identical(other.totalStaff, totalStaff) || other.totalStaff == totalStaff)&&(identical(other.totalOrders, totalOrders) || other.totalOrders == totalOrders)&&(identical(other.pendingOrders, pendingOrders) || other.pendingOrders == pendingOrders)&&(identical(other.completedOrders, completedOrders) || other.completedOrders == completedOrders)&&(identical(other.canceledOrders, canceledOrders) || other.canceledOrders == canceledOrders)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.partnerRevenue, partnerRevenue) || other.partnerRevenue == partnerRevenue)&&(identical(other.platformFee, platformFee) || other.platformFee == platformFee)&&(identical(other.todayRevenue, todayRevenue) || other.todayRevenue == todayRevenue)&&(identical(other.monthRevenue, monthRevenue) || other.monthRevenue == monthRevenue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,partnerId,businessName,totalStores,activeStores,totalStaff,totalOrders,pendingOrders,completedOrders,canceledOrders,totalRevenue,partnerRevenue,platformFee,todayRevenue,monthRevenue);

@override
String toString() {
  return 'PartnerDashboard(partnerId: $partnerId, businessName: $businessName, totalStores: $totalStores, activeStores: $activeStores, totalStaff: $totalStaff, totalOrders: $totalOrders, pendingOrders: $pendingOrders, completedOrders: $completedOrders, canceledOrders: $canceledOrders, totalRevenue: $totalRevenue, partnerRevenue: $partnerRevenue, platformFee: $platformFee, todayRevenue: $todayRevenue, monthRevenue: $monthRevenue)';
}


}

/// @nodoc
abstract mixin class _$PartnerDashboardCopyWith<$Res> implements $PartnerDashboardCopyWith<$Res> {
  factory _$PartnerDashboardCopyWith(_PartnerDashboard value, $Res Function(_PartnerDashboard) _then) = __$PartnerDashboardCopyWithImpl;
@override @useResult
$Res call({
 int partnerId, String businessName, int totalStores, int activeStores, int totalStaff, int totalOrders, int pendingOrders, int completedOrders, int canceledOrders, double totalRevenue, double partnerRevenue, double platformFee, double todayRevenue, double monthRevenue
});




}
/// @nodoc
class __$PartnerDashboardCopyWithImpl<$Res>
    implements _$PartnerDashboardCopyWith<$Res> {
  __$PartnerDashboardCopyWithImpl(this._self, this._then);

  final _PartnerDashboard _self;
  final $Res Function(_PartnerDashboard) _then;

/// Create a copy of PartnerDashboard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? partnerId = null,Object? businessName = null,Object? totalStores = null,Object? activeStores = null,Object? totalStaff = null,Object? totalOrders = null,Object? pendingOrders = null,Object? completedOrders = null,Object? canceledOrders = null,Object? totalRevenue = null,Object? partnerRevenue = null,Object? platformFee = null,Object? todayRevenue = null,Object? monthRevenue = null,}) {
  return _then(_PartnerDashboard(
partnerId: null == partnerId ? _self.partnerId : partnerId // ignore: cast_nullable_to_non_nullable
as int,businessName: null == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String,totalStores: null == totalStores ? _self.totalStores : totalStores // ignore: cast_nullable_to_non_nullable
as int,activeStores: null == activeStores ? _self.activeStores : activeStores // ignore: cast_nullable_to_non_nullable
as int,totalStaff: null == totalStaff ? _self.totalStaff : totalStaff // ignore: cast_nullable_to_non_nullable
as int,totalOrders: null == totalOrders ? _self.totalOrders : totalOrders // ignore: cast_nullable_to_non_nullable
as int,pendingOrders: null == pendingOrders ? _self.pendingOrders : pendingOrders // ignore: cast_nullable_to_non_nullable
as int,completedOrders: null == completedOrders ? _self.completedOrders : completedOrders // ignore: cast_nullable_to_non_nullable
as int,canceledOrders: null == canceledOrders ? _self.canceledOrders : canceledOrders // ignore: cast_nullable_to_non_nullable
as int,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,partnerRevenue: null == partnerRevenue ? _self.partnerRevenue : partnerRevenue // ignore: cast_nullable_to_non_nullable
as double,platformFee: null == platformFee ? _self.platformFee : platformFee // ignore: cast_nullable_to_non_nullable
as double,todayRevenue: null == todayRevenue ? _self.todayRevenue : todayRevenue // ignore: cast_nullable_to_non_nullable
as double,monthRevenue: null == monthRevenue ? _self.monthRevenue : monthRevenue // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$PartnerProfile {

 int get id; String get businessName; String? get businessRegistrationNumber; String? get taxId; String get businessAddress; String get contactPhone; String? get contactEmail; Map<String, dynamic>? get user; String get status; String? get approvedAt; int? get approvedBy; String? get rejectionReason; double get revenueSharePercent; int get storeCount; int get staffCount; String get notes; String get createdAt; String get updatedAt;
/// Create a copy of PartnerProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PartnerProfileCopyWith<PartnerProfile> get copyWith => _$PartnerProfileCopyWithImpl<PartnerProfile>(this as PartnerProfile, _$identity);

  /// Serializes this PartnerProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PartnerProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.businessName, businessName) || other.businessName == businessName)&&(identical(other.businessRegistrationNumber, businessRegistrationNumber) || other.businessRegistrationNumber == businessRegistrationNumber)&&(identical(other.taxId, taxId) || other.taxId == taxId)&&(identical(other.businessAddress, businessAddress) || other.businessAddress == businessAddress)&&(identical(other.contactPhone, contactPhone) || other.contactPhone == contactPhone)&&(identical(other.contactEmail, contactEmail) || other.contactEmail == contactEmail)&&const DeepCollectionEquality().equals(other.user, user)&&(identical(other.status, status) || other.status == status)&&(identical(other.approvedAt, approvedAt) || other.approvedAt == approvedAt)&&(identical(other.approvedBy, approvedBy) || other.approvedBy == approvedBy)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.revenueSharePercent, revenueSharePercent) || other.revenueSharePercent == revenueSharePercent)&&(identical(other.storeCount, storeCount) || other.storeCount == storeCount)&&(identical(other.staffCount, staffCount) || other.staffCount == staffCount)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,businessName,businessRegistrationNumber,taxId,businessAddress,contactPhone,contactEmail,const DeepCollectionEquality().hash(user),status,approvedAt,approvedBy,rejectionReason,revenueSharePercent,storeCount,staffCount,notes,createdAt,updatedAt);

@override
String toString() {
  return 'PartnerProfile(id: $id, businessName: $businessName, businessRegistrationNumber: $businessRegistrationNumber, taxId: $taxId, businessAddress: $businessAddress, contactPhone: $contactPhone, contactEmail: $contactEmail, user: $user, status: $status, approvedAt: $approvedAt, approvedBy: $approvedBy, rejectionReason: $rejectionReason, revenueSharePercent: $revenueSharePercent, storeCount: $storeCount, staffCount: $staffCount, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PartnerProfileCopyWith<$Res>  {
  factory $PartnerProfileCopyWith(PartnerProfile value, $Res Function(PartnerProfile) _then) = _$PartnerProfileCopyWithImpl;
@useResult
$Res call({
 int id, String businessName, String? businessRegistrationNumber, String? taxId, String businessAddress, String contactPhone, String? contactEmail, Map<String, dynamic>? user, String status, String? approvedAt, int? approvedBy, String? rejectionReason, double revenueSharePercent, int storeCount, int staffCount, String notes, String createdAt, String updatedAt
});




}
/// @nodoc
class _$PartnerProfileCopyWithImpl<$Res>
    implements $PartnerProfileCopyWith<$Res> {
  _$PartnerProfileCopyWithImpl(this._self, this._then);

  final PartnerProfile _self;
  final $Res Function(PartnerProfile) _then;

/// Create a copy of PartnerProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? businessName = null,Object? businessRegistrationNumber = freezed,Object? taxId = freezed,Object? businessAddress = null,Object? contactPhone = null,Object? contactEmail = freezed,Object? user = freezed,Object? status = null,Object? approvedAt = freezed,Object? approvedBy = freezed,Object? rejectionReason = freezed,Object? revenueSharePercent = null,Object? storeCount = null,Object? staffCount = null,Object? notes = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,businessName: null == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String,businessRegistrationNumber: freezed == businessRegistrationNumber ? _self.businessRegistrationNumber : businessRegistrationNumber // ignore: cast_nullable_to_non_nullable
as String?,taxId: freezed == taxId ? _self.taxId : taxId // ignore: cast_nullable_to_non_nullable
as String?,businessAddress: null == businessAddress ? _self.businessAddress : businessAddress // ignore: cast_nullable_to_non_nullable
as String,contactPhone: null == contactPhone ? _self.contactPhone : contactPhone // ignore: cast_nullable_to_non_nullable
as String,contactEmail: freezed == contactEmail ? _self.contactEmail : contactEmail // ignore: cast_nullable_to_non_nullable
as String?,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,approvedAt: freezed == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as String?,approvedBy: freezed == approvedBy ? _self.approvedBy : approvedBy // ignore: cast_nullable_to_non_nullable
as int?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,revenueSharePercent: null == revenueSharePercent ? _self.revenueSharePercent : revenueSharePercent // ignore: cast_nullable_to_non_nullable
as double,storeCount: null == storeCount ? _self.storeCount : storeCount // ignore: cast_nullable_to_non_nullable
as int,staffCount: null == staffCount ? _self.staffCount : staffCount // ignore: cast_nullable_to_non_nullable
as int,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PartnerProfile].
extension PartnerProfilePatterns on PartnerProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PartnerProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PartnerProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PartnerProfile value)  $default,){
final _that = this;
switch (_that) {
case _PartnerProfile():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PartnerProfile value)?  $default,){
final _that = this;
switch (_that) {
case _PartnerProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String businessName,  String? businessRegistrationNumber,  String? taxId,  String businessAddress,  String contactPhone,  String? contactEmail,  Map<String, dynamic>? user,  String status,  String? approvedAt,  int? approvedBy,  String? rejectionReason,  double revenueSharePercent,  int storeCount,  int staffCount,  String notes,  String createdAt,  String updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PartnerProfile() when $default != null:
return $default(_that.id,_that.businessName,_that.businessRegistrationNumber,_that.taxId,_that.businessAddress,_that.contactPhone,_that.contactEmail,_that.user,_that.status,_that.approvedAt,_that.approvedBy,_that.rejectionReason,_that.revenueSharePercent,_that.storeCount,_that.staffCount,_that.notes,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String businessName,  String? businessRegistrationNumber,  String? taxId,  String businessAddress,  String contactPhone,  String? contactEmail,  Map<String, dynamic>? user,  String status,  String? approvedAt,  int? approvedBy,  String? rejectionReason,  double revenueSharePercent,  int storeCount,  int staffCount,  String notes,  String createdAt,  String updatedAt)  $default,) {final _that = this;
switch (_that) {
case _PartnerProfile():
return $default(_that.id,_that.businessName,_that.businessRegistrationNumber,_that.taxId,_that.businessAddress,_that.contactPhone,_that.contactEmail,_that.user,_that.status,_that.approvedAt,_that.approvedBy,_that.rejectionReason,_that.revenueSharePercent,_that.storeCount,_that.staffCount,_that.notes,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String businessName,  String? businessRegistrationNumber,  String? taxId,  String businessAddress,  String contactPhone,  String? contactEmail,  Map<String, dynamic>? user,  String status,  String? approvedAt,  int? approvedBy,  String? rejectionReason,  double revenueSharePercent,  int storeCount,  int staffCount,  String notes,  String createdAt,  String updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PartnerProfile() when $default != null:
return $default(_that.id,_that.businessName,_that.businessRegistrationNumber,_that.taxId,_that.businessAddress,_that.contactPhone,_that.contactEmail,_that.user,_that.status,_that.approvedAt,_that.approvedBy,_that.rejectionReason,_that.revenueSharePercent,_that.storeCount,_that.staffCount,_that.notes,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PartnerProfile implements PartnerProfile {
  const _PartnerProfile({required this.id, required this.businessName, this.businessRegistrationNumber, this.taxId, required this.businessAddress, required this.contactPhone, this.contactEmail, final  Map<String, dynamic>? user, required this.status, this.approvedAt, this.approvedBy, this.rejectionReason, required this.revenueSharePercent, required this.storeCount, required this.staffCount, required this.notes, required this.createdAt, required this.updatedAt}): _user = user;
  factory _PartnerProfile.fromJson(Map<String, dynamic> json) => _$PartnerProfileFromJson(json);

@override final  int id;
@override final  String businessName;
@override final  String? businessRegistrationNumber;
@override final  String? taxId;
@override final  String businessAddress;
@override final  String contactPhone;
@override final  String? contactEmail;
 final  Map<String, dynamic>? _user;
@override Map<String, dynamic>? get user {
  final value = _user;
  if (value == null) return null;
  if (_user is EqualUnmodifiableMapView) return _user;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String status;
@override final  String? approvedAt;
@override final  int? approvedBy;
@override final  String? rejectionReason;
@override final  double revenueSharePercent;
@override final  int storeCount;
@override final  int staffCount;
@override final  String notes;
@override final  String createdAt;
@override final  String updatedAt;

/// Create a copy of PartnerProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PartnerProfileCopyWith<_PartnerProfile> get copyWith => __$PartnerProfileCopyWithImpl<_PartnerProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PartnerProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PartnerProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.businessName, businessName) || other.businessName == businessName)&&(identical(other.businessRegistrationNumber, businessRegistrationNumber) || other.businessRegistrationNumber == businessRegistrationNumber)&&(identical(other.taxId, taxId) || other.taxId == taxId)&&(identical(other.businessAddress, businessAddress) || other.businessAddress == businessAddress)&&(identical(other.contactPhone, contactPhone) || other.contactPhone == contactPhone)&&(identical(other.contactEmail, contactEmail) || other.contactEmail == contactEmail)&&const DeepCollectionEquality().equals(other._user, _user)&&(identical(other.status, status) || other.status == status)&&(identical(other.approvedAt, approvedAt) || other.approvedAt == approvedAt)&&(identical(other.approvedBy, approvedBy) || other.approvedBy == approvedBy)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.revenueSharePercent, revenueSharePercent) || other.revenueSharePercent == revenueSharePercent)&&(identical(other.storeCount, storeCount) || other.storeCount == storeCount)&&(identical(other.staffCount, staffCount) || other.staffCount == staffCount)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,businessName,businessRegistrationNumber,taxId,businessAddress,contactPhone,contactEmail,const DeepCollectionEquality().hash(_user),status,approvedAt,approvedBy,rejectionReason,revenueSharePercent,storeCount,staffCount,notes,createdAt,updatedAt);

@override
String toString() {
  return 'PartnerProfile(id: $id, businessName: $businessName, businessRegistrationNumber: $businessRegistrationNumber, taxId: $taxId, businessAddress: $businessAddress, contactPhone: $contactPhone, contactEmail: $contactEmail, user: $user, status: $status, approvedAt: $approvedAt, approvedBy: $approvedBy, rejectionReason: $rejectionReason, revenueSharePercent: $revenueSharePercent, storeCount: $storeCount, staffCount: $staffCount, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PartnerProfileCopyWith<$Res> implements $PartnerProfileCopyWith<$Res> {
  factory _$PartnerProfileCopyWith(_PartnerProfile value, $Res Function(_PartnerProfile) _then) = __$PartnerProfileCopyWithImpl;
@override @useResult
$Res call({
 int id, String businessName, String? businessRegistrationNumber, String? taxId, String businessAddress, String contactPhone, String? contactEmail, Map<String, dynamic>? user, String status, String? approvedAt, int? approvedBy, String? rejectionReason, double revenueSharePercent, int storeCount, int staffCount, String notes, String createdAt, String updatedAt
});




}
/// @nodoc
class __$PartnerProfileCopyWithImpl<$Res>
    implements _$PartnerProfileCopyWith<$Res> {
  __$PartnerProfileCopyWithImpl(this._self, this._then);

  final _PartnerProfile _self;
  final $Res Function(_PartnerProfile) _then;

/// Create a copy of PartnerProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? businessName = null,Object? businessRegistrationNumber = freezed,Object? taxId = freezed,Object? businessAddress = null,Object? contactPhone = null,Object? contactEmail = freezed,Object? user = freezed,Object? status = null,Object? approvedAt = freezed,Object? approvedBy = freezed,Object? rejectionReason = freezed,Object? revenueSharePercent = null,Object? storeCount = null,Object? staffCount = null,Object? notes = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_PartnerProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,businessName: null == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String,businessRegistrationNumber: freezed == businessRegistrationNumber ? _self.businessRegistrationNumber : businessRegistrationNumber // ignore: cast_nullable_to_non_nullable
as String?,taxId: freezed == taxId ? _self.taxId : taxId // ignore: cast_nullable_to_non_nullable
as String?,businessAddress: null == businessAddress ? _self.businessAddress : businessAddress // ignore: cast_nullable_to_non_nullable
as String,contactPhone: null == contactPhone ? _self.contactPhone : contactPhone // ignore: cast_nullable_to_non_nullable
as String,contactEmail: freezed == contactEmail ? _self.contactEmail : contactEmail // ignore: cast_nullable_to_non_nullable
as String?,user: freezed == user ? _self._user : user // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,approvedAt: freezed == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as String?,approvedBy: freezed == approvedBy ? _self.approvedBy : approvedBy // ignore: cast_nullable_to_non_nullable
as int?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,revenueSharePercent: null == revenueSharePercent ? _self.revenueSharePercent : revenueSharePercent // ignore: cast_nullable_to_non_nullable
as double,storeCount: null == storeCount ? _self.storeCount : storeCount // ignore: cast_nullable_to_non_nullable
as int,staffCount: null == staffCount ? _self.staffCount : staffCount // ignore: cast_nullable_to_non_nullable
as int,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$PartnerOrderStatistics {

 int get partnerId; int get totalOrders; int get todayOrders; int get weekOrders; int get monthOrders; int get initializedOrders; int get waitingOrders; int get collectedOrders; int get processingOrders; int get readyOrders; int get returnedOrders; int get completedOrders; int get canceledOrders; double get totalRevenue; double get todayRevenue; double get weekRevenue; double get monthRevenue; double get averageOrderValue; Map<String, int> get ordersByStore;
/// Create a copy of PartnerOrderStatistics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PartnerOrderStatisticsCopyWith<PartnerOrderStatistics> get copyWith => _$PartnerOrderStatisticsCopyWithImpl<PartnerOrderStatistics>(this as PartnerOrderStatistics, _$identity);

  /// Serializes this PartnerOrderStatistics to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PartnerOrderStatistics&&(identical(other.partnerId, partnerId) || other.partnerId == partnerId)&&(identical(other.totalOrders, totalOrders) || other.totalOrders == totalOrders)&&(identical(other.todayOrders, todayOrders) || other.todayOrders == todayOrders)&&(identical(other.weekOrders, weekOrders) || other.weekOrders == weekOrders)&&(identical(other.monthOrders, monthOrders) || other.monthOrders == monthOrders)&&(identical(other.initializedOrders, initializedOrders) || other.initializedOrders == initializedOrders)&&(identical(other.waitingOrders, waitingOrders) || other.waitingOrders == waitingOrders)&&(identical(other.collectedOrders, collectedOrders) || other.collectedOrders == collectedOrders)&&(identical(other.processingOrders, processingOrders) || other.processingOrders == processingOrders)&&(identical(other.readyOrders, readyOrders) || other.readyOrders == readyOrders)&&(identical(other.returnedOrders, returnedOrders) || other.returnedOrders == returnedOrders)&&(identical(other.completedOrders, completedOrders) || other.completedOrders == completedOrders)&&(identical(other.canceledOrders, canceledOrders) || other.canceledOrders == canceledOrders)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.todayRevenue, todayRevenue) || other.todayRevenue == todayRevenue)&&(identical(other.weekRevenue, weekRevenue) || other.weekRevenue == weekRevenue)&&(identical(other.monthRevenue, monthRevenue) || other.monthRevenue == monthRevenue)&&(identical(other.averageOrderValue, averageOrderValue) || other.averageOrderValue == averageOrderValue)&&const DeepCollectionEquality().equals(other.ordersByStore, ordersByStore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,partnerId,totalOrders,todayOrders,weekOrders,monthOrders,initializedOrders,waitingOrders,collectedOrders,processingOrders,readyOrders,returnedOrders,completedOrders,canceledOrders,totalRevenue,todayRevenue,weekRevenue,monthRevenue,averageOrderValue,const DeepCollectionEquality().hash(ordersByStore)]);

@override
String toString() {
  return 'PartnerOrderStatistics(partnerId: $partnerId, totalOrders: $totalOrders, todayOrders: $todayOrders, weekOrders: $weekOrders, monthOrders: $monthOrders, initializedOrders: $initializedOrders, waitingOrders: $waitingOrders, collectedOrders: $collectedOrders, processingOrders: $processingOrders, readyOrders: $readyOrders, returnedOrders: $returnedOrders, completedOrders: $completedOrders, canceledOrders: $canceledOrders, totalRevenue: $totalRevenue, todayRevenue: $todayRevenue, weekRevenue: $weekRevenue, monthRevenue: $monthRevenue, averageOrderValue: $averageOrderValue, ordersByStore: $ordersByStore)';
}


}

/// @nodoc
abstract mixin class $PartnerOrderStatisticsCopyWith<$Res>  {
  factory $PartnerOrderStatisticsCopyWith(PartnerOrderStatistics value, $Res Function(PartnerOrderStatistics) _then) = _$PartnerOrderStatisticsCopyWithImpl;
@useResult
$Res call({
 int partnerId, int totalOrders, int todayOrders, int weekOrders, int monthOrders, int initializedOrders, int waitingOrders, int collectedOrders, int processingOrders, int readyOrders, int returnedOrders, int completedOrders, int canceledOrders, double totalRevenue, double todayRevenue, double weekRevenue, double monthRevenue, double averageOrderValue, Map<String, int> ordersByStore
});




}
/// @nodoc
class _$PartnerOrderStatisticsCopyWithImpl<$Res>
    implements $PartnerOrderStatisticsCopyWith<$Res> {
  _$PartnerOrderStatisticsCopyWithImpl(this._self, this._then);

  final PartnerOrderStatistics _self;
  final $Res Function(PartnerOrderStatistics) _then;

/// Create a copy of PartnerOrderStatistics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? partnerId = null,Object? totalOrders = null,Object? todayOrders = null,Object? weekOrders = null,Object? monthOrders = null,Object? initializedOrders = null,Object? waitingOrders = null,Object? collectedOrders = null,Object? processingOrders = null,Object? readyOrders = null,Object? returnedOrders = null,Object? completedOrders = null,Object? canceledOrders = null,Object? totalRevenue = null,Object? todayRevenue = null,Object? weekRevenue = null,Object? monthRevenue = null,Object? averageOrderValue = null,Object? ordersByStore = null,}) {
  return _then(_self.copyWith(
partnerId: null == partnerId ? _self.partnerId : partnerId // ignore: cast_nullable_to_non_nullable
as int,totalOrders: null == totalOrders ? _self.totalOrders : totalOrders // ignore: cast_nullable_to_non_nullable
as int,todayOrders: null == todayOrders ? _self.todayOrders : todayOrders // ignore: cast_nullable_to_non_nullable
as int,weekOrders: null == weekOrders ? _self.weekOrders : weekOrders // ignore: cast_nullable_to_non_nullable
as int,monthOrders: null == monthOrders ? _self.monthOrders : monthOrders // ignore: cast_nullable_to_non_nullable
as int,initializedOrders: null == initializedOrders ? _self.initializedOrders : initializedOrders // ignore: cast_nullable_to_non_nullable
as int,waitingOrders: null == waitingOrders ? _self.waitingOrders : waitingOrders // ignore: cast_nullable_to_non_nullable
as int,collectedOrders: null == collectedOrders ? _self.collectedOrders : collectedOrders // ignore: cast_nullable_to_non_nullable
as int,processingOrders: null == processingOrders ? _self.processingOrders : processingOrders // ignore: cast_nullable_to_non_nullable
as int,readyOrders: null == readyOrders ? _self.readyOrders : readyOrders // ignore: cast_nullable_to_non_nullable
as int,returnedOrders: null == returnedOrders ? _self.returnedOrders : returnedOrders // ignore: cast_nullable_to_non_nullable
as int,completedOrders: null == completedOrders ? _self.completedOrders : completedOrders // ignore: cast_nullable_to_non_nullable
as int,canceledOrders: null == canceledOrders ? _self.canceledOrders : canceledOrders // ignore: cast_nullable_to_non_nullable
as int,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,todayRevenue: null == todayRevenue ? _self.todayRevenue : todayRevenue // ignore: cast_nullable_to_non_nullable
as double,weekRevenue: null == weekRevenue ? _self.weekRevenue : weekRevenue // ignore: cast_nullable_to_non_nullable
as double,monthRevenue: null == monthRevenue ? _self.monthRevenue : monthRevenue // ignore: cast_nullable_to_non_nullable
as double,averageOrderValue: null == averageOrderValue ? _self.averageOrderValue : averageOrderValue // ignore: cast_nullable_to_non_nullable
as double,ordersByStore: null == ordersByStore ? _self.ordersByStore : ordersByStore // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}

}


/// Adds pattern-matching-related methods to [PartnerOrderStatistics].
extension PartnerOrderStatisticsPatterns on PartnerOrderStatistics {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PartnerOrderStatistics value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PartnerOrderStatistics() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PartnerOrderStatistics value)  $default,){
final _that = this;
switch (_that) {
case _PartnerOrderStatistics():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PartnerOrderStatistics value)?  $default,){
final _that = this;
switch (_that) {
case _PartnerOrderStatistics() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int partnerId,  int totalOrders,  int todayOrders,  int weekOrders,  int monthOrders,  int initializedOrders,  int waitingOrders,  int collectedOrders,  int processingOrders,  int readyOrders,  int returnedOrders,  int completedOrders,  int canceledOrders,  double totalRevenue,  double todayRevenue,  double weekRevenue,  double monthRevenue,  double averageOrderValue,  Map<String, int> ordersByStore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PartnerOrderStatistics() when $default != null:
return $default(_that.partnerId,_that.totalOrders,_that.todayOrders,_that.weekOrders,_that.monthOrders,_that.initializedOrders,_that.waitingOrders,_that.collectedOrders,_that.processingOrders,_that.readyOrders,_that.returnedOrders,_that.completedOrders,_that.canceledOrders,_that.totalRevenue,_that.todayRevenue,_that.weekRevenue,_that.monthRevenue,_that.averageOrderValue,_that.ordersByStore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int partnerId,  int totalOrders,  int todayOrders,  int weekOrders,  int monthOrders,  int initializedOrders,  int waitingOrders,  int collectedOrders,  int processingOrders,  int readyOrders,  int returnedOrders,  int completedOrders,  int canceledOrders,  double totalRevenue,  double todayRevenue,  double weekRevenue,  double monthRevenue,  double averageOrderValue,  Map<String, int> ordersByStore)  $default,) {final _that = this;
switch (_that) {
case _PartnerOrderStatistics():
return $default(_that.partnerId,_that.totalOrders,_that.todayOrders,_that.weekOrders,_that.monthOrders,_that.initializedOrders,_that.waitingOrders,_that.collectedOrders,_that.processingOrders,_that.readyOrders,_that.returnedOrders,_that.completedOrders,_that.canceledOrders,_that.totalRevenue,_that.todayRevenue,_that.weekRevenue,_that.monthRevenue,_that.averageOrderValue,_that.ordersByStore);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int partnerId,  int totalOrders,  int todayOrders,  int weekOrders,  int monthOrders,  int initializedOrders,  int waitingOrders,  int collectedOrders,  int processingOrders,  int readyOrders,  int returnedOrders,  int completedOrders,  int canceledOrders,  double totalRevenue,  double todayRevenue,  double weekRevenue,  double monthRevenue,  double averageOrderValue,  Map<String, int> ordersByStore)?  $default,) {final _that = this;
switch (_that) {
case _PartnerOrderStatistics() when $default != null:
return $default(_that.partnerId,_that.totalOrders,_that.todayOrders,_that.weekOrders,_that.monthOrders,_that.initializedOrders,_that.waitingOrders,_that.collectedOrders,_that.processingOrders,_that.readyOrders,_that.returnedOrders,_that.completedOrders,_that.canceledOrders,_that.totalRevenue,_that.todayRevenue,_that.weekRevenue,_that.monthRevenue,_that.averageOrderValue,_that.ordersByStore);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PartnerOrderStatistics implements PartnerOrderStatistics {
  const _PartnerOrderStatistics({required this.partnerId, required this.totalOrders, required this.todayOrders, required this.weekOrders, required this.monthOrders, required this.initializedOrders, required this.waitingOrders, required this.collectedOrders, required this.processingOrders, required this.readyOrders, required this.returnedOrders, required this.completedOrders, required this.canceledOrders, required this.totalRevenue, required this.todayRevenue, required this.weekRevenue, required this.monthRevenue, required this.averageOrderValue, required final  Map<String, int> ordersByStore}): _ordersByStore = ordersByStore;
  factory _PartnerOrderStatistics.fromJson(Map<String, dynamic> json) => _$PartnerOrderStatisticsFromJson(json);

@override final  int partnerId;
@override final  int totalOrders;
@override final  int todayOrders;
@override final  int weekOrders;
@override final  int monthOrders;
@override final  int initializedOrders;
@override final  int waitingOrders;
@override final  int collectedOrders;
@override final  int processingOrders;
@override final  int readyOrders;
@override final  int returnedOrders;
@override final  int completedOrders;
@override final  int canceledOrders;
@override final  double totalRevenue;
@override final  double todayRevenue;
@override final  double weekRevenue;
@override final  double monthRevenue;
@override final  double averageOrderValue;
 final  Map<String, int> _ordersByStore;
@override Map<String, int> get ordersByStore {
  if (_ordersByStore is EqualUnmodifiableMapView) return _ordersByStore;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_ordersByStore);
}


/// Create a copy of PartnerOrderStatistics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PartnerOrderStatisticsCopyWith<_PartnerOrderStatistics> get copyWith => __$PartnerOrderStatisticsCopyWithImpl<_PartnerOrderStatistics>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PartnerOrderStatisticsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PartnerOrderStatistics&&(identical(other.partnerId, partnerId) || other.partnerId == partnerId)&&(identical(other.totalOrders, totalOrders) || other.totalOrders == totalOrders)&&(identical(other.todayOrders, todayOrders) || other.todayOrders == todayOrders)&&(identical(other.weekOrders, weekOrders) || other.weekOrders == weekOrders)&&(identical(other.monthOrders, monthOrders) || other.monthOrders == monthOrders)&&(identical(other.initializedOrders, initializedOrders) || other.initializedOrders == initializedOrders)&&(identical(other.waitingOrders, waitingOrders) || other.waitingOrders == waitingOrders)&&(identical(other.collectedOrders, collectedOrders) || other.collectedOrders == collectedOrders)&&(identical(other.processingOrders, processingOrders) || other.processingOrders == processingOrders)&&(identical(other.readyOrders, readyOrders) || other.readyOrders == readyOrders)&&(identical(other.returnedOrders, returnedOrders) || other.returnedOrders == returnedOrders)&&(identical(other.completedOrders, completedOrders) || other.completedOrders == completedOrders)&&(identical(other.canceledOrders, canceledOrders) || other.canceledOrders == canceledOrders)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.todayRevenue, todayRevenue) || other.todayRevenue == todayRevenue)&&(identical(other.weekRevenue, weekRevenue) || other.weekRevenue == weekRevenue)&&(identical(other.monthRevenue, monthRevenue) || other.monthRevenue == monthRevenue)&&(identical(other.averageOrderValue, averageOrderValue) || other.averageOrderValue == averageOrderValue)&&const DeepCollectionEquality().equals(other._ordersByStore, _ordersByStore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,partnerId,totalOrders,todayOrders,weekOrders,monthOrders,initializedOrders,waitingOrders,collectedOrders,processingOrders,readyOrders,returnedOrders,completedOrders,canceledOrders,totalRevenue,todayRevenue,weekRevenue,monthRevenue,averageOrderValue,const DeepCollectionEquality().hash(_ordersByStore)]);

@override
String toString() {
  return 'PartnerOrderStatistics(partnerId: $partnerId, totalOrders: $totalOrders, todayOrders: $todayOrders, weekOrders: $weekOrders, monthOrders: $monthOrders, initializedOrders: $initializedOrders, waitingOrders: $waitingOrders, collectedOrders: $collectedOrders, processingOrders: $processingOrders, readyOrders: $readyOrders, returnedOrders: $returnedOrders, completedOrders: $completedOrders, canceledOrders: $canceledOrders, totalRevenue: $totalRevenue, todayRevenue: $todayRevenue, weekRevenue: $weekRevenue, monthRevenue: $monthRevenue, averageOrderValue: $averageOrderValue, ordersByStore: $ordersByStore)';
}


}

/// @nodoc
abstract mixin class _$PartnerOrderStatisticsCopyWith<$Res> implements $PartnerOrderStatisticsCopyWith<$Res> {
  factory _$PartnerOrderStatisticsCopyWith(_PartnerOrderStatistics value, $Res Function(_PartnerOrderStatistics) _then) = __$PartnerOrderStatisticsCopyWithImpl;
@override @useResult
$Res call({
 int partnerId, int totalOrders, int todayOrders, int weekOrders, int monthOrders, int initializedOrders, int waitingOrders, int collectedOrders, int processingOrders, int readyOrders, int returnedOrders, int completedOrders, int canceledOrders, double totalRevenue, double todayRevenue, double weekRevenue, double monthRevenue, double averageOrderValue, Map<String, int> ordersByStore
});




}
/// @nodoc
class __$PartnerOrderStatisticsCopyWithImpl<$Res>
    implements _$PartnerOrderStatisticsCopyWith<$Res> {
  __$PartnerOrderStatisticsCopyWithImpl(this._self, this._then);

  final _PartnerOrderStatistics _self;
  final $Res Function(_PartnerOrderStatistics) _then;

/// Create a copy of PartnerOrderStatistics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? partnerId = null,Object? totalOrders = null,Object? todayOrders = null,Object? weekOrders = null,Object? monthOrders = null,Object? initializedOrders = null,Object? waitingOrders = null,Object? collectedOrders = null,Object? processingOrders = null,Object? readyOrders = null,Object? returnedOrders = null,Object? completedOrders = null,Object? canceledOrders = null,Object? totalRevenue = null,Object? todayRevenue = null,Object? weekRevenue = null,Object? monthRevenue = null,Object? averageOrderValue = null,Object? ordersByStore = null,}) {
  return _then(_PartnerOrderStatistics(
partnerId: null == partnerId ? _self.partnerId : partnerId // ignore: cast_nullable_to_non_nullable
as int,totalOrders: null == totalOrders ? _self.totalOrders : totalOrders // ignore: cast_nullable_to_non_nullable
as int,todayOrders: null == todayOrders ? _self.todayOrders : todayOrders // ignore: cast_nullable_to_non_nullable
as int,weekOrders: null == weekOrders ? _self.weekOrders : weekOrders // ignore: cast_nullable_to_non_nullable
as int,monthOrders: null == monthOrders ? _self.monthOrders : monthOrders // ignore: cast_nullable_to_non_nullable
as int,initializedOrders: null == initializedOrders ? _self.initializedOrders : initializedOrders // ignore: cast_nullable_to_non_nullable
as int,waitingOrders: null == waitingOrders ? _self.waitingOrders : waitingOrders // ignore: cast_nullable_to_non_nullable
as int,collectedOrders: null == collectedOrders ? _self.collectedOrders : collectedOrders // ignore: cast_nullable_to_non_nullable
as int,processingOrders: null == processingOrders ? _self.processingOrders : processingOrders // ignore: cast_nullable_to_non_nullable
as int,readyOrders: null == readyOrders ? _self.readyOrders : readyOrders // ignore: cast_nullable_to_non_nullable
as int,returnedOrders: null == returnedOrders ? _self.returnedOrders : returnedOrders // ignore: cast_nullable_to_non_nullable
as int,completedOrders: null == completedOrders ? _self.completedOrders : completedOrders // ignore: cast_nullable_to_non_nullable
as int,canceledOrders: null == canceledOrders ? _self.canceledOrders : canceledOrders // ignore: cast_nullable_to_non_nullable
as int,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,todayRevenue: null == todayRevenue ? _self.todayRevenue : todayRevenue // ignore: cast_nullable_to_non_nullable
as double,weekRevenue: null == weekRevenue ? _self.weekRevenue : weekRevenue // ignore: cast_nullable_to_non_nullable
as double,monthRevenue: null == monthRevenue ? _self.monthRevenue : monthRevenue // ignore: cast_nullable_to_non_nullable
as double,averageOrderValue: null == averageOrderValue ? _self.averageOrderValue : averageOrderValue // ignore: cast_nullable_to_non_nullable
as double,ordersByStore: null == ordersByStore ? _self._ordersByStore : ordersByStore // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}


}


/// @nodoc
mixin _$StaffOrderSummary {

 int get waitingCount; int get processingCount; int get readyCount; int get collectedCount; List<dynamic> get recentOrders;
/// Create a copy of StaffOrderSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StaffOrderSummaryCopyWith<StaffOrderSummary> get copyWith => _$StaffOrderSummaryCopyWithImpl<StaffOrderSummary>(this as StaffOrderSummary, _$identity);

  /// Serializes this StaffOrderSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StaffOrderSummary&&(identical(other.waitingCount, waitingCount) || other.waitingCount == waitingCount)&&(identical(other.processingCount, processingCount) || other.processingCount == processingCount)&&(identical(other.readyCount, readyCount) || other.readyCount == readyCount)&&(identical(other.collectedCount, collectedCount) || other.collectedCount == collectedCount)&&const DeepCollectionEquality().equals(other.recentOrders, recentOrders));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,waitingCount,processingCount,readyCount,collectedCount,const DeepCollectionEquality().hash(recentOrders));

@override
String toString() {
  return 'StaffOrderSummary(waitingCount: $waitingCount, processingCount: $processingCount, readyCount: $readyCount, collectedCount: $collectedCount, recentOrders: $recentOrders)';
}


}

/// @nodoc
abstract mixin class $StaffOrderSummaryCopyWith<$Res>  {
  factory $StaffOrderSummaryCopyWith(StaffOrderSummary value, $Res Function(StaffOrderSummary) _then) = _$StaffOrderSummaryCopyWithImpl;
@useResult
$Res call({
 int waitingCount, int processingCount, int readyCount, int collectedCount, List<dynamic> recentOrders
});




}
/// @nodoc
class _$StaffOrderSummaryCopyWithImpl<$Res>
    implements $StaffOrderSummaryCopyWith<$Res> {
  _$StaffOrderSummaryCopyWithImpl(this._self, this._then);

  final StaffOrderSummary _self;
  final $Res Function(StaffOrderSummary) _then;

/// Create a copy of StaffOrderSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? waitingCount = null,Object? processingCount = null,Object? readyCount = null,Object? collectedCount = null,Object? recentOrders = null,}) {
  return _then(_self.copyWith(
waitingCount: null == waitingCount ? _self.waitingCount : waitingCount // ignore: cast_nullable_to_non_nullable
as int,processingCount: null == processingCount ? _self.processingCount : processingCount // ignore: cast_nullable_to_non_nullable
as int,readyCount: null == readyCount ? _self.readyCount : readyCount // ignore: cast_nullable_to_non_nullable
as int,collectedCount: null == collectedCount ? _self.collectedCount : collectedCount // ignore: cast_nullable_to_non_nullable
as int,recentOrders: null == recentOrders ? _self.recentOrders : recentOrders // ignore: cast_nullable_to_non_nullable
as List<dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [StaffOrderSummary].
extension StaffOrderSummaryPatterns on StaffOrderSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StaffOrderSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StaffOrderSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StaffOrderSummary value)  $default,){
final _that = this;
switch (_that) {
case _StaffOrderSummary():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StaffOrderSummary value)?  $default,){
final _that = this;
switch (_that) {
case _StaffOrderSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int waitingCount,  int processingCount,  int readyCount,  int collectedCount,  List<dynamic> recentOrders)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StaffOrderSummary() when $default != null:
return $default(_that.waitingCount,_that.processingCount,_that.readyCount,_that.collectedCount,_that.recentOrders);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int waitingCount,  int processingCount,  int readyCount,  int collectedCount,  List<dynamic> recentOrders)  $default,) {final _that = this;
switch (_that) {
case _StaffOrderSummary():
return $default(_that.waitingCount,_that.processingCount,_that.readyCount,_that.collectedCount,_that.recentOrders);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int waitingCount,  int processingCount,  int readyCount,  int collectedCount,  List<dynamic> recentOrders)?  $default,) {final _that = this;
switch (_that) {
case _StaffOrderSummary() when $default != null:
return $default(_that.waitingCount,_that.processingCount,_that.readyCount,_that.collectedCount,_that.recentOrders);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StaffOrderSummary implements StaffOrderSummary {
  const _StaffOrderSummary({required this.waitingCount, required this.processingCount, required this.readyCount, required this.collectedCount, required final  List<dynamic> recentOrders}): _recentOrders = recentOrders;
  factory _StaffOrderSummary.fromJson(Map<String, dynamic> json) => _$StaffOrderSummaryFromJson(json);

@override final  int waitingCount;
@override final  int processingCount;
@override final  int readyCount;
@override final  int collectedCount;
 final  List<dynamic> _recentOrders;
@override List<dynamic> get recentOrders {
  if (_recentOrders is EqualUnmodifiableListView) return _recentOrders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentOrders);
}


/// Create a copy of StaffOrderSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StaffOrderSummaryCopyWith<_StaffOrderSummary> get copyWith => __$StaffOrderSummaryCopyWithImpl<_StaffOrderSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StaffOrderSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StaffOrderSummary&&(identical(other.waitingCount, waitingCount) || other.waitingCount == waitingCount)&&(identical(other.processingCount, processingCount) || other.processingCount == processingCount)&&(identical(other.readyCount, readyCount) || other.readyCount == readyCount)&&(identical(other.collectedCount, collectedCount) || other.collectedCount == collectedCount)&&const DeepCollectionEquality().equals(other._recentOrders, _recentOrders));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,waitingCount,processingCount,readyCount,collectedCount,const DeepCollectionEquality().hash(_recentOrders));

@override
String toString() {
  return 'StaffOrderSummary(waitingCount: $waitingCount, processingCount: $processingCount, readyCount: $readyCount, collectedCount: $collectedCount, recentOrders: $recentOrders)';
}


}

/// @nodoc
abstract mixin class _$StaffOrderSummaryCopyWith<$Res> implements $StaffOrderSummaryCopyWith<$Res> {
  factory _$StaffOrderSummaryCopyWith(_StaffOrderSummary value, $Res Function(_StaffOrderSummary) _then) = __$StaffOrderSummaryCopyWithImpl;
@override @useResult
$Res call({
 int waitingCount, int processingCount, int readyCount, int collectedCount, List<dynamic> recentOrders
});




}
/// @nodoc
class __$StaffOrderSummaryCopyWithImpl<$Res>
    implements _$StaffOrderSummaryCopyWith<$Res> {
  __$StaffOrderSummaryCopyWithImpl(this._self, this._then);

  final _StaffOrderSummary _self;
  final $Res Function(_StaffOrderSummary) _then;

/// Create a copy of StaffOrderSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? waitingCount = null,Object? processingCount = null,Object? readyCount = null,Object? collectedCount = null,Object? recentOrders = null,}) {
  return _then(_StaffOrderSummary(
waitingCount: null == waitingCount ? _self.waitingCount : waitingCount // ignore: cast_nullable_to_non_nullable
as int,processingCount: null == processingCount ? _self.processingCount : processingCount // ignore: cast_nullable_to_non_nullable
as int,readyCount: null == readyCount ? _self.readyCount : readyCount // ignore: cast_nullable_to_non_nullable
as int,collectedCount: null == collectedCount ? _self.collectedCount : collectedCount // ignore: cast_nullable_to_non_nullable
as int,recentOrders: null == recentOrders ? _self._recentOrders : recentOrders // ignore: cast_nullable_to_non_nullable
as List<dynamic>,
  ));
}


}

// dart format on

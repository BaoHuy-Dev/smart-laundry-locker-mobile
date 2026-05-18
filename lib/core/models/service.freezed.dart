// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'service.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LaundryService {

 int get id; int? get storeId; String get name; String? get description; ServiceCategory? get category; ServiceType? get serviceType; double get price; double? get pricePerUnit; double? get maxPrice; String get unit; int? get estimatedTime; int? get estimatedHours; bool get isAddon; bool get isMonthlyPackage; String? get image; String? get imageUrl; bool get isActive; String? get createdAt; String? get updatedAt;
/// Create a copy of LaundryService
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LaundryServiceCopyWith<LaundryService> get copyWith => _$LaundryServiceCopyWithImpl<LaundryService>(this as LaundryService, _$identity);

  /// Serializes this LaundryService to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LaundryService&&(identical(other.id, id) || other.id == id)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.serviceType, serviceType) || other.serviceType == serviceType)&&(identical(other.price, price) || other.price == price)&&(identical(other.pricePerUnit, pricePerUnit) || other.pricePerUnit == pricePerUnit)&&(identical(other.maxPrice, maxPrice) || other.maxPrice == maxPrice)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.estimatedTime, estimatedTime) || other.estimatedTime == estimatedTime)&&(identical(other.estimatedHours, estimatedHours) || other.estimatedHours == estimatedHours)&&(identical(other.isAddon, isAddon) || other.isAddon == isAddon)&&(identical(other.isMonthlyPackage, isMonthlyPackage) || other.isMonthlyPackage == isMonthlyPackage)&&(identical(other.image, image) || other.image == image)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,storeId,name,description,category,serviceType,price,pricePerUnit,maxPrice,unit,estimatedTime,estimatedHours,isAddon,isMonthlyPackage,image,imageUrl,isActive,createdAt,updatedAt]);

@override
String toString() {
  return 'LaundryService(id: $id, storeId: $storeId, name: $name, description: $description, category: $category, serviceType: $serviceType, price: $price, pricePerUnit: $pricePerUnit, maxPrice: $maxPrice, unit: $unit, estimatedTime: $estimatedTime, estimatedHours: $estimatedHours, isAddon: $isAddon, isMonthlyPackage: $isMonthlyPackage, image: $image, imageUrl: $imageUrl, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $LaundryServiceCopyWith<$Res>  {
  factory $LaundryServiceCopyWith(LaundryService value, $Res Function(LaundryService) _then) = _$LaundryServiceCopyWithImpl;
@useResult
$Res call({
 int id, int? storeId, String name, String? description, ServiceCategory? category, ServiceType? serviceType, double price, double? pricePerUnit, double? maxPrice, String unit, int? estimatedTime, int? estimatedHours, bool isAddon, bool isMonthlyPackage, String? image, String? imageUrl, bool isActive, String? createdAt, String? updatedAt
});




}
/// @nodoc
class _$LaundryServiceCopyWithImpl<$Res>
    implements $LaundryServiceCopyWith<$Res> {
  _$LaundryServiceCopyWithImpl(this._self, this._then);

  final LaundryService _self;
  final $Res Function(LaundryService) _then;

/// Create a copy of LaundryService
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? storeId = freezed,Object? name = null,Object? description = freezed,Object? category = freezed,Object? serviceType = freezed,Object? price = null,Object? pricePerUnit = freezed,Object? maxPrice = freezed,Object? unit = null,Object? estimatedTime = freezed,Object? estimatedHours = freezed,Object? isAddon = null,Object? isMonthlyPackage = null,Object? image = freezed,Object? imageUrl = freezed,Object? isActive = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,storeId: freezed == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ServiceCategory?,serviceType: freezed == serviceType ? _self.serviceType : serviceType // ignore: cast_nullable_to_non_nullable
as ServiceType?,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,pricePerUnit: freezed == pricePerUnit ? _self.pricePerUnit : pricePerUnit // ignore: cast_nullable_to_non_nullable
as double?,maxPrice: freezed == maxPrice ? _self.maxPrice : maxPrice // ignore: cast_nullable_to_non_nullable
as double?,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,estimatedTime: freezed == estimatedTime ? _self.estimatedTime : estimatedTime // ignore: cast_nullable_to_non_nullable
as int?,estimatedHours: freezed == estimatedHours ? _self.estimatedHours : estimatedHours // ignore: cast_nullable_to_non_nullable
as int?,isAddon: null == isAddon ? _self.isAddon : isAddon // ignore: cast_nullable_to_non_nullable
as bool,isMonthlyPackage: null == isMonthlyPackage ? _self.isMonthlyPackage : isMonthlyPackage // ignore: cast_nullable_to_non_nullable
as bool,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LaundryService].
extension LaundryServicePatterns on LaundryService {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LaundryService value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LaundryService() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LaundryService value)  $default,){
final _that = this;
switch (_that) {
case _LaundryService():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LaundryService value)?  $default,){
final _that = this;
switch (_that) {
case _LaundryService() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int? storeId,  String name,  String? description,  ServiceCategory? category,  ServiceType? serviceType,  double price,  double? pricePerUnit,  double? maxPrice,  String unit,  int? estimatedTime,  int? estimatedHours,  bool isAddon,  bool isMonthlyPackage,  String? image,  String? imageUrl,  bool isActive,  String? createdAt,  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LaundryService() when $default != null:
return $default(_that.id,_that.storeId,_that.name,_that.description,_that.category,_that.serviceType,_that.price,_that.pricePerUnit,_that.maxPrice,_that.unit,_that.estimatedTime,_that.estimatedHours,_that.isAddon,_that.isMonthlyPackage,_that.image,_that.imageUrl,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int? storeId,  String name,  String? description,  ServiceCategory? category,  ServiceType? serviceType,  double price,  double? pricePerUnit,  double? maxPrice,  String unit,  int? estimatedTime,  int? estimatedHours,  bool isAddon,  bool isMonthlyPackage,  String? image,  String? imageUrl,  bool isActive,  String? createdAt,  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _LaundryService():
return $default(_that.id,_that.storeId,_that.name,_that.description,_that.category,_that.serviceType,_that.price,_that.pricePerUnit,_that.maxPrice,_that.unit,_that.estimatedTime,_that.estimatedHours,_that.isAddon,_that.isMonthlyPackage,_that.image,_that.imageUrl,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int? storeId,  String name,  String? description,  ServiceCategory? category,  ServiceType? serviceType,  double price,  double? pricePerUnit,  double? maxPrice,  String unit,  int? estimatedTime,  int? estimatedHours,  bool isAddon,  bool isMonthlyPackage,  String? image,  String? imageUrl,  bool isActive,  String? createdAt,  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _LaundryService() when $default != null:
return $default(_that.id,_that.storeId,_that.name,_that.description,_that.category,_that.serviceType,_that.price,_that.pricePerUnit,_that.maxPrice,_that.unit,_that.estimatedTime,_that.estimatedHours,_that.isAddon,_that.isMonthlyPackage,_that.image,_that.imageUrl,_that.isActive,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LaundryService implements LaundryService {
  const _LaundryService({required this.id, this.storeId, required this.name, this.description, this.category, this.serviceType, required this.price, this.pricePerUnit, this.maxPrice, required this.unit, this.estimatedTime, this.estimatedHours, this.isAddon = false, this.isMonthlyPackage = false, this.image, this.imageUrl, this.isActive = true, this.createdAt, this.updatedAt});
  factory _LaundryService.fromJson(Map<String, dynamic> json) => _$LaundryServiceFromJson(json);

@override final  int id;
@override final  int? storeId;
@override final  String name;
@override final  String? description;
@override final  ServiceCategory? category;
@override final  ServiceType? serviceType;
@override final  double price;
@override final  double? pricePerUnit;
@override final  double? maxPrice;
@override final  String unit;
@override final  int? estimatedTime;
@override final  int? estimatedHours;
@override@JsonKey() final  bool isAddon;
@override@JsonKey() final  bool isMonthlyPackage;
@override final  String? image;
@override final  String? imageUrl;
@override@JsonKey() final  bool isActive;
@override final  String? createdAt;
@override final  String? updatedAt;

/// Create a copy of LaundryService
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LaundryServiceCopyWith<_LaundryService> get copyWith => __$LaundryServiceCopyWithImpl<_LaundryService>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LaundryServiceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LaundryService&&(identical(other.id, id) || other.id == id)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.serviceType, serviceType) || other.serviceType == serviceType)&&(identical(other.price, price) || other.price == price)&&(identical(other.pricePerUnit, pricePerUnit) || other.pricePerUnit == pricePerUnit)&&(identical(other.maxPrice, maxPrice) || other.maxPrice == maxPrice)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.estimatedTime, estimatedTime) || other.estimatedTime == estimatedTime)&&(identical(other.estimatedHours, estimatedHours) || other.estimatedHours == estimatedHours)&&(identical(other.isAddon, isAddon) || other.isAddon == isAddon)&&(identical(other.isMonthlyPackage, isMonthlyPackage) || other.isMonthlyPackage == isMonthlyPackage)&&(identical(other.image, image) || other.image == image)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,storeId,name,description,category,serviceType,price,pricePerUnit,maxPrice,unit,estimatedTime,estimatedHours,isAddon,isMonthlyPackage,image,imageUrl,isActive,createdAt,updatedAt]);

@override
String toString() {
  return 'LaundryService(id: $id, storeId: $storeId, name: $name, description: $description, category: $category, serviceType: $serviceType, price: $price, pricePerUnit: $pricePerUnit, maxPrice: $maxPrice, unit: $unit, estimatedTime: $estimatedTime, estimatedHours: $estimatedHours, isAddon: $isAddon, isMonthlyPackage: $isMonthlyPackage, image: $image, imageUrl: $imageUrl, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$LaundryServiceCopyWith<$Res> implements $LaundryServiceCopyWith<$Res> {
  factory _$LaundryServiceCopyWith(_LaundryService value, $Res Function(_LaundryService) _then) = __$LaundryServiceCopyWithImpl;
@override @useResult
$Res call({
 int id, int? storeId, String name, String? description, ServiceCategory? category, ServiceType? serviceType, double price, double? pricePerUnit, double? maxPrice, String unit, int? estimatedTime, int? estimatedHours, bool isAddon, bool isMonthlyPackage, String? image, String? imageUrl, bool isActive, String? createdAt, String? updatedAt
});




}
/// @nodoc
class __$LaundryServiceCopyWithImpl<$Res>
    implements _$LaundryServiceCopyWith<$Res> {
  __$LaundryServiceCopyWithImpl(this._self, this._then);

  final _LaundryService _self;
  final $Res Function(_LaundryService) _then;

/// Create a copy of LaundryService
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? storeId = freezed,Object? name = null,Object? description = freezed,Object? category = freezed,Object? serviceType = freezed,Object? price = null,Object? pricePerUnit = freezed,Object? maxPrice = freezed,Object? unit = null,Object? estimatedTime = freezed,Object? estimatedHours = freezed,Object? isAddon = null,Object? isMonthlyPackage = null,Object? image = freezed,Object? imageUrl = freezed,Object? isActive = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_LaundryService(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,storeId: freezed == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ServiceCategory?,serviceType: freezed == serviceType ? _self.serviceType : serviceType // ignore: cast_nullable_to_non_nullable
as ServiceType?,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,pricePerUnit: freezed == pricePerUnit ? _self.pricePerUnit : pricePerUnit // ignore: cast_nullable_to_non_nullable
as double?,maxPrice: freezed == maxPrice ? _self.maxPrice : maxPrice // ignore: cast_nullable_to_non_nullable
as double?,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,estimatedTime: freezed == estimatedTime ? _self.estimatedTime : estimatedTime // ignore: cast_nullable_to_non_nullable
as int?,estimatedHours: freezed == estimatedHours ? _self.estimatedHours : estimatedHours // ignore: cast_nullable_to_non_nullable
as int?,isAddon: null == isAddon ? _self.isAddon : isAddon // ignore: cast_nullable_to_non_nullable
as bool,isMonthlyPackage: null == isMonthlyPackage ? _self.isMonthlyPackage : isMonthlyPackage // ignore: cast_nullable_to_non_nullable
as bool,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PromotionInfo {

 String get code; String get title; String get discountType;// 'PERCENTAGE', 'FIXED_AMOUNT', 'FREE_SERVICE'
 double get discountValue; double? get maxDiscountAmount; double get calculatedDiscount; bool get applied; String? get message;
/// Create a copy of PromotionInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PromotionInfoCopyWith<PromotionInfo> get copyWith => _$PromotionInfoCopyWithImpl<PromotionInfo>(this as PromotionInfo, _$identity);

  /// Serializes this PromotionInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PromotionInfo&&(identical(other.code, code) || other.code == code)&&(identical(other.title, title) || other.title == title)&&(identical(other.discountType, discountType) || other.discountType == discountType)&&(identical(other.discountValue, discountValue) || other.discountValue == discountValue)&&(identical(other.maxDiscountAmount, maxDiscountAmount) || other.maxDiscountAmount == maxDiscountAmount)&&(identical(other.calculatedDiscount, calculatedDiscount) || other.calculatedDiscount == calculatedDiscount)&&(identical(other.applied, applied) || other.applied == applied)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,title,discountType,discountValue,maxDiscountAmount,calculatedDiscount,applied,message);

@override
String toString() {
  return 'PromotionInfo(code: $code, title: $title, discountType: $discountType, discountValue: $discountValue, maxDiscountAmount: $maxDiscountAmount, calculatedDiscount: $calculatedDiscount, applied: $applied, message: $message)';
}


}

/// @nodoc
abstract mixin class $PromotionInfoCopyWith<$Res>  {
  factory $PromotionInfoCopyWith(PromotionInfo value, $Res Function(PromotionInfo) _then) = _$PromotionInfoCopyWithImpl;
@useResult
$Res call({
 String code, String title, String discountType, double discountValue, double? maxDiscountAmount, double calculatedDiscount, bool applied, String? message
});




}
/// @nodoc
class _$PromotionInfoCopyWithImpl<$Res>
    implements $PromotionInfoCopyWith<$Res> {
  _$PromotionInfoCopyWithImpl(this._self, this._then);

  final PromotionInfo _self;
  final $Res Function(PromotionInfo) _then;

/// Create a copy of PromotionInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? title = null,Object? discountType = null,Object? discountValue = null,Object? maxDiscountAmount = freezed,Object? calculatedDiscount = null,Object? applied = null,Object? message = freezed,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,discountType: null == discountType ? _self.discountType : discountType // ignore: cast_nullable_to_non_nullable
as String,discountValue: null == discountValue ? _self.discountValue : discountValue // ignore: cast_nullable_to_non_nullable
as double,maxDiscountAmount: freezed == maxDiscountAmount ? _self.maxDiscountAmount : maxDiscountAmount // ignore: cast_nullable_to_non_nullable
as double?,calculatedDiscount: null == calculatedDiscount ? _self.calculatedDiscount : calculatedDiscount // ignore: cast_nullable_to_non_nullable
as double,applied: null == applied ? _self.applied : applied // ignore: cast_nullable_to_non_nullable
as bool,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PromotionInfo].
extension PromotionInfoPatterns on PromotionInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PromotionInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PromotionInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PromotionInfo value)  $default,){
final _that = this;
switch (_that) {
case _PromotionInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PromotionInfo value)?  $default,){
final _that = this;
switch (_that) {
case _PromotionInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String title,  String discountType,  double discountValue,  double? maxDiscountAmount,  double calculatedDiscount,  bool applied,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PromotionInfo() when $default != null:
return $default(_that.code,_that.title,_that.discountType,_that.discountValue,_that.maxDiscountAmount,_that.calculatedDiscount,_that.applied,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String title,  String discountType,  double discountValue,  double? maxDiscountAmount,  double calculatedDiscount,  bool applied,  String? message)  $default,) {final _that = this;
switch (_that) {
case _PromotionInfo():
return $default(_that.code,_that.title,_that.discountType,_that.discountValue,_that.maxDiscountAmount,_that.calculatedDiscount,_that.applied,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String title,  String discountType,  double discountValue,  double? maxDiscountAmount,  double calculatedDiscount,  bool applied,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _PromotionInfo() when $default != null:
return $default(_that.code,_that.title,_that.discountType,_that.discountValue,_that.maxDiscountAmount,_that.calculatedDiscount,_that.applied,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PromotionInfo implements PromotionInfo {
  const _PromotionInfo({required this.code, required this.title, required this.discountType, required this.discountValue, this.maxDiscountAmount, required this.calculatedDiscount, required this.applied, this.message});
  factory _PromotionInfo.fromJson(Map<String, dynamic> json) => _$PromotionInfoFromJson(json);

@override final  String code;
@override final  String title;
@override final  String discountType;
// 'PERCENTAGE', 'FIXED_AMOUNT', 'FREE_SERVICE'
@override final  double discountValue;
@override final  double? maxDiscountAmount;
@override final  double calculatedDiscount;
@override final  bool applied;
@override final  String? message;

/// Create a copy of PromotionInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PromotionInfoCopyWith<_PromotionInfo> get copyWith => __$PromotionInfoCopyWithImpl<_PromotionInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PromotionInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PromotionInfo&&(identical(other.code, code) || other.code == code)&&(identical(other.title, title) || other.title == title)&&(identical(other.discountType, discountType) || other.discountType == discountType)&&(identical(other.discountValue, discountValue) || other.discountValue == discountValue)&&(identical(other.maxDiscountAmount, maxDiscountAmount) || other.maxDiscountAmount == maxDiscountAmount)&&(identical(other.calculatedDiscount, calculatedDiscount) || other.calculatedDiscount == calculatedDiscount)&&(identical(other.applied, applied) || other.applied == applied)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,title,discountType,discountValue,maxDiscountAmount,calculatedDiscount,applied,message);

@override
String toString() {
  return 'PromotionInfo(code: $code, title: $title, discountType: $discountType, discountValue: $discountValue, maxDiscountAmount: $maxDiscountAmount, calculatedDiscount: $calculatedDiscount, applied: $applied, message: $message)';
}


}

/// @nodoc
abstract mixin class _$PromotionInfoCopyWith<$Res> implements $PromotionInfoCopyWith<$Res> {
  factory _$PromotionInfoCopyWith(_PromotionInfo value, $Res Function(_PromotionInfo) _then) = __$PromotionInfoCopyWithImpl;
@override @useResult
$Res call({
 String code, String title, String discountType, double discountValue, double? maxDiscountAmount, double calculatedDiscount, bool applied, String? message
});




}
/// @nodoc
class __$PromotionInfoCopyWithImpl<$Res>
    implements _$PromotionInfoCopyWith<$Res> {
  __$PromotionInfoCopyWithImpl(this._self, this._then);

  final _PromotionInfo _self;
  final $Res Function(_PromotionInfo) _then;

/// Create a copy of PromotionInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? title = null,Object? discountType = null,Object? discountValue = null,Object? maxDiscountAmount = freezed,Object? calculatedDiscount = null,Object? applied = null,Object? message = freezed,}) {
  return _then(_PromotionInfo(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,discountType: null == discountType ? _self.discountType : discountType // ignore: cast_nullable_to_non_nullable
as String,discountValue: null == discountValue ? _self.discountValue : discountValue // ignore: cast_nullable_to_non_nullable
as double,maxDiscountAmount: freezed == maxDiscountAmount ? _self.maxDiscountAmount : maxDiscountAmount // ignore: cast_nullable_to_non_nullable
as double?,calculatedDiscount: null == calculatedDiscount ? _self.calculatedDiscount : calculatedDiscount // ignore: cast_nullable_to_non_nullable
as double,applied: null == applied ? _self.applied : applied // ignore: cast_nullable_to_non_nullable
as bool,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PriceBreakdown {

 double get basePrice; double? get storageFee; double? get overtimeFee; double? get shippingFee; double? get originalPrice; String? get promotionCode; double? get promotionDiscount; double? get discount; double? get finalPrice; List<PromotionInfo>? get appliedPromotions; String? get note;
/// Create a copy of PriceBreakdown
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PriceBreakdownCopyWith<PriceBreakdown> get copyWith => _$PriceBreakdownCopyWithImpl<PriceBreakdown>(this as PriceBreakdown, _$identity);

  /// Serializes this PriceBreakdown to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PriceBreakdown&&(identical(other.basePrice, basePrice) || other.basePrice == basePrice)&&(identical(other.storageFee, storageFee) || other.storageFee == storageFee)&&(identical(other.overtimeFee, overtimeFee) || other.overtimeFee == overtimeFee)&&(identical(other.shippingFee, shippingFee) || other.shippingFee == shippingFee)&&(identical(other.originalPrice, originalPrice) || other.originalPrice == originalPrice)&&(identical(other.promotionCode, promotionCode) || other.promotionCode == promotionCode)&&(identical(other.promotionDiscount, promotionDiscount) || other.promotionDiscount == promotionDiscount)&&(identical(other.discount, discount) || other.discount == discount)&&(identical(other.finalPrice, finalPrice) || other.finalPrice == finalPrice)&&const DeepCollectionEquality().equals(other.appliedPromotions, appliedPromotions)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,basePrice,storageFee,overtimeFee,shippingFee,originalPrice,promotionCode,promotionDiscount,discount,finalPrice,const DeepCollectionEquality().hash(appliedPromotions),note);

@override
String toString() {
  return 'PriceBreakdown(basePrice: $basePrice, storageFee: $storageFee, overtimeFee: $overtimeFee, shippingFee: $shippingFee, originalPrice: $originalPrice, promotionCode: $promotionCode, promotionDiscount: $promotionDiscount, discount: $discount, finalPrice: $finalPrice, appliedPromotions: $appliedPromotions, note: $note)';
}


}

/// @nodoc
abstract mixin class $PriceBreakdownCopyWith<$Res>  {
  factory $PriceBreakdownCopyWith(PriceBreakdown value, $Res Function(PriceBreakdown) _then) = _$PriceBreakdownCopyWithImpl;
@useResult
$Res call({
 double basePrice, double? storageFee, double? overtimeFee, double? shippingFee, double? originalPrice, String? promotionCode, double? promotionDiscount, double? discount, double? finalPrice, List<PromotionInfo>? appliedPromotions, String? note
});




}
/// @nodoc
class _$PriceBreakdownCopyWithImpl<$Res>
    implements $PriceBreakdownCopyWith<$Res> {
  _$PriceBreakdownCopyWithImpl(this._self, this._then);

  final PriceBreakdown _self;
  final $Res Function(PriceBreakdown) _then;

/// Create a copy of PriceBreakdown
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? basePrice = null,Object? storageFee = freezed,Object? overtimeFee = freezed,Object? shippingFee = freezed,Object? originalPrice = freezed,Object? promotionCode = freezed,Object? promotionDiscount = freezed,Object? discount = freezed,Object? finalPrice = freezed,Object? appliedPromotions = freezed,Object? note = freezed,}) {
  return _then(_self.copyWith(
basePrice: null == basePrice ? _self.basePrice : basePrice // ignore: cast_nullable_to_non_nullable
as double,storageFee: freezed == storageFee ? _self.storageFee : storageFee // ignore: cast_nullable_to_non_nullable
as double?,overtimeFee: freezed == overtimeFee ? _self.overtimeFee : overtimeFee // ignore: cast_nullable_to_non_nullable
as double?,shippingFee: freezed == shippingFee ? _self.shippingFee : shippingFee // ignore: cast_nullable_to_non_nullable
as double?,originalPrice: freezed == originalPrice ? _self.originalPrice : originalPrice // ignore: cast_nullable_to_non_nullable
as double?,promotionCode: freezed == promotionCode ? _self.promotionCode : promotionCode // ignore: cast_nullable_to_non_nullable
as String?,promotionDiscount: freezed == promotionDiscount ? _self.promotionDiscount : promotionDiscount // ignore: cast_nullable_to_non_nullable
as double?,discount: freezed == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as double?,finalPrice: freezed == finalPrice ? _self.finalPrice : finalPrice // ignore: cast_nullable_to_non_nullable
as double?,appliedPromotions: freezed == appliedPromotions ? _self.appliedPromotions : appliedPromotions // ignore: cast_nullable_to_non_nullable
as List<PromotionInfo>?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PriceBreakdown].
extension PriceBreakdownPatterns on PriceBreakdown {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PriceBreakdown value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PriceBreakdown() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PriceBreakdown value)  $default,){
final _that = this;
switch (_that) {
case _PriceBreakdown():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PriceBreakdown value)?  $default,){
final _that = this;
switch (_that) {
case _PriceBreakdown() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double basePrice,  double? storageFee,  double? overtimeFee,  double? shippingFee,  double? originalPrice,  String? promotionCode,  double? promotionDiscount,  double? discount,  double? finalPrice,  List<PromotionInfo>? appliedPromotions,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PriceBreakdown() when $default != null:
return $default(_that.basePrice,_that.storageFee,_that.overtimeFee,_that.shippingFee,_that.originalPrice,_that.promotionCode,_that.promotionDiscount,_that.discount,_that.finalPrice,_that.appliedPromotions,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double basePrice,  double? storageFee,  double? overtimeFee,  double? shippingFee,  double? originalPrice,  String? promotionCode,  double? promotionDiscount,  double? discount,  double? finalPrice,  List<PromotionInfo>? appliedPromotions,  String? note)  $default,) {final _that = this;
switch (_that) {
case _PriceBreakdown():
return $default(_that.basePrice,_that.storageFee,_that.overtimeFee,_that.shippingFee,_that.originalPrice,_that.promotionCode,_that.promotionDiscount,_that.discount,_that.finalPrice,_that.appliedPromotions,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double basePrice,  double? storageFee,  double? overtimeFee,  double? shippingFee,  double? originalPrice,  String? promotionCode,  double? promotionDiscount,  double? discount,  double? finalPrice,  List<PromotionInfo>? appliedPromotions,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _PriceBreakdown() when $default != null:
return $default(_that.basePrice,_that.storageFee,_that.overtimeFee,_that.shippingFee,_that.originalPrice,_that.promotionCode,_that.promotionDiscount,_that.discount,_that.finalPrice,_that.appliedPromotions,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PriceBreakdown implements PriceBreakdown {
  const _PriceBreakdown({required this.basePrice, this.storageFee, this.overtimeFee, this.shippingFee, this.originalPrice, this.promotionCode, this.promotionDiscount, this.discount, this.finalPrice, final  List<PromotionInfo>? appliedPromotions, this.note}): _appliedPromotions = appliedPromotions;
  factory _PriceBreakdown.fromJson(Map<String, dynamic> json) => _$PriceBreakdownFromJson(json);

@override final  double basePrice;
@override final  double? storageFee;
@override final  double? overtimeFee;
@override final  double? shippingFee;
@override final  double? originalPrice;
@override final  String? promotionCode;
@override final  double? promotionDiscount;
@override final  double? discount;
@override final  double? finalPrice;
 final  List<PromotionInfo>? _appliedPromotions;
@override List<PromotionInfo>? get appliedPromotions {
  final value = _appliedPromotions;
  if (value == null) return null;
  if (_appliedPromotions is EqualUnmodifiableListView) return _appliedPromotions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? note;

/// Create a copy of PriceBreakdown
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PriceBreakdownCopyWith<_PriceBreakdown> get copyWith => __$PriceBreakdownCopyWithImpl<_PriceBreakdown>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PriceBreakdownToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PriceBreakdown&&(identical(other.basePrice, basePrice) || other.basePrice == basePrice)&&(identical(other.storageFee, storageFee) || other.storageFee == storageFee)&&(identical(other.overtimeFee, overtimeFee) || other.overtimeFee == overtimeFee)&&(identical(other.shippingFee, shippingFee) || other.shippingFee == shippingFee)&&(identical(other.originalPrice, originalPrice) || other.originalPrice == originalPrice)&&(identical(other.promotionCode, promotionCode) || other.promotionCode == promotionCode)&&(identical(other.promotionDiscount, promotionDiscount) || other.promotionDiscount == promotionDiscount)&&(identical(other.discount, discount) || other.discount == discount)&&(identical(other.finalPrice, finalPrice) || other.finalPrice == finalPrice)&&const DeepCollectionEquality().equals(other._appliedPromotions, _appliedPromotions)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,basePrice,storageFee,overtimeFee,shippingFee,originalPrice,promotionCode,promotionDiscount,discount,finalPrice,const DeepCollectionEquality().hash(_appliedPromotions),note);

@override
String toString() {
  return 'PriceBreakdown(basePrice: $basePrice, storageFee: $storageFee, overtimeFee: $overtimeFee, shippingFee: $shippingFee, originalPrice: $originalPrice, promotionCode: $promotionCode, promotionDiscount: $promotionDiscount, discount: $discount, finalPrice: $finalPrice, appliedPromotions: $appliedPromotions, note: $note)';
}


}

/// @nodoc
abstract mixin class _$PriceBreakdownCopyWith<$Res> implements $PriceBreakdownCopyWith<$Res> {
  factory _$PriceBreakdownCopyWith(_PriceBreakdown value, $Res Function(_PriceBreakdown) _then) = __$PriceBreakdownCopyWithImpl;
@override @useResult
$Res call({
 double basePrice, double? storageFee, double? overtimeFee, double? shippingFee, double? originalPrice, String? promotionCode, double? promotionDiscount, double? discount, double? finalPrice, List<PromotionInfo>? appliedPromotions, String? note
});




}
/// @nodoc
class __$PriceBreakdownCopyWithImpl<$Res>
    implements _$PriceBreakdownCopyWith<$Res> {
  __$PriceBreakdownCopyWithImpl(this._self, this._then);

  final _PriceBreakdown _self;
  final $Res Function(_PriceBreakdown) _then;

/// Create a copy of PriceBreakdown
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? basePrice = null,Object? storageFee = freezed,Object? overtimeFee = freezed,Object? shippingFee = freezed,Object? originalPrice = freezed,Object? promotionCode = freezed,Object? promotionDiscount = freezed,Object? discount = freezed,Object? finalPrice = freezed,Object? appliedPromotions = freezed,Object? note = freezed,}) {
  return _then(_PriceBreakdown(
basePrice: null == basePrice ? _self.basePrice : basePrice // ignore: cast_nullable_to_non_nullable
as double,storageFee: freezed == storageFee ? _self.storageFee : storageFee // ignore: cast_nullable_to_non_nullable
as double?,overtimeFee: freezed == overtimeFee ? _self.overtimeFee : overtimeFee // ignore: cast_nullable_to_non_nullable
as double?,shippingFee: freezed == shippingFee ? _self.shippingFee : shippingFee // ignore: cast_nullable_to_non_nullable
as double?,originalPrice: freezed == originalPrice ? _self.originalPrice : originalPrice // ignore: cast_nullable_to_non_nullable
as double?,promotionCode: freezed == promotionCode ? _self.promotionCode : promotionCode // ignore: cast_nullable_to_non_nullable
as String?,promotionDiscount: freezed == promotionDiscount ? _self.promotionDiscount : promotionDiscount // ignore: cast_nullable_to_non_nullable
as double?,discount: freezed == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as double?,finalPrice: freezed == finalPrice ? _self.finalPrice : finalPrice // ignore: cast_nullable_to_non_nullable
as double?,appliedPromotions: freezed == appliedPromotions ? _self._appliedPromotions : appliedPromotions // ignore: cast_nullable_to_non_nullable
as List<PromotionInfo>?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$EstimatedPrice {

 double get minPrice; double get maxPrice; double? get estimatedWeight; String? get note;
/// Create a copy of EstimatedPrice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EstimatedPriceCopyWith<EstimatedPrice> get copyWith => _$EstimatedPriceCopyWithImpl<EstimatedPrice>(this as EstimatedPrice, _$identity);

  /// Serializes this EstimatedPrice to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EstimatedPrice&&(identical(other.minPrice, minPrice) || other.minPrice == minPrice)&&(identical(other.maxPrice, maxPrice) || other.maxPrice == maxPrice)&&(identical(other.estimatedWeight, estimatedWeight) || other.estimatedWeight == estimatedWeight)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,minPrice,maxPrice,estimatedWeight,note);

@override
String toString() {
  return 'EstimatedPrice(minPrice: $minPrice, maxPrice: $maxPrice, estimatedWeight: $estimatedWeight, note: $note)';
}


}

/// @nodoc
abstract mixin class $EstimatedPriceCopyWith<$Res>  {
  factory $EstimatedPriceCopyWith(EstimatedPrice value, $Res Function(EstimatedPrice) _then) = _$EstimatedPriceCopyWithImpl;
@useResult
$Res call({
 double minPrice, double maxPrice, double? estimatedWeight, String? note
});




}
/// @nodoc
class _$EstimatedPriceCopyWithImpl<$Res>
    implements $EstimatedPriceCopyWith<$Res> {
  _$EstimatedPriceCopyWithImpl(this._self, this._then);

  final EstimatedPrice _self;
  final $Res Function(EstimatedPrice) _then;

/// Create a copy of EstimatedPrice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? minPrice = null,Object? maxPrice = null,Object? estimatedWeight = freezed,Object? note = freezed,}) {
  return _then(_self.copyWith(
minPrice: null == minPrice ? _self.minPrice : minPrice // ignore: cast_nullable_to_non_nullable
as double,maxPrice: null == maxPrice ? _self.maxPrice : maxPrice // ignore: cast_nullable_to_non_nullable
as double,estimatedWeight: freezed == estimatedWeight ? _self.estimatedWeight : estimatedWeight // ignore: cast_nullable_to_non_nullable
as double?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [EstimatedPrice].
extension EstimatedPricePatterns on EstimatedPrice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EstimatedPrice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EstimatedPrice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EstimatedPrice value)  $default,){
final _that = this;
switch (_that) {
case _EstimatedPrice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EstimatedPrice value)?  $default,){
final _that = this;
switch (_that) {
case _EstimatedPrice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double minPrice,  double maxPrice,  double? estimatedWeight,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EstimatedPrice() when $default != null:
return $default(_that.minPrice,_that.maxPrice,_that.estimatedWeight,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double minPrice,  double maxPrice,  double? estimatedWeight,  String? note)  $default,) {final _that = this;
switch (_that) {
case _EstimatedPrice():
return $default(_that.minPrice,_that.maxPrice,_that.estimatedWeight,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double minPrice,  double maxPrice,  double? estimatedWeight,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _EstimatedPrice() when $default != null:
return $default(_that.minPrice,_that.maxPrice,_that.estimatedWeight,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EstimatedPrice implements EstimatedPrice {
  const _EstimatedPrice({required this.minPrice, required this.maxPrice, this.estimatedWeight, this.note});
  factory _EstimatedPrice.fromJson(Map<String, dynamic> json) => _$EstimatedPriceFromJson(json);

@override final  double minPrice;
@override final  double maxPrice;
@override final  double? estimatedWeight;
@override final  String? note;

/// Create a copy of EstimatedPrice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EstimatedPriceCopyWith<_EstimatedPrice> get copyWith => __$EstimatedPriceCopyWithImpl<_EstimatedPrice>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EstimatedPriceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EstimatedPrice&&(identical(other.minPrice, minPrice) || other.minPrice == minPrice)&&(identical(other.maxPrice, maxPrice) || other.maxPrice == maxPrice)&&(identical(other.estimatedWeight, estimatedWeight) || other.estimatedWeight == estimatedWeight)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,minPrice,maxPrice,estimatedWeight,note);

@override
String toString() {
  return 'EstimatedPrice(minPrice: $minPrice, maxPrice: $maxPrice, estimatedWeight: $estimatedWeight, note: $note)';
}


}

/// @nodoc
abstract mixin class _$EstimatedPriceCopyWith<$Res> implements $EstimatedPriceCopyWith<$Res> {
  factory _$EstimatedPriceCopyWith(_EstimatedPrice value, $Res Function(_EstimatedPrice) _then) = __$EstimatedPriceCopyWithImpl;
@override @useResult
$Res call({
 double minPrice, double maxPrice, double? estimatedWeight, String? note
});




}
/// @nodoc
class __$EstimatedPriceCopyWithImpl<$Res>
    implements _$EstimatedPriceCopyWith<$Res> {
  __$EstimatedPriceCopyWithImpl(this._self, this._then);

  final _EstimatedPrice _self;
  final $Res Function(_EstimatedPrice) _then;

/// Create a copy of EstimatedPrice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? minPrice = null,Object? maxPrice = null,Object? estimatedWeight = freezed,Object? note = freezed,}) {
  return _then(_EstimatedPrice(
minPrice: null == minPrice ? _self.minPrice : minPrice // ignore: cast_nullable_to_non_nullable
as double,maxPrice: null == maxPrice ? _self.maxPrice : maxPrice // ignore: cast_nullable_to_non_nullable
as double,estimatedWeight: freezed == estimatedWeight ? _self.estimatedWeight : estimatedWeight // ignore: cast_nullable_to_non_nullable
as double?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Order {

 int get id; String? get orderCode; int get userId; OrderType? get type; ServiceCategory? get serviceCategory; PricingType? get pricingType; int get lockerId; Locker? get locker; String? get lockerName; String? get lockerCode; int get boxId; int? get boxNumber; int? get sendBoxNumber; int? get receiveBoxNumber; List<OrderBox>? get boxes; OrderStatus get status; String? get pin; String? get pinCode; Map<String, dynamic>? get customer; int? get senderId; String? get senderName; String? get senderPhone; int? get receiverId; String? get receiverName; String? get receiverPhone; double get totalAmount; double? get totalPrice; double? get originalPrice; double? get storagePrice; dynamic get estimatedPrice;// Can be EstimatedPrice or double based on RN type
 double? get actualPrice; double? get discountAmount; PriceBreakdown? get priceBreakdown; String? get promotionCode; List<String>? get appliedPromotionCodes; double? get promotionDiscount; double? get discount; PromotionInfo? get promotionInfo; Map<String, dynamic>? get promotion; double? get estimatedWeight; double? get actualWeight; String? get weightUnit; bool? get isOvertime; double? get overtimeHours; double? get extraFee; bool? get isPaid; bool? get paymentRequired; Map<String, dynamic>? get payment; String? get nextAction; String? get nextActionMessage; List<OrderItem>? get items; List<OrderItem>? get orderDetails; List<LaundryService>? get services; String? get customerNote; String? get staffNote; String? get deliveryAddress; String? get expiresAt; String? get intendedReceiveAt; String? get pickupDeadline; String? get createdAt; String? get updatedAt; String? get confirmedAt; String? get collectedAt; String? get processedAt; String? get readyAt; String? get returnedAt; String? get completedAt; String? get canceledAt; String? get cancelReason;
/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderCopyWith<Order> get copyWith => _$OrderCopyWithImpl<Order>(this as Order, _$identity);

  /// Serializes this Order to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Order&&(identical(other.id, id) || other.id == id)&&(identical(other.orderCode, orderCode) || other.orderCode == orderCode)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.type, type) || other.type == type)&&(identical(other.serviceCategory, serviceCategory) || other.serviceCategory == serviceCategory)&&(identical(other.pricingType, pricingType) || other.pricingType == pricingType)&&(identical(other.lockerId, lockerId) || other.lockerId == lockerId)&&(identical(other.locker, locker) || other.locker == locker)&&(identical(other.lockerName, lockerName) || other.lockerName == lockerName)&&(identical(other.lockerCode, lockerCode) || other.lockerCode == lockerCode)&&(identical(other.boxId, boxId) || other.boxId == boxId)&&(identical(other.boxNumber, boxNumber) || other.boxNumber == boxNumber)&&(identical(other.sendBoxNumber, sendBoxNumber) || other.sendBoxNumber == sendBoxNumber)&&(identical(other.receiveBoxNumber, receiveBoxNumber) || other.receiveBoxNumber == receiveBoxNumber)&&const DeepCollectionEquality().equals(other.boxes, boxes)&&(identical(other.status, status) || other.status == status)&&(identical(other.pin, pin) || other.pin == pin)&&(identical(other.pinCode, pinCode) || other.pinCode == pinCode)&&const DeepCollectionEquality().equals(other.customer, customer)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.senderPhone, senderPhone) || other.senderPhone == senderPhone)&&(identical(other.receiverId, receiverId) || other.receiverId == receiverId)&&(identical(other.receiverName, receiverName) || other.receiverName == receiverName)&&(identical(other.receiverPhone, receiverPhone) || other.receiverPhone == receiverPhone)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.originalPrice, originalPrice) || other.originalPrice == originalPrice)&&(identical(other.storagePrice, storagePrice) || other.storagePrice == storagePrice)&&const DeepCollectionEquality().equals(other.estimatedPrice, estimatedPrice)&&(identical(other.actualPrice, actualPrice) || other.actualPrice == actualPrice)&&(identical(other.discountAmount, discountAmount) || other.discountAmount == discountAmount)&&(identical(other.priceBreakdown, priceBreakdown) || other.priceBreakdown == priceBreakdown)&&(identical(other.promotionCode, promotionCode) || other.promotionCode == promotionCode)&&const DeepCollectionEquality().equals(other.appliedPromotionCodes, appliedPromotionCodes)&&(identical(other.promotionDiscount, promotionDiscount) || other.promotionDiscount == promotionDiscount)&&(identical(other.discount, discount) || other.discount == discount)&&(identical(other.promotionInfo, promotionInfo) || other.promotionInfo == promotionInfo)&&const DeepCollectionEquality().equals(other.promotion, promotion)&&(identical(other.estimatedWeight, estimatedWeight) || other.estimatedWeight == estimatedWeight)&&(identical(other.actualWeight, actualWeight) || other.actualWeight == actualWeight)&&(identical(other.weightUnit, weightUnit) || other.weightUnit == weightUnit)&&(identical(other.isOvertime, isOvertime) || other.isOvertime == isOvertime)&&(identical(other.overtimeHours, overtimeHours) || other.overtimeHours == overtimeHours)&&(identical(other.extraFee, extraFee) || other.extraFee == extraFee)&&(identical(other.isPaid, isPaid) || other.isPaid == isPaid)&&(identical(other.paymentRequired, paymentRequired) || other.paymentRequired == paymentRequired)&&const DeepCollectionEquality().equals(other.payment, payment)&&(identical(other.nextAction, nextAction) || other.nextAction == nextAction)&&(identical(other.nextActionMessage, nextActionMessage) || other.nextActionMessage == nextActionMessage)&&const DeepCollectionEquality().equals(other.items, items)&&const DeepCollectionEquality().equals(other.orderDetails, orderDetails)&&const DeepCollectionEquality().equals(other.services, services)&&(identical(other.customerNote, customerNote) || other.customerNote == customerNote)&&(identical(other.staffNote, staffNote) || other.staffNote == staffNote)&&(identical(other.deliveryAddress, deliveryAddress) || other.deliveryAddress == deliveryAddress)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.intendedReceiveAt, intendedReceiveAt) || other.intendedReceiveAt == intendedReceiveAt)&&(identical(other.pickupDeadline, pickupDeadline) || other.pickupDeadline == pickupDeadline)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.confirmedAt, confirmedAt) || other.confirmedAt == confirmedAt)&&(identical(other.collectedAt, collectedAt) || other.collectedAt == collectedAt)&&(identical(other.processedAt, processedAt) || other.processedAt == processedAt)&&(identical(other.readyAt, readyAt) || other.readyAt == readyAt)&&(identical(other.returnedAt, returnedAt) || other.returnedAt == returnedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.canceledAt, canceledAt) || other.canceledAt == canceledAt)&&(identical(other.cancelReason, cancelReason) || other.cancelReason == cancelReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,orderCode,userId,type,serviceCategory,pricingType,lockerId,locker,lockerName,lockerCode,boxId,boxNumber,sendBoxNumber,receiveBoxNumber,const DeepCollectionEquality().hash(boxes),status,pin,pinCode,const DeepCollectionEquality().hash(customer),senderId,senderName,senderPhone,receiverId,receiverName,receiverPhone,totalAmount,totalPrice,originalPrice,storagePrice,const DeepCollectionEquality().hash(estimatedPrice),actualPrice,discountAmount,priceBreakdown,promotionCode,const DeepCollectionEquality().hash(appliedPromotionCodes),promotionDiscount,discount,promotionInfo,const DeepCollectionEquality().hash(promotion),estimatedWeight,actualWeight,weightUnit,isOvertime,overtimeHours,extraFee,isPaid,paymentRequired,const DeepCollectionEquality().hash(payment),nextAction,nextActionMessage,const DeepCollectionEquality().hash(items),const DeepCollectionEquality().hash(orderDetails),const DeepCollectionEquality().hash(services),customerNote,staffNote,deliveryAddress,expiresAt,intendedReceiveAt,pickupDeadline,createdAt,updatedAt,confirmedAt,collectedAt,processedAt,readyAt,returnedAt,completedAt,canceledAt,cancelReason]);

@override
String toString() {
  return 'Order(id: $id, orderCode: $orderCode, userId: $userId, type: $type, serviceCategory: $serviceCategory, pricingType: $pricingType, lockerId: $lockerId, locker: $locker, lockerName: $lockerName, lockerCode: $lockerCode, boxId: $boxId, boxNumber: $boxNumber, sendBoxNumber: $sendBoxNumber, receiveBoxNumber: $receiveBoxNumber, boxes: $boxes, status: $status, pin: $pin, pinCode: $pinCode, customer: $customer, senderId: $senderId, senderName: $senderName, senderPhone: $senderPhone, receiverId: $receiverId, receiverName: $receiverName, receiverPhone: $receiverPhone, totalAmount: $totalAmount, totalPrice: $totalPrice, originalPrice: $originalPrice, storagePrice: $storagePrice, estimatedPrice: $estimatedPrice, actualPrice: $actualPrice, discountAmount: $discountAmount, priceBreakdown: $priceBreakdown, promotionCode: $promotionCode, appliedPromotionCodes: $appliedPromotionCodes, promotionDiscount: $promotionDiscount, discount: $discount, promotionInfo: $promotionInfo, promotion: $promotion, estimatedWeight: $estimatedWeight, actualWeight: $actualWeight, weightUnit: $weightUnit, isOvertime: $isOvertime, overtimeHours: $overtimeHours, extraFee: $extraFee, isPaid: $isPaid, paymentRequired: $paymentRequired, payment: $payment, nextAction: $nextAction, nextActionMessage: $nextActionMessage, items: $items, orderDetails: $orderDetails, services: $services, customerNote: $customerNote, staffNote: $staffNote, deliveryAddress: $deliveryAddress, expiresAt: $expiresAt, intendedReceiveAt: $intendedReceiveAt, pickupDeadline: $pickupDeadline, createdAt: $createdAt, updatedAt: $updatedAt, confirmedAt: $confirmedAt, collectedAt: $collectedAt, processedAt: $processedAt, readyAt: $readyAt, returnedAt: $returnedAt, completedAt: $completedAt, canceledAt: $canceledAt, cancelReason: $cancelReason)';
}


}

/// @nodoc
abstract mixin class $OrderCopyWith<$Res>  {
  factory $OrderCopyWith(Order value, $Res Function(Order) _then) = _$OrderCopyWithImpl;
@useResult
$Res call({
 int id, String? orderCode, int userId, OrderType? type, ServiceCategory? serviceCategory, PricingType? pricingType, int lockerId, Locker? locker, String? lockerName, String? lockerCode, int boxId, int? boxNumber, int? sendBoxNumber, int? receiveBoxNumber, List<OrderBox>? boxes, OrderStatus status, String? pin, String? pinCode, Map<String, dynamic>? customer, int? senderId, String? senderName, String? senderPhone, int? receiverId, String? receiverName, String? receiverPhone, double totalAmount, double? totalPrice, double? originalPrice, double? storagePrice, dynamic estimatedPrice, double? actualPrice, double? discountAmount, PriceBreakdown? priceBreakdown, String? promotionCode, List<String>? appliedPromotionCodes, double? promotionDiscount, double? discount, PromotionInfo? promotionInfo, Map<String, dynamic>? promotion, double? estimatedWeight, double? actualWeight, String? weightUnit, bool? isOvertime, double? overtimeHours, double? extraFee, bool? isPaid, bool? paymentRequired, Map<String, dynamic>? payment, String? nextAction, String? nextActionMessage, List<OrderItem>? items, List<OrderItem>? orderDetails, List<LaundryService>? services, String? customerNote, String? staffNote, String? deliveryAddress, String? expiresAt, String? intendedReceiveAt, String? pickupDeadline, String? createdAt, String? updatedAt, String? confirmedAt, String? collectedAt, String? processedAt, String? readyAt, String? returnedAt, String? completedAt, String? canceledAt, String? cancelReason
});


$LockerCopyWith<$Res>? get locker;$PriceBreakdownCopyWith<$Res>? get priceBreakdown;$PromotionInfoCopyWith<$Res>? get promotionInfo;

}
/// @nodoc
class _$OrderCopyWithImpl<$Res>
    implements $OrderCopyWith<$Res> {
  _$OrderCopyWithImpl(this._self, this._then);

  final Order _self;
  final $Res Function(Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orderCode = freezed,Object? userId = null,Object? type = freezed,Object? serviceCategory = freezed,Object? pricingType = freezed,Object? lockerId = null,Object? locker = freezed,Object? lockerName = freezed,Object? lockerCode = freezed,Object? boxId = null,Object? boxNumber = freezed,Object? sendBoxNumber = freezed,Object? receiveBoxNumber = freezed,Object? boxes = freezed,Object? status = null,Object? pin = freezed,Object? pinCode = freezed,Object? customer = freezed,Object? senderId = freezed,Object? senderName = freezed,Object? senderPhone = freezed,Object? receiverId = freezed,Object? receiverName = freezed,Object? receiverPhone = freezed,Object? totalAmount = null,Object? totalPrice = freezed,Object? originalPrice = freezed,Object? storagePrice = freezed,Object? estimatedPrice = freezed,Object? actualPrice = freezed,Object? discountAmount = freezed,Object? priceBreakdown = freezed,Object? promotionCode = freezed,Object? appliedPromotionCodes = freezed,Object? promotionDiscount = freezed,Object? discount = freezed,Object? promotionInfo = freezed,Object? promotion = freezed,Object? estimatedWeight = freezed,Object? actualWeight = freezed,Object? weightUnit = freezed,Object? isOvertime = freezed,Object? overtimeHours = freezed,Object? extraFee = freezed,Object? isPaid = freezed,Object? paymentRequired = freezed,Object? payment = freezed,Object? nextAction = freezed,Object? nextActionMessage = freezed,Object? items = freezed,Object? orderDetails = freezed,Object? services = freezed,Object? customerNote = freezed,Object? staffNote = freezed,Object? deliveryAddress = freezed,Object? expiresAt = freezed,Object? intendedReceiveAt = freezed,Object? pickupDeadline = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? confirmedAt = freezed,Object? collectedAt = freezed,Object? processedAt = freezed,Object? readyAt = freezed,Object? returnedAt = freezed,Object? completedAt = freezed,Object? canceledAt = freezed,Object? cancelReason = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,orderCode: freezed == orderCode ? _self.orderCode : orderCode // ignore: cast_nullable_to_non_nullable
as String?,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as OrderType?,serviceCategory: freezed == serviceCategory ? _self.serviceCategory : serviceCategory // ignore: cast_nullable_to_non_nullable
as ServiceCategory?,pricingType: freezed == pricingType ? _self.pricingType : pricingType // ignore: cast_nullable_to_non_nullable
as PricingType?,lockerId: null == lockerId ? _self.lockerId : lockerId // ignore: cast_nullable_to_non_nullable
as int,locker: freezed == locker ? _self.locker : locker // ignore: cast_nullable_to_non_nullable
as Locker?,lockerName: freezed == lockerName ? _self.lockerName : lockerName // ignore: cast_nullable_to_non_nullable
as String?,lockerCode: freezed == lockerCode ? _self.lockerCode : lockerCode // ignore: cast_nullable_to_non_nullable
as String?,boxId: null == boxId ? _self.boxId : boxId // ignore: cast_nullable_to_non_nullable
as int,boxNumber: freezed == boxNumber ? _self.boxNumber : boxNumber // ignore: cast_nullable_to_non_nullable
as int?,sendBoxNumber: freezed == sendBoxNumber ? _self.sendBoxNumber : sendBoxNumber // ignore: cast_nullable_to_non_nullable
as int?,receiveBoxNumber: freezed == receiveBoxNumber ? _self.receiveBoxNumber : receiveBoxNumber // ignore: cast_nullable_to_non_nullable
as int?,boxes: freezed == boxes ? _self.boxes : boxes // ignore: cast_nullable_to_non_nullable
as List<OrderBox>?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,pin: freezed == pin ? _self.pin : pin // ignore: cast_nullable_to_non_nullable
as String?,pinCode: freezed == pinCode ? _self.pinCode : pinCode // ignore: cast_nullable_to_non_nullable
as String?,customer: freezed == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,senderId: freezed == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as int?,senderName: freezed == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String?,senderPhone: freezed == senderPhone ? _self.senderPhone : senderPhone // ignore: cast_nullable_to_non_nullable
as String?,receiverId: freezed == receiverId ? _self.receiverId : receiverId // ignore: cast_nullable_to_non_nullable
as int?,receiverName: freezed == receiverName ? _self.receiverName : receiverName // ignore: cast_nullable_to_non_nullable
as String?,receiverPhone: freezed == receiverPhone ? _self.receiverPhone : receiverPhone // ignore: cast_nullable_to_non_nullable
as String?,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,totalPrice: freezed == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double?,originalPrice: freezed == originalPrice ? _self.originalPrice : originalPrice // ignore: cast_nullable_to_non_nullable
as double?,storagePrice: freezed == storagePrice ? _self.storagePrice : storagePrice // ignore: cast_nullable_to_non_nullable
as double?,estimatedPrice: freezed == estimatedPrice ? _self.estimatedPrice : estimatedPrice // ignore: cast_nullable_to_non_nullable
as dynamic,actualPrice: freezed == actualPrice ? _self.actualPrice : actualPrice // ignore: cast_nullable_to_non_nullable
as double?,discountAmount: freezed == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as double?,priceBreakdown: freezed == priceBreakdown ? _self.priceBreakdown : priceBreakdown // ignore: cast_nullable_to_non_nullable
as PriceBreakdown?,promotionCode: freezed == promotionCode ? _self.promotionCode : promotionCode // ignore: cast_nullable_to_non_nullable
as String?,appliedPromotionCodes: freezed == appliedPromotionCodes ? _self.appliedPromotionCodes : appliedPromotionCodes // ignore: cast_nullable_to_non_nullable
as List<String>?,promotionDiscount: freezed == promotionDiscount ? _self.promotionDiscount : promotionDiscount // ignore: cast_nullable_to_non_nullable
as double?,discount: freezed == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as double?,promotionInfo: freezed == promotionInfo ? _self.promotionInfo : promotionInfo // ignore: cast_nullable_to_non_nullable
as PromotionInfo?,promotion: freezed == promotion ? _self.promotion : promotion // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,estimatedWeight: freezed == estimatedWeight ? _self.estimatedWeight : estimatedWeight // ignore: cast_nullable_to_non_nullable
as double?,actualWeight: freezed == actualWeight ? _self.actualWeight : actualWeight // ignore: cast_nullable_to_non_nullable
as double?,weightUnit: freezed == weightUnit ? _self.weightUnit : weightUnit // ignore: cast_nullable_to_non_nullable
as String?,isOvertime: freezed == isOvertime ? _self.isOvertime : isOvertime // ignore: cast_nullable_to_non_nullable
as bool?,overtimeHours: freezed == overtimeHours ? _self.overtimeHours : overtimeHours // ignore: cast_nullable_to_non_nullable
as double?,extraFee: freezed == extraFee ? _self.extraFee : extraFee // ignore: cast_nullable_to_non_nullable
as double?,isPaid: freezed == isPaid ? _self.isPaid : isPaid // ignore: cast_nullable_to_non_nullable
as bool?,paymentRequired: freezed == paymentRequired ? _self.paymentRequired : paymentRequired // ignore: cast_nullable_to_non_nullable
as bool?,payment: freezed == payment ? _self.payment : payment // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,nextAction: freezed == nextAction ? _self.nextAction : nextAction // ignore: cast_nullable_to_non_nullable
as String?,nextActionMessage: freezed == nextActionMessage ? _self.nextActionMessage : nextActionMessage // ignore: cast_nullable_to_non_nullable
as String?,items: freezed == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItem>?,orderDetails: freezed == orderDetails ? _self.orderDetails : orderDetails // ignore: cast_nullable_to_non_nullable
as List<OrderItem>?,services: freezed == services ? _self.services : services // ignore: cast_nullable_to_non_nullable
as List<LaundryService>?,customerNote: freezed == customerNote ? _self.customerNote : customerNote // ignore: cast_nullable_to_non_nullable
as String?,staffNote: freezed == staffNote ? _self.staffNote : staffNote // ignore: cast_nullable_to_non_nullable
as String?,deliveryAddress: freezed == deliveryAddress ? _self.deliveryAddress : deliveryAddress // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as String?,intendedReceiveAt: freezed == intendedReceiveAt ? _self.intendedReceiveAt : intendedReceiveAt // ignore: cast_nullable_to_non_nullable
as String?,pickupDeadline: freezed == pickupDeadline ? _self.pickupDeadline : pickupDeadline // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,confirmedAt: freezed == confirmedAt ? _self.confirmedAt : confirmedAt // ignore: cast_nullable_to_non_nullable
as String?,collectedAt: freezed == collectedAt ? _self.collectedAt : collectedAt // ignore: cast_nullable_to_non_nullable
as String?,processedAt: freezed == processedAt ? _self.processedAt : processedAt // ignore: cast_nullable_to_non_nullable
as String?,readyAt: freezed == readyAt ? _self.readyAt : readyAt // ignore: cast_nullable_to_non_nullable
as String?,returnedAt: freezed == returnedAt ? _self.returnedAt : returnedAt // ignore: cast_nullable_to_non_nullable
as String?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as String?,canceledAt: freezed == canceledAt ? _self.canceledAt : canceledAt // ignore: cast_nullable_to_non_nullable
as String?,cancelReason: freezed == cancelReason ? _self.cancelReason : cancelReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LockerCopyWith<$Res>? get locker {
    if (_self.locker == null) {
    return null;
  }

  return $LockerCopyWith<$Res>(_self.locker!, (value) {
    return _then(_self.copyWith(locker: value));
  });
}/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceBreakdownCopyWith<$Res>? get priceBreakdown {
    if (_self.priceBreakdown == null) {
    return null;
  }

  return $PriceBreakdownCopyWith<$Res>(_self.priceBreakdown!, (value) {
    return _then(_self.copyWith(priceBreakdown: value));
  });
}/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PromotionInfoCopyWith<$Res>? get promotionInfo {
    if (_self.promotionInfo == null) {
    return null;
  }

  return $PromotionInfoCopyWith<$Res>(_self.promotionInfo!, (value) {
    return _then(_self.copyWith(promotionInfo: value));
  });
}
}


/// Adds pattern-matching-related methods to [Order].
extension OrderPatterns on Order {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Order value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Order() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Order value)  $default,){
final _that = this;
switch (_that) {
case _Order():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Order value)?  $default,){
final _that = this;
switch (_that) {
case _Order() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String? orderCode,  int userId,  OrderType? type,  ServiceCategory? serviceCategory,  PricingType? pricingType,  int lockerId,  Locker? locker,  String? lockerName,  String? lockerCode,  int boxId,  int? boxNumber,  int? sendBoxNumber,  int? receiveBoxNumber,  List<OrderBox>? boxes,  OrderStatus status,  String? pin,  String? pinCode,  Map<String, dynamic>? customer,  int? senderId,  String? senderName,  String? senderPhone,  int? receiverId,  String? receiverName,  String? receiverPhone,  double totalAmount,  double? totalPrice,  double? originalPrice,  double? storagePrice,  dynamic estimatedPrice,  double? actualPrice,  double? discountAmount,  PriceBreakdown? priceBreakdown,  String? promotionCode,  List<String>? appliedPromotionCodes,  double? promotionDiscount,  double? discount,  PromotionInfo? promotionInfo,  Map<String, dynamic>? promotion,  double? estimatedWeight,  double? actualWeight,  String? weightUnit,  bool? isOvertime,  double? overtimeHours,  double? extraFee,  bool? isPaid,  bool? paymentRequired,  Map<String, dynamic>? payment,  String? nextAction,  String? nextActionMessage,  List<OrderItem>? items,  List<OrderItem>? orderDetails,  List<LaundryService>? services,  String? customerNote,  String? staffNote,  String? deliveryAddress,  String? expiresAt,  String? intendedReceiveAt,  String? pickupDeadline,  String? createdAt,  String? updatedAt,  String? confirmedAt,  String? collectedAt,  String? processedAt,  String? readyAt,  String? returnedAt,  String? completedAt,  String? canceledAt,  String? cancelReason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.orderCode,_that.userId,_that.type,_that.serviceCategory,_that.pricingType,_that.lockerId,_that.locker,_that.lockerName,_that.lockerCode,_that.boxId,_that.boxNumber,_that.sendBoxNumber,_that.receiveBoxNumber,_that.boxes,_that.status,_that.pin,_that.pinCode,_that.customer,_that.senderId,_that.senderName,_that.senderPhone,_that.receiverId,_that.receiverName,_that.receiverPhone,_that.totalAmount,_that.totalPrice,_that.originalPrice,_that.storagePrice,_that.estimatedPrice,_that.actualPrice,_that.discountAmount,_that.priceBreakdown,_that.promotionCode,_that.appliedPromotionCodes,_that.promotionDiscount,_that.discount,_that.promotionInfo,_that.promotion,_that.estimatedWeight,_that.actualWeight,_that.weightUnit,_that.isOvertime,_that.overtimeHours,_that.extraFee,_that.isPaid,_that.paymentRequired,_that.payment,_that.nextAction,_that.nextActionMessage,_that.items,_that.orderDetails,_that.services,_that.customerNote,_that.staffNote,_that.deliveryAddress,_that.expiresAt,_that.intendedReceiveAt,_that.pickupDeadline,_that.createdAt,_that.updatedAt,_that.confirmedAt,_that.collectedAt,_that.processedAt,_that.readyAt,_that.returnedAt,_that.completedAt,_that.canceledAt,_that.cancelReason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String? orderCode,  int userId,  OrderType? type,  ServiceCategory? serviceCategory,  PricingType? pricingType,  int lockerId,  Locker? locker,  String? lockerName,  String? lockerCode,  int boxId,  int? boxNumber,  int? sendBoxNumber,  int? receiveBoxNumber,  List<OrderBox>? boxes,  OrderStatus status,  String? pin,  String? pinCode,  Map<String, dynamic>? customer,  int? senderId,  String? senderName,  String? senderPhone,  int? receiverId,  String? receiverName,  String? receiverPhone,  double totalAmount,  double? totalPrice,  double? originalPrice,  double? storagePrice,  dynamic estimatedPrice,  double? actualPrice,  double? discountAmount,  PriceBreakdown? priceBreakdown,  String? promotionCode,  List<String>? appliedPromotionCodes,  double? promotionDiscount,  double? discount,  PromotionInfo? promotionInfo,  Map<String, dynamic>? promotion,  double? estimatedWeight,  double? actualWeight,  String? weightUnit,  bool? isOvertime,  double? overtimeHours,  double? extraFee,  bool? isPaid,  bool? paymentRequired,  Map<String, dynamic>? payment,  String? nextAction,  String? nextActionMessage,  List<OrderItem>? items,  List<OrderItem>? orderDetails,  List<LaundryService>? services,  String? customerNote,  String? staffNote,  String? deliveryAddress,  String? expiresAt,  String? intendedReceiveAt,  String? pickupDeadline,  String? createdAt,  String? updatedAt,  String? confirmedAt,  String? collectedAt,  String? processedAt,  String? readyAt,  String? returnedAt,  String? completedAt,  String? canceledAt,  String? cancelReason)  $default,) {final _that = this;
switch (_that) {
case _Order():
return $default(_that.id,_that.orderCode,_that.userId,_that.type,_that.serviceCategory,_that.pricingType,_that.lockerId,_that.locker,_that.lockerName,_that.lockerCode,_that.boxId,_that.boxNumber,_that.sendBoxNumber,_that.receiveBoxNumber,_that.boxes,_that.status,_that.pin,_that.pinCode,_that.customer,_that.senderId,_that.senderName,_that.senderPhone,_that.receiverId,_that.receiverName,_that.receiverPhone,_that.totalAmount,_that.totalPrice,_that.originalPrice,_that.storagePrice,_that.estimatedPrice,_that.actualPrice,_that.discountAmount,_that.priceBreakdown,_that.promotionCode,_that.appliedPromotionCodes,_that.promotionDiscount,_that.discount,_that.promotionInfo,_that.promotion,_that.estimatedWeight,_that.actualWeight,_that.weightUnit,_that.isOvertime,_that.overtimeHours,_that.extraFee,_that.isPaid,_that.paymentRequired,_that.payment,_that.nextAction,_that.nextActionMessage,_that.items,_that.orderDetails,_that.services,_that.customerNote,_that.staffNote,_that.deliveryAddress,_that.expiresAt,_that.intendedReceiveAt,_that.pickupDeadline,_that.createdAt,_that.updatedAt,_that.confirmedAt,_that.collectedAt,_that.processedAt,_that.readyAt,_that.returnedAt,_that.completedAt,_that.canceledAt,_that.cancelReason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String? orderCode,  int userId,  OrderType? type,  ServiceCategory? serviceCategory,  PricingType? pricingType,  int lockerId,  Locker? locker,  String? lockerName,  String? lockerCode,  int boxId,  int? boxNumber,  int? sendBoxNumber,  int? receiveBoxNumber,  List<OrderBox>? boxes,  OrderStatus status,  String? pin,  String? pinCode,  Map<String, dynamic>? customer,  int? senderId,  String? senderName,  String? senderPhone,  int? receiverId,  String? receiverName,  String? receiverPhone,  double totalAmount,  double? totalPrice,  double? originalPrice,  double? storagePrice,  dynamic estimatedPrice,  double? actualPrice,  double? discountAmount,  PriceBreakdown? priceBreakdown,  String? promotionCode,  List<String>? appliedPromotionCodes,  double? promotionDiscount,  double? discount,  PromotionInfo? promotionInfo,  Map<String, dynamic>? promotion,  double? estimatedWeight,  double? actualWeight,  String? weightUnit,  bool? isOvertime,  double? overtimeHours,  double? extraFee,  bool? isPaid,  bool? paymentRequired,  Map<String, dynamic>? payment,  String? nextAction,  String? nextActionMessage,  List<OrderItem>? items,  List<OrderItem>? orderDetails,  List<LaundryService>? services,  String? customerNote,  String? staffNote,  String? deliveryAddress,  String? expiresAt,  String? intendedReceiveAt,  String? pickupDeadline,  String? createdAt,  String? updatedAt,  String? confirmedAt,  String? collectedAt,  String? processedAt,  String? readyAt,  String? returnedAt,  String? completedAt,  String? canceledAt,  String? cancelReason)?  $default,) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.orderCode,_that.userId,_that.type,_that.serviceCategory,_that.pricingType,_that.lockerId,_that.locker,_that.lockerName,_that.lockerCode,_that.boxId,_that.boxNumber,_that.sendBoxNumber,_that.receiveBoxNumber,_that.boxes,_that.status,_that.pin,_that.pinCode,_that.customer,_that.senderId,_that.senderName,_that.senderPhone,_that.receiverId,_that.receiverName,_that.receiverPhone,_that.totalAmount,_that.totalPrice,_that.originalPrice,_that.storagePrice,_that.estimatedPrice,_that.actualPrice,_that.discountAmount,_that.priceBreakdown,_that.promotionCode,_that.appliedPromotionCodes,_that.promotionDiscount,_that.discount,_that.promotionInfo,_that.promotion,_that.estimatedWeight,_that.actualWeight,_that.weightUnit,_that.isOvertime,_that.overtimeHours,_that.extraFee,_that.isPaid,_that.paymentRequired,_that.payment,_that.nextAction,_that.nextActionMessage,_that.items,_that.orderDetails,_that.services,_that.customerNote,_that.staffNote,_that.deliveryAddress,_that.expiresAt,_that.intendedReceiveAt,_that.pickupDeadline,_that.createdAt,_that.updatedAt,_that.confirmedAt,_that.collectedAt,_that.processedAt,_that.readyAt,_that.returnedAt,_that.completedAt,_that.canceledAt,_that.cancelReason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Order implements Order {
  const _Order({required this.id, this.orderCode, required this.userId, this.type, this.serviceCategory, this.pricingType, required this.lockerId, this.locker, this.lockerName, this.lockerCode, required this.boxId, this.boxNumber, this.sendBoxNumber, this.receiveBoxNumber, final  List<OrderBox>? boxes, required this.status, this.pin, this.pinCode, final  Map<String, dynamic>? customer, this.senderId, this.senderName, this.senderPhone, this.receiverId, this.receiverName, this.receiverPhone, required this.totalAmount, this.totalPrice, this.originalPrice, this.storagePrice, this.estimatedPrice, this.actualPrice, this.discountAmount, this.priceBreakdown, this.promotionCode, final  List<String>? appliedPromotionCodes, this.promotionDiscount, this.discount, this.promotionInfo, final  Map<String, dynamic>? promotion, this.estimatedWeight, this.actualWeight, this.weightUnit, this.isOvertime, this.overtimeHours, this.extraFee, this.isPaid, this.paymentRequired, final  Map<String, dynamic>? payment, this.nextAction, this.nextActionMessage, final  List<OrderItem>? items, final  List<OrderItem>? orderDetails, final  List<LaundryService>? services, this.customerNote, this.staffNote, this.deliveryAddress, this.expiresAt, this.intendedReceiveAt, this.pickupDeadline, this.createdAt, this.updatedAt, this.confirmedAt, this.collectedAt, this.processedAt, this.readyAt, this.returnedAt, this.completedAt, this.canceledAt, this.cancelReason}): _boxes = boxes,_customer = customer,_appliedPromotionCodes = appliedPromotionCodes,_promotion = promotion,_payment = payment,_items = items,_orderDetails = orderDetails,_services = services;
  factory _Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

@override final  int id;
@override final  String? orderCode;
@override final  int userId;
@override final  OrderType? type;
@override final  ServiceCategory? serviceCategory;
@override final  PricingType? pricingType;
@override final  int lockerId;
@override final  Locker? locker;
@override final  String? lockerName;
@override final  String? lockerCode;
@override final  int boxId;
@override final  int? boxNumber;
@override final  int? sendBoxNumber;
@override final  int? receiveBoxNumber;
 final  List<OrderBox>? _boxes;
@override List<OrderBox>? get boxes {
  final value = _boxes;
  if (value == null) return null;
  if (_boxes is EqualUnmodifiableListView) return _boxes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  OrderStatus status;
@override final  String? pin;
@override final  String? pinCode;
 final  Map<String, dynamic>? _customer;
@override Map<String, dynamic>? get customer {
  final value = _customer;
  if (value == null) return null;
  if (_customer is EqualUnmodifiableMapView) return _customer;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  int? senderId;
@override final  String? senderName;
@override final  String? senderPhone;
@override final  int? receiverId;
@override final  String? receiverName;
@override final  String? receiverPhone;
@override final  double totalAmount;
@override final  double? totalPrice;
@override final  double? originalPrice;
@override final  double? storagePrice;
@override final  dynamic estimatedPrice;
// Can be EstimatedPrice or double based on RN type
@override final  double? actualPrice;
@override final  double? discountAmount;
@override final  PriceBreakdown? priceBreakdown;
@override final  String? promotionCode;
 final  List<String>? _appliedPromotionCodes;
@override List<String>? get appliedPromotionCodes {
  final value = _appliedPromotionCodes;
  if (value == null) return null;
  if (_appliedPromotionCodes is EqualUnmodifiableListView) return _appliedPromotionCodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  double? promotionDiscount;
@override final  double? discount;
@override final  PromotionInfo? promotionInfo;
 final  Map<String, dynamic>? _promotion;
@override Map<String, dynamic>? get promotion {
  final value = _promotion;
  if (value == null) return null;
  if (_promotion is EqualUnmodifiableMapView) return _promotion;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  double? estimatedWeight;
@override final  double? actualWeight;
@override final  String? weightUnit;
@override final  bool? isOvertime;
@override final  double? overtimeHours;
@override final  double? extraFee;
@override final  bool? isPaid;
@override final  bool? paymentRequired;
 final  Map<String, dynamic>? _payment;
@override Map<String, dynamic>? get payment {
  final value = _payment;
  if (value == null) return null;
  if (_payment is EqualUnmodifiableMapView) return _payment;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String? nextAction;
@override final  String? nextActionMessage;
 final  List<OrderItem>? _items;
@override List<OrderItem>? get items {
  final value = _items;
  if (value == null) return null;
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<OrderItem>? _orderDetails;
@override List<OrderItem>? get orderDetails {
  final value = _orderDetails;
  if (value == null) return null;
  if (_orderDetails is EqualUnmodifiableListView) return _orderDetails;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<LaundryService>? _services;
@override List<LaundryService>? get services {
  final value = _services;
  if (value == null) return null;
  if (_services is EqualUnmodifiableListView) return _services;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? customerNote;
@override final  String? staffNote;
@override final  String? deliveryAddress;
@override final  String? expiresAt;
@override final  String? intendedReceiveAt;
@override final  String? pickupDeadline;
@override final  String? createdAt;
@override final  String? updatedAt;
@override final  String? confirmedAt;
@override final  String? collectedAt;
@override final  String? processedAt;
@override final  String? readyAt;
@override final  String? returnedAt;
@override final  String? completedAt;
@override final  String? canceledAt;
@override final  String? cancelReason;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderCopyWith<_Order> get copyWith => __$OrderCopyWithImpl<_Order>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Order&&(identical(other.id, id) || other.id == id)&&(identical(other.orderCode, orderCode) || other.orderCode == orderCode)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.type, type) || other.type == type)&&(identical(other.serviceCategory, serviceCategory) || other.serviceCategory == serviceCategory)&&(identical(other.pricingType, pricingType) || other.pricingType == pricingType)&&(identical(other.lockerId, lockerId) || other.lockerId == lockerId)&&(identical(other.locker, locker) || other.locker == locker)&&(identical(other.lockerName, lockerName) || other.lockerName == lockerName)&&(identical(other.lockerCode, lockerCode) || other.lockerCode == lockerCode)&&(identical(other.boxId, boxId) || other.boxId == boxId)&&(identical(other.boxNumber, boxNumber) || other.boxNumber == boxNumber)&&(identical(other.sendBoxNumber, sendBoxNumber) || other.sendBoxNumber == sendBoxNumber)&&(identical(other.receiveBoxNumber, receiveBoxNumber) || other.receiveBoxNumber == receiveBoxNumber)&&const DeepCollectionEquality().equals(other._boxes, _boxes)&&(identical(other.status, status) || other.status == status)&&(identical(other.pin, pin) || other.pin == pin)&&(identical(other.pinCode, pinCode) || other.pinCode == pinCode)&&const DeepCollectionEquality().equals(other._customer, _customer)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.senderPhone, senderPhone) || other.senderPhone == senderPhone)&&(identical(other.receiverId, receiverId) || other.receiverId == receiverId)&&(identical(other.receiverName, receiverName) || other.receiverName == receiverName)&&(identical(other.receiverPhone, receiverPhone) || other.receiverPhone == receiverPhone)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.originalPrice, originalPrice) || other.originalPrice == originalPrice)&&(identical(other.storagePrice, storagePrice) || other.storagePrice == storagePrice)&&const DeepCollectionEquality().equals(other.estimatedPrice, estimatedPrice)&&(identical(other.actualPrice, actualPrice) || other.actualPrice == actualPrice)&&(identical(other.discountAmount, discountAmount) || other.discountAmount == discountAmount)&&(identical(other.priceBreakdown, priceBreakdown) || other.priceBreakdown == priceBreakdown)&&(identical(other.promotionCode, promotionCode) || other.promotionCode == promotionCode)&&const DeepCollectionEquality().equals(other._appliedPromotionCodes, _appliedPromotionCodes)&&(identical(other.promotionDiscount, promotionDiscount) || other.promotionDiscount == promotionDiscount)&&(identical(other.discount, discount) || other.discount == discount)&&(identical(other.promotionInfo, promotionInfo) || other.promotionInfo == promotionInfo)&&const DeepCollectionEquality().equals(other._promotion, _promotion)&&(identical(other.estimatedWeight, estimatedWeight) || other.estimatedWeight == estimatedWeight)&&(identical(other.actualWeight, actualWeight) || other.actualWeight == actualWeight)&&(identical(other.weightUnit, weightUnit) || other.weightUnit == weightUnit)&&(identical(other.isOvertime, isOvertime) || other.isOvertime == isOvertime)&&(identical(other.overtimeHours, overtimeHours) || other.overtimeHours == overtimeHours)&&(identical(other.extraFee, extraFee) || other.extraFee == extraFee)&&(identical(other.isPaid, isPaid) || other.isPaid == isPaid)&&(identical(other.paymentRequired, paymentRequired) || other.paymentRequired == paymentRequired)&&const DeepCollectionEquality().equals(other._payment, _payment)&&(identical(other.nextAction, nextAction) || other.nextAction == nextAction)&&(identical(other.nextActionMessage, nextActionMessage) || other.nextActionMessage == nextActionMessage)&&const DeepCollectionEquality().equals(other._items, _items)&&const DeepCollectionEquality().equals(other._orderDetails, _orderDetails)&&const DeepCollectionEquality().equals(other._services, _services)&&(identical(other.customerNote, customerNote) || other.customerNote == customerNote)&&(identical(other.staffNote, staffNote) || other.staffNote == staffNote)&&(identical(other.deliveryAddress, deliveryAddress) || other.deliveryAddress == deliveryAddress)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.intendedReceiveAt, intendedReceiveAt) || other.intendedReceiveAt == intendedReceiveAt)&&(identical(other.pickupDeadline, pickupDeadline) || other.pickupDeadline == pickupDeadline)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.confirmedAt, confirmedAt) || other.confirmedAt == confirmedAt)&&(identical(other.collectedAt, collectedAt) || other.collectedAt == collectedAt)&&(identical(other.processedAt, processedAt) || other.processedAt == processedAt)&&(identical(other.readyAt, readyAt) || other.readyAt == readyAt)&&(identical(other.returnedAt, returnedAt) || other.returnedAt == returnedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.canceledAt, canceledAt) || other.canceledAt == canceledAt)&&(identical(other.cancelReason, cancelReason) || other.cancelReason == cancelReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,orderCode,userId,type,serviceCategory,pricingType,lockerId,locker,lockerName,lockerCode,boxId,boxNumber,sendBoxNumber,receiveBoxNumber,const DeepCollectionEquality().hash(_boxes),status,pin,pinCode,const DeepCollectionEquality().hash(_customer),senderId,senderName,senderPhone,receiverId,receiverName,receiverPhone,totalAmount,totalPrice,originalPrice,storagePrice,const DeepCollectionEquality().hash(estimatedPrice),actualPrice,discountAmount,priceBreakdown,promotionCode,const DeepCollectionEquality().hash(_appliedPromotionCodes),promotionDiscount,discount,promotionInfo,const DeepCollectionEquality().hash(_promotion),estimatedWeight,actualWeight,weightUnit,isOvertime,overtimeHours,extraFee,isPaid,paymentRequired,const DeepCollectionEquality().hash(_payment),nextAction,nextActionMessage,const DeepCollectionEquality().hash(_items),const DeepCollectionEquality().hash(_orderDetails),const DeepCollectionEquality().hash(_services),customerNote,staffNote,deliveryAddress,expiresAt,intendedReceiveAt,pickupDeadline,createdAt,updatedAt,confirmedAt,collectedAt,processedAt,readyAt,returnedAt,completedAt,canceledAt,cancelReason]);

@override
String toString() {
  return 'Order(id: $id, orderCode: $orderCode, userId: $userId, type: $type, serviceCategory: $serviceCategory, pricingType: $pricingType, lockerId: $lockerId, locker: $locker, lockerName: $lockerName, lockerCode: $lockerCode, boxId: $boxId, boxNumber: $boxNumber, sendBoxNumber: $sendBoxNumber, receiveBoxNumber: $receiveBoxNumber, boxes: $boxes, status: $status, pin: $pin, pinCode: $pinCode, customer: $customer, senderId: $senderId, senderName: $senderName, senderPhone: $senderPhone, receiverId: $receiverId, receiverName: $receiverName, receiverPhone: $receiverPhone, totalAmount: $totalAmount, totalPrice: $totalPrice, originalPrice: $originalPrice, storagePrice: $storagePrice, estimatedPrice: $estimatedPrice, actualPrice: $actualPrice, discountAmount: $discountAmount, priceBreakdown: $priceBreakdown, promotionCode: $promotionCode, appliedPromotionCodes: $appliedPromotionCodes, promotionDiscount: $promotionDiscount, discount: $discount, promotionInfo: $promotionInfo, promotion: $promotion, estimatedWeight: $estimatedWeight, actualWeight: $actualWeight, weightUnit: $weightUnit, isOvertime: $isOvertime, overtimeHours: $overtimeHours, extraFee: $extraFee, isPaid: $isPaid, paymentRequired: $paymentRequired, payment: $payment, nextAction: $nextAction, nextActionMessage: $nextActionMessage, items: $items, orderDetails: $orderDetails, services: $services, customerNote: $customerNote, staffNote: $staffNote, deliveryAddress: $deliveryAddress, expiresAt: $expiresAt, intendedReceiveAt: $intendedReceiveAt, pickupDeadline: $pickupDeadline, createdAt: $createdAt, updatedAt: $updatedAt, confirmedAt: $confirmedAt, collectedAt: $collectedAt, processedAt: $processedAt, readyAt: $readyAt, returnedAt: $returnedAt, completedAt: $completedAt, canceledAt: $canceledAt, cancelReason: $cancelReason)';
}


}

/// @nodoc
abstract mixin class _$OrderCopyWith<$Res> implements $OrderCopyWith<$Res> {
  factory _$OrderCopyWith(_Order value, $Res Function(_Order) _then) = __$OrderCopyWithImpl;
@override @useResult
$Res call({
 int id, String? orderCode, int userId, OrderType? type, ServiceCategory? serviceCategory, PricingType? pricingType, int lockerId, Locker? locker, String? lockerName, String? lockerCode, int boxId, int? boxNumber, int? sendBoxNumber, int? receiveBoxNumber, List<OrderBox>? boxes, OrderStatus status, String? pin, String? pinCode, Map<String, dynamic>? customer, int? senderId, String? senderName, String? senderPhone, int? receiverId, String? receiverName, String? receiverPhone, double totalAmount, double? totalPrice, double? originalPrice, double? storagePrice, dynamic estimatedPrice, double? actualPrice, double? discountAmount, PriceBreakdown? priceBreakdown, String? promotionCode, List<String>? appliedPromotionCodes, double? promotionDiscount, double? discount, PromotionInfo? promotionInfo, Map<String, dynamic>? promotion, double? estimatedWeight, double? actualWeight, String? weightUnit, bool? isOvertime, double? overtimeHours, double? extraFee, bool? isPaid, bool? paymentRequired, Map<String, dynamic>? payment, String? nextAction, String? nextActionMessage, List<OrderItem>? items, List<OrderItem>? orderDetails, List<LaundryService>? services, String? customerNote, String? staffNote, String? deliveryAddress, String? expiresAt, String? intendedReceiveAt, String? pickupDeadline, String? createdAt, String? updatedAt, String? confirmedAt, String? collectedAt, String? processedAt, String? readyAt, String? returnedAt, String? completedAt, String? canceledAt, String? cancelReason
});


@override $LockerCopyWith<$Res>? get locker;@override $PriceBreakdownCopyWith<$Res>? get priceBreakdown;@override $PromotionInfoCopyWith<$Res>? get promotionInfo;

}
/// @nodoc
class __$OrderCopyWithImpl<$Res>
    implements _$OrderCopyWith<$Res> {
  __$OrderCopyWithImpl(this._self, this._then);

  final _Order _self;
  final $Res Function(_Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orderCode = freezed,Object? userId = null,Object? type = freezed,Object? serviceCategory = freezed,Object? pricingType = freezed,Object? lockerId = null,Object? locker = freezed,Object? lockerName = freezed,Object? lockerCode = freezed,Object? boxId = null,Object? boxNumber = freezed,Object? sendBoxNumber = freezed,Object? receiveBoxNumber = freezed,Object? boxes = freezed,Object? status = null,Object? pin = freezed,Object? pinCode = freezed,Object? customer = freezed,Object? senderId = freezed,Object? senderName = freezed,Object? senderPhone = freezed,Object? receiverId = freezed,Object? receiverName = freezed,Object? receiverPhone = freezed,Object? totalAmount = null,Object? totalPrice = freezed,Object? originalPrice = freezed,Object? storagePrice = freezed,Object? estimatedPrice = freezed,Object? actualPrice = freezed,Object? discountAmount = freezed,Object? priceBreakdown = freezed,Object? promotionCode = freezed,Object? appliedPromotionCodes = freezed,Object? promotionDiscount = freezed,Object? discount = freezed,Object? promotionInfo = freezed,Object? promotion = freezed,Object? estimatedWeight = freezed,Object? actualWeight = freezed,Object? weightUnit = freezed,Object? isOvertime = freezed,Object? overtimeHours = freezed,Object? extraFee = freezed,Object? isPaid = freezed,Object? paymentRequired = freezed,Object? payment = freezed,Object? nextAction = freezed,Object? nextActionMessage = freezed,Object? items = freezed,Object? orderDetails = freezed,Object? services = freezed,Object? customerNote = freezed,Object? staffNote = freezed,Object? deliveryAddress = freezed,Object? expiresAt = freezed,Object? intendedReceiveAt = freezed,Object? pickupDeadline = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? confirmedAt = freezed,Object? collectedAt = freezed,Object? processedAt = freezed,Object? readyAt = freezed,Object? returnedAt = freezed,Object? completedAt = freezed,Object? canceledAt = freezed,Object? cancelReason = freezed,}) {
  return _then(_Order(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,orderCode: freezed == orderCode ? _self.orderCode : orderCode // ignore: cast_nullable_to_non_nullable
as String?,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as OrderType?,serviceCategory: freezed == serviceCategory ? _self.serviceCategory : serviceCategory // ignore: cast_nullable_to_non_nullable
as ServiceCategory?,pricingType: freezed == pricingType ? _self.pricingType : pricingType // ignore: cast_nullable_to_non_nullable
as PricingType?,lockerId: null == lockerId ? _self.lockerId : lockerId // ignore: cast_nullable_to_non_nullable
as int,locker: freezed == locker ? _self.locker : locker // ignore: cast_nullable_to_non_nullable
as Locker?,lockerName: freezed == lockerName ? _self.lockerName : lockerName // ignore: cast_nullable_to_non_nullable
as String?,lockerCode: freezed == lockerCode ? _self.lockerCode : lockerCode // ignore: cast_nullable_to_non_nullable
as String?,boxId: null == boxId ? _self.boxId : boxId // ignore: cast_nullable_to_non_nullable
as int,boxNumber: freezed == boxNumber ? _self.boxNumber : boxNumber // ignore: cast_nullable_to_non_nullable
as int?,sendBoxNumber: freezed == sendBoxNumber ? _self.sendBoxNumber : sendBoxNumber // ignore: cast_nullable_to_non_nullable
as int?,receiveBoxNumber: freezed == receiveBoxNumber ? _self.receiveBoxNumber : receiveBoxNumber // ignore: cast_nullable_to_non_nullable
as int?,boxes: freezed == boxes ? _self._boxes : boxes // ignore: cast_nullable_to_non_nullable
as List<OrderBox>?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,pin: freezed == pin ? _self.pin : pin // ignore: cast_nullable_to_non_nullable
as String?,pinCode: freezed == pinCode ? _self.pinCode : pinCode // ignore: cast_nullable_to_non_nullable
as String?,customer: freezed == customer ? _self._customer : customer // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,senderId: freezed == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as int?,senderName: freezed == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String?,senderPhone: freezed == senderPhone ? _self.senderPhone : senderPhone // ignore: cast_nullable_to_non_nullable
as String?,receiverId: freezed == receiverId ? _self.receiverId : receiverId // ignore: cast_nullable_to_non_nullable
as int?,receiverName: freezed == receiverName ? _self.receiverName : receiverName // ignore: cast_nullable_to_non_nullable
as String?,receiverPhone: freezed == receiverPhone ? _self.receiverPhone : receiverPhone // ignore: cast_nullable_to_non_nullable
as String?,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,totalPrice: freezed == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double?,originalPrice: freezed == originalPrice ? _self.originalPrice : originalPrice // ignore: cast_nullable_to_non_nullable
as double?,storagePrice: freezed == storagePrice ? _self.storagePrice : storagePrice // ignore: cast_nullable_to_non_nullable
as double?,estimatedPrice: freezed == estimatedPrice ? _self.estimatedPrice : estimatedPrice // ignore: cast_nullable_to_non_nullable
as dynamic,actualPrice: freezed == actualPrice ? _self.actualPrice : actualPrice // ignore: cast_nullable_to_non_nullable
as double?,discountAmount: freezed == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as double?,priceBreakdown: freezed == priceBreakdown ? _self.priceBreakdown : priceBreakdown // ignore: cast_nullable_to_non_nullable
as PriceBreakdown?,promotionCode: freezed == promotionCode ? _self.promotionCode : promotionCode // ignore: cast_nullable_to_non_nullable
as String?,appliedPromotionCodes: freezed == appliedPromotionCodes ? _self._appliedPromotionCodes : appliedPromotionCodes // ignore: cast_nullable_to_non_nullable
as List<String>?,promotionDiscount: freezed == promotionDiscount ? _self.promotionDiscount : promotionDiscount // ignore: cast_nullable_to_non_nullable
as double?,discount: freezed == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as double?,promotionInfo: freezed == promotionInfo ? _self.promotionInfo : promotionInfo // ignore: cast_nullable_to_non_nullable
as PromotionInfo?,promotion: freezed == promotion ? _self._promotion : promotion // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,estimatedWeight: freezed == estimatedWeight ? _self.estimatedWeight : estimatedWeight // ignore: cast_nullable_to_non_nullable
as double?,actualWeight: freezed == actualWeight ? _self.actualWeight : actualWeight // ignore: cast_nullable_to_non_nullable
as double?,weightUnit: freezed == weightUnit ? _self.weightUnit : weightUnit // ignore: cast_nullable_to_non_nullable
as String?,isOvertime: freezed == isOvertime ? _self.isOvertime : isOvertime // ignore: cast_nullable_to_non_nullable
as bool?,overtimeHours: freezed == overtimeHours ? _self.overtimeHours : overtimeHours // ignore: cast_nullable_to_non_nullable
as double?,extraFee: freezed == extraFee ? _self.extraFee : extraFee // ignore: cast_nullable_to_non_nullable
as double?,isPaid: freezed == isPaid ? _self.isPaid : isPaid // ignore: cast_nullable_to_non_nullable
as bool?,paymentRequired: freezed == paymentRequired ? _self.paymentRequired : paymentRequired // ignore: cast_nullable_to_non_nullable
as bool?,payment: freezed == payment ? _self._payment : payment // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,nextAction: freezed == nextAction ? _self.nextAction : nextAction // ignore: cast_nullable_to_non_nullable
as String?,nextActionMessage: freezed == nextActionMessage ? _self.nextActionMessage : nextActionMessage // ignore: cast_nullable_to_non_nullable
as String?,items: freezed == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItem>?,orderDetails: freezed == orderDetails ? _self._orderDetails : orderDetails // ignore: cast_nullable_to_non_nullable
as List<OrderItem>?,services: freezed == services ? _self._services : services // ignore: cast_nullable_to_non_nullable
as List<LaundryService>?,customerNote: freezed == customerNote ? _self.customerNote : customerNote // ignore: cast_nullable_to_non_nullable
as String?,staffNote: freezed == staffNote ? _self.staffNote : staffNote // ignore: cast_nullable_to_non_nullable
as String?,deliveryAddress: freezed == deliveryAddress ? _self.deliveryAddress : deliveryAddress // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as String?,intendedReceiveAt: freezed == intendedReceiveAt ? _self.intendedReceiveAt : intendedReceiveAt // ignore: cast_nullable_to_non_nullable
as String?,pickupDeadline: freezed == pickupDeadline ? _self.pickupDeadline : pickupDeadline // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,confirmedAt: freezed == confirmedAt ? _self.confirmedAt : confirmedAt // ignore: cast_nullable_to_non_nullable
as String?,collectedAt: freezed == collectedAt ? _self.collectedAt : collectedAt // ignore: cast_nullable_to_non_nullable
as String?,processedAt: freezed == processedAt ? _self.processedAt : processedAt // ignore: cast_nullable_to_non_nullable
as String?,readyAt: freezed == readyAt ? _self.readyAt : readyAt // ignore: cast_nullable_to_non_nullable
as String?,returnedAt: freezed == returnedAt ? _self.returnedAt : returnedAt // ignore: cast_nullable_to_non_nullable
as String?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as String?,canceledAt: freezed == canceledAt ? _self.canceledAt : canceledAt // ignore: cast_nullable_to_non_nullable
as String?,cancelReason: freezed == cancelReason ? _self.cancelReason : cancelReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LockerCopyWith<$Res>? get locker {
    if (_self.locker == null) {
    return null;
  }

  return $LockerCopyWith<$Res>(_self.locker!, (value) {
    return _then(_self.copyWith(locker: value));
  });
}/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceBreakdownCopyWith<$Res>? get priceBreakdown {
    if (_self.priceBreakdown == null) {
    return null;
  }

  return $PriceBreakdownCopyWith<$Res>(_self.priceBreakdown!, (value) {
    return _then(_self.copyWith(priceBreakdown: value));
  });
}/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PromotionInfoCopyWith<$Res>? get promotionInfo {
    if (_self.promotionInfo == null) {
    return null;
  }

  return $PromotionInfoCopyWith<$Res>(_self.promotionInfo!, (value) {
    return _then(_self.copyWith(promotionInfo: value));
  });
}
}


/// @nodoc
mixin _$OrderBox {

 int get id; String get boxNumber; String get size;
/// Create a copy of OrderBox
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderBoxCopyWith<OrderBox> get copyWith => _$OrderBoxCopyWithImpl<OrderBox>(this as OrderBox, _$identity);

  /// Serializes this OrderBox to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderBox&&(identical(other.id, id) || other.id == id)&&(identical(other.boxNumber, boxNumber) || other.boxNumber == boxNumber)&&(identical(other.size, size) || other.size == size));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,boxNumber,size);

@override
String toString() {
  return 'OrderBox(id: $id, boxNumber: $boxNumber, size: $size)';
}


}

/// @nodoc
abstract mixin class $OrderBoxCopyWith<$Res>  {
  factory $OrderBoxCopyWith(OrderBox value, $Res Function(OrderBox) _then) = _$OrderBoxCopyWithImpl;
@useResult
$Res call({
 int id, String boxNumber, String size
});




}
/// @nodoc
class _$OrderBoxCopyWithImpl<$Res>
    implements $OrderBoxCopyWith<$Res> {
  _$OrderBoxCopyWithImpl(this._self, this._then);

  final OrderBox _self;
  final $Res Function(OrderBox) _then;

/// Create a copy of OrderBox
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? boxNumber = null,Object? size = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,boxNumber: null == boxNumber ? _self.boxNumber : boxNumber // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderBox].
extension OrderBoxPatterns on OrderBox {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderBox value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderBox() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderBox value)  $default,){
final _that = this;
switch (_that) {
case _OrderBox():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderBox value)?  $default,){
final _that = this;
switch (_that) {
case _OrderBox() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String boxNumber,  String size)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderBox() when $default != null:
return $default(_that.id,_that.boxNumber,_that.size);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String boxNumber,  String size)  $default,) {final _that = this;
switch (_that) {
case _OrderBox():
return $default(_that.id,_that.boxNumber,_that.size);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String boxNumber,  String size)?  $default,) {final _that = this;
switch (_that) {
case _OrderBox() when $default != null:
return $default(_that.id,_that.boxNumber,_that.size);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderBox implements OrderBox {
  const _OrderBox({required this.id, required this.boxNumber, required this.size});
  factory _OrderBox.fromJson(Map<String, dynamic> json) => _$OrderBoxFromJson(json);

@override final  int id;
@override final  String boxNumber;
@override final  String size;

/// Create a copy of OrderBox
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderBoxCopyWith<_OrderBox> get copyWith => __$OrderBoxCopyWithImpl<_OrderBox>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderBoxToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderBox&&(identical(other.id, id) || other.id == id)&&(identical(other.boxNumber, boxNumber) || other.boxNumber == boxNumber)&&(identical(other.size, size) || other.size == size));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,boxNumber,size);

@override
String toString() {
  return 'OrderBox(id: $id, boxNumber: $boxNumber, size: $size)';
}


}

/// @nodoc
abstract mixin class _$OrderBoxCopyWith<$Res> implements $OrderBoxCopyWith<$Res> {
  factory _$OrderBoxCopyWith(_OrderBox value, $Res Function(_OrderBox) _then) = __$OrderBoxCopyWithImpl;
@override @useResult
$Res call({
 int id, String boxNumber, String size
});




}
/// @nodoc
class __$OrderBoxCopyWithImpl<$Res>
    implements _$OrderBoxCopyWith<$Res> {
  __$OrderBoxCopyWithImpl(this._self, this._then);

  final _OrderBox _self;
  final $Res Function(_OrderBox) _then;

/// Create a copy of OrderBox
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? boxNumber = null,Object? size = null,}) {
  return _then(_OrderBox(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,boxNumber: null == boxNumber ? _self.boxNumber : boxNumber // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$OrderItem {

 int get id; int get serviceId; String get serviceName; int get quantity; double get price; double get subtotal;
/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderItemCopyWith<OrderItem> get copyWith => _$OrderItemCopyWithImpl<OrderItem>(this as OrderItem, _$identity);

  /// Serializes this OrderItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderItem&&(identical(other.id, id) || other.id == id)&&(identical(other.serviceId, serviceId) || other.serviceId == serviceId)&&(identical(other.serviceName, serviceName) || other.serviceName == serviceName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.price, price) || other.price == price)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,serviceId,serviceName,quantity,price,subtotal);

@override
String toString() {
  return 'OrderItem(id: $id, serviceId: $serviceId, serviceName: $serviceName, quantity: $quantity, price: $price, subtotal: $subtotal)';
}


}

/// @nodoc
abstract mixin class $OrderItemCopyWith<$Res>  {
  factory $OrderItemCopyWith(OrderItem value, $Res Function(OrderItem) _then) = _$OrderItemCopyWithImpl;
@useResult
$Res call({
 int id, int serviceId, String serviceName, int quantity, double price, double subtotal
});




}
/// @nodoc
class _$OrderItemCopyWithImpl<$Res>
    implements $OrderItemCopyWith<$Res> {
  _$OrderItemCopyWithImpl(this._self, this._then);

  final OrderItem _self;
  final $Res Function(OrderItem) _then;

/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? serviceId = null,Object? serviceName = null,Object? quantity = null,Object? price = null,Object? subtotal = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,serviceId: null == serviceId ? _self.serviceId : serviceId // ignore: cast_nullable_to_non_nullable
as int,serviceName: null == serviceName ? _self.serviceName : serviceName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderItem].
extension OrderItemPatterns on OrderItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderItem value)  $default,){
final _that = this;
switch (_that) {
case _OrderItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderItem value)?  $default,){
final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int serviceId,  String serviceName,  int quantity,  double price,  double subtotal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
return $default(_that.id,_that.serviceId,_that.serviceName,_that.quantity,_that.price,_that.subtotal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int serviceId,  String serviceName,  int quantity,  double price,  double subtotal)  $default,) {final _that = this;
switch (_that) {
case _OrderItem():
return $default(_that.id,_that.serviceId,_that.serviceName,_that.quantity,_that.price,_that.subtotal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int serviceId,  String serviceName,  int quantity,  double price,  double subtotal)?  $default,) {final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
return $default(_that.id,_that.serviceId,_that.serviceName,_that.quantity,_that.price,_that.subtotal);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderItem implements OrderItem {
  const _OrderItem({required this.id, required this.serviceId, required this.serviceName, required this.quantity, required this.price, required this.subtotal});
  factory _OrderItem.fromJson(Map<String, dynamic> json) => _$OrderItemFromJson(json);

@override final  int id;
@override final  int serviceId;
@override final  String serviceName;
@override final  int quantity;
@override final  double price;
@override final  double subtotal;

/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderItemCopyWith<_OrderItem> get copyWith => __$OrderItemCopyWithImpl<_OrderItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderItem&&(identical(other.id, id) || other.id == id)&&(identical(other.serviceId, serviceId) || other.serviceId == serviceId)&&(identical(other.serviceName, serviceName) || other.serviceName == serviceName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.price, price) || other.price == price)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,serviceId,serviceName,quantity,price,subtotal);

@override
String toString() {
  return 'OrderItem(id: $id, serviceId: $serviceId, serviceName: $serviceName, quantity: $quantity, price: $price, subtotal: $subtotal)';
}


}

/// @nodoc
abstract mixin class _$OrderItemCopyWith<$Res> implements $OrderItemCopyWith<$Res> {
  factory _$OrderItemCopyWith(_OrderItem value, $Res Function(_OrderItem) _then) = __$OrderItemCopyWithImpl;
@override @useResult
$Res call({
 int id, int serviceId, String serviceName, int quantity, double price, double subtotal
});




}
/// @nodoc
class __$OrderItemCopyWithImpl<$Res>
    implements _$OrderItemCopyWith<$Res> {
  __$OrderItemCopyWithImpl(this._self, this._then);

  final _OrderItem _self;
  final $Res Function(_OrderItem) _then;

/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? serviceId = null,Object? serviceName = null,Object? quantity = null,Object? price = null,Object? subtotal = null,}) {
  return _then(_OrderItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,serviceId: null == serviceId ? _self.serviceId : serviceId // ignore: cast_nullable_to_non_nullable
as int,serviceName: null == serviceName ? _self.serviceName : serviceName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$OrderTrackingDetail {

 int get orderId; OrderStatus get status; String get statusDescription; String? get pinCode; String? get lockerName; String? get lockerCode; int? get boxNumber; String get createdAt; String get updatedAt; String? get estimatedReadyAt; String? get completedAt; bool get isPaid; String get nextAction;
/// Create a copy of OrderTrackingDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderTrackingDetailCopyWith<OrderTrackingDetail> get copyWith => _$OrderTrackingDetailCopyWithImpl<OrderTrackingDetail>(this as OrderTrackingDetail, _$identity);

  /// Serializes this OrderTrackingDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderTrackingDetail&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.status, status) || other.status == status)&&(identical(other.statusDescription, statusDescription) || other.statusDescription == statusDescription)&&(identical(other.pinCode, pinCode) || other.pinCode == pinCode)&&(identical(other.lockerName, lockerName) || other.lockerName == lockerName)&&(identical(other.lockerCode, lockerCode) || other.lockerCode == lockerCode)&&(identical(other.boxNumber, boxNumber) || other.boxNumber == boxNumber)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.estimatedReadyAt, estimatedReadyAt) || other.estimatedReadyAt == estimatedReadyAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.isPaid, isPaid) || other.isPaid == isPaid)&&(identical(other.nextAction, nextAction) || other.nextAction == nextAction));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,orderId,status,statusDescription,pinCode,lockerName,lockerCode,boxNumber,createdAt,updatedAt,estimatedReadyAt,completedAt,isPaid,nextAction);

@override
String toString() {
  return 'OrderTrackingDetail(orderId: $orderId, status: $status, statusDescription: $statusDescription, pinCode: $pinCode, lockerName: $lockerName, lockerCode: $lockerCode, boxNumber: $boxNumber, createdAt: $createdAt, updatedAt: $updatedAt, estimatedReadyAt: $estimatedReadyAt, completedAt: $completedAt, isPaid: $isPaid, nextAction: $nextAction)';
}


}

/// @nodoc
abstract mixin class $OrderTrackingDetailCopyWith<$Res>  {
  factory $OrderTrackingDetailCopyWith(OrderTrackingDetail value, $Res Function(OrderTrackingDetail) _then) = _$OrderTrackingDetailCopyWithImpl;
@useResult
$Res call({
 int orderId, OrderStatus status, String statusDescription, String? pinCode, String? lockerName, String? lockerCode, int? boxNumber, String createdAt, String updatedAt, String? estimatedReadyAt, String? completedAt, bool isPaid, String nextAction
});




}
/// @nodoc
class _$OrderTrackingDetailCopyWithImpl<$Res>
    implements $OrderTrackingDetailCopyWith<$Res> {
  _$OrderTrackingDetailCopyWithImpl(this._self, this._then);

  final OrderTrackingDetail _self;
  final $Res Function(OrderTrackingDetail) _then;

/// Create a copy of OrderTrackingDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? orderId = null,Object? status = null,Object? statusDescription = null,Object? pinCode = freezed,Object? lockerName = freezed,Object? lockerCode = freezed,Object? boxNumber = freezed,Object? createdAt = null,Object? updatedAt = null,Object? estimatedReadyAt = freezed,Object? completedAt = freezed,Object? isPaid = null,Object? nextAction = null,}) {
  return _then(_self.copyWith(
orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,statusDescription: null == statusDescription ? _self.statusDescription : statusDescription // ignore: cast_nullable_to_non_nullable
as String,pinCode: freezed == pinCode ? _self.pinCode : pinCode // ignore: cast_nullable_to_non_nullable
as String?,lockerName: freezed == lockerName ? _self.lockerName : lockerName // ignore: cast_nullable_to_non_nullable
as String?,lockerCode: freezed == lockerCode ? _self.lockerCode : lockerCode // ignore: cast_nullable_to_non_nullable
as String?,boxNumber: freezed == boxNumber ? _self.boxNumber : boxNumber // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,estimatedReadyAt: freezed == estimatedReadyAt ? _self.estimatedReadyAt : estimatedReadyAt // ignore: cast_nullable_to_non_nullable
as String?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as String?,isPaid: null == isPaid ? _self.isPaid : isPaid // ignore: cast_nullable_to_non_nullable
as bool,nextAction: null == nextAction ? _self.nextAction : nextAction // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderTrackingDetail].
extension OrderTrackingDetailPatterns on OrderTrackingDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderTrackingDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderTrackingDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderTrackingDetail value)  $default,){
final _that = this;
switch (_that) {
case _OrderTrackingDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderTrackingDetail value)?  $default,){
final _that = this;
switch (_that) {
case _OrderTrackingDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int orderId,  OrderStatus status,  String statusDescription,  String? pinCode,  String? lockerName,  String? lockerCode,  int? boxNumber,  String createdAt,  String updatedAt,  String? estimatedReadyAt,  String? completedAt,  bool isPaid,  String nextAction)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderTrackingDetail() when $default != null:
return $default(_that.orderId,_that.status,_that.statusDescription,_that.pinCode,_that.lockerName,_that.lockerCode,_that.boxNumber,_that.createdAt,_that.updatedAt,_that.estimatedReadyAt,_that.completedAt,_that.isPaid,_that.nextAction);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int orderId,  OrderStatus status,  String statusDescription,  String? pinCode,  String? lockerName,  String? lockerCode,  int? boxNumber,  String createdAt,  String updatedAt,  String? estimatedReadyAt,  String? completedAt,  bool isPaid,  String nextAction)  $default,) {final _that = this;
switch (_that) {
case _OrderTrackingDetail():
return $default(_that.orderId,_that.status,_that.statusDescription,_that.pinCode,_that.lockerName,_that.lockerCode,_that.boxNumber,_that.createdAt,_that.updatedAt,_that.estimatedReadyAt,_that.completedAt,_that.isPaid,_that.nextAction);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int orderId,  OrderStatus status,  String statusDescription,  String? pinCode,  String? lockerName,  String? lockerCode,  int? boxNumber,  String createdAt,  String updatedAt,  String? estimatedReadyAt,  String? completedAt,  bool isPaid,  String nextAction)?  $default,) {final _that = this;
switch (_that) {
case _OrderTrackingDetail() when $default != null:
return $default(_that.orderId,_that.status,_that.statusDescription,_that.pinCode,_that.lockerName,_that.lockerCode,_that.boxNumber,_that.createdAt,_that.updatedAt,_that.estimatedReadyAt,_that.completedAt,_that.isPaid,_that.nextAction);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderTrackingDetail implements OrderTrackingDetail {
  const _OrderTrackingDetail({required this.orderId, required this.status, required this.statusDescription, this.pinCode, this.lockerName, this.lockerCode, this.boxNumber, required this.createdAt, required this.updatedAt, this.estimatedReadyAt, this.completedAt, required this.isPaid, required this.nextAction});
  factory _OrderTrackingDetail.fromJson(Map<String, dynamic> json) => _$OrderTrackingDetailFromJson(json);

@override final  int orderId;
@override final  OrderStatus status;
@override final  String statusDescription;
@override final  String? pinCode;
@override final  String? lockerName;
@override final  String? lockerCode;
@override final  int? boxNumber;
@override final  String createdAt;
@override final  String updatedAt;
@override final  String? estimatedReadyAt;
@override final  String? completedAt;
@override final  bool isPaid;
@override final  String nextAction;

/// Create a copy of OrderTrackingDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderTrackingDetailCopyWith<_OrderTrackingDetail> get copyWith => __$OrderTrackingDetailCopyWithImpl<_OrderTrackingDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderTrackingDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderTrackingDetail&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.status, status) || other.status == status)&&(identical(other.statusDescription, statusDescription) || other.statusDescription == statusDescription)&&(identical(other.pinCode, pinCode) || other.pinCode == pinCode)&&(identical(other.lockerName, lockerName) || other.lockerName == lockerName)&&(identical(other.lockerCode, lockerCode) || other.lockerCode == lockerCode)&&(identical(other.boxNumber, boxNumber) || other.boxNumber == boxNumber)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.estimatedReadyAt, estimatedReadyAt) || other.estimatedReadyAt == estimatedReadyAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.isPaid, isPaid) || other.isPaid == isPaid)&&(identical(other.nextAction, nextAction) || other.nextAction == nextAction));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,orderId,status,statusDescription,pinCode,lockerName,lockerCode,boxNumber,createdAt,updatedAt,estimatedReadyAt,completedAt,isPaid,nextAction);

@override
String toString() {
  return 'OrderTrackingDetail(orderId: $orderId, status: $status, statusDescription: $statusDescription, pinCode: $pinCode, lockerName: $lockerName, lockerCode: $lockerCode, boxNumber: $boxNumber, createdAt: $createdAt, updatedAt: $updatedAt, estimatedReadyAt: $estimatedReadyAt, completedAt: $completedAt, isPaid: $isPaid, nextAction: $nextAction)';
}


}

/// @nodoc
abstract mixin class _$OrderTrackingDetailCopyWith<$Res> implements $OrderTrackingDetailCopyWith<$Res> {
  factory _$OrderTrackingDetailCopyWith(_OrderTrackingDetail value, $Res Function(_OrderTrackingDetail) _then) = __$OrderTrackingDetailCopyWithImpl;
@override @useResult
$Res call({
 int orderId, OrderStatus status, String statusDescription, String? pinCode, String? lockerName, String? lockerCode, int? boxNumber, String createdAt, String updatedAt, String? estimatedReadyAt, String? completedAt, bool isPaid, String nextAction
});




}
/// @nodoc
class __$OrderTrackingDetailCopyWithImpl<$Res>
    implements _$OrderTrackingDetailCopyWith<$Res> {
  __$OrderTrackingDetailCopyWithImpl(this._self, this._then);

  final _OrderTrackingDetail _self;
  final $Res Function(_OrderTrackingDetail) _then;

/// Create a copy of OrderTrackingDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? orderId = null,Object? status = null,Object? statusDescription = null,Object? pinCode = freezed,Object? lockerName = freezed,Object? lockerCode = freezed,Object? boxNumber = freezed,Object? createdAt = null,Object? updatedAt = null,Object? estimatedReadyAt = freezed,Object? completedAt = freezed,Object? isPaid = null,Object? nextAction = null,}) {
  return _then(_OrderTrackingDetail(
orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,statusDescription: null == statusDescription ? _self.statusDescription : statusDescription // ignore: cast_nullable_to_non_nullable
as String,pinCode: freezed == pinCode ? _self.pinCode : pinCode // ignore: cast_nullable_to_non_nullable
as String?,lockerName: freezed == lockerName ? _self.lockerName : lockerName // ignore: cast_nullable_to_non_nullable
as String?,lockerCode: freezed == lockerCode ? _self.lockerCode : lockerCode // ignore: cast_nullable_to_non_nullable
as String?,boxNumber: freezed == boxNumber ? _self.boxNumber : boxNumber // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,estimatedReadyAt: freezed == estimatedReadyAt ? _self.estimatedReadyAt : estimatedReadyAt // ignore: cast_nullable_to_non_nullable
as String?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as String?,isPaid: null == isPaid ? _self.isPaid : isPaid // ignore: cast_nullable_to_non_nullable
as bool,nextAction: null == nextAction ? _self.nextAction : nextAction // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$OrderTimelineEvent {

 String get status; String get title; String get description; String get timestamp; String? get icon; String? get color; String? get actor; String? get metadata;
/// Create a copy of OrderTimelineEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderTimelineEventCopyWith<OrderTimelineEvent> get copyWith => _$OrderTimelineEventCopyWithImpl<OrderTimelineEvent>(this as OrderTimelineEvent, _$identity);

  /// Serializes this OrderTimelineEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderTimelineEvent&&(identical(other.status, status) || other.status == status)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.actor, actor) || other.actor == actor)&&(identical(other.metadata, metadata) || other.metadata == metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,title,description,timestamp,icon,color,actor,metadata);

@override
String toString() {
  return 'OrderTimelineEvent(status: $status, title: $title, description: $description, timestamp: $timestamp, icon: $icon, color: $color, actor: $actor, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $OrderTimelineEventCopyWith<$Res>  {
  factory $OrderTimelineEventCopyWith(OrderTimelineEvent value, $Res Function(OrderTimelineEvent) _then) = _$OrderTimelineEventCopyWithImpl;
@useResult
$Res call({
 String status, String title, String description, String timestamp, String? icon, String? color, String? actor, String? metadata
});




}
/// @nodoc
class _$OrderTimelineEventCopyWithImpl<$Res>
    implements $OrderTimelineEventCopyWith<$Res> {
  _$OrderTimelineEventCopyWithImpl(this._self, this._then);

  final OrderTimelineEvent _self;
  final $Res Function(OrderTimelineEvent) _then;

/// Create a copy of OrderTimelineEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? title = null,Object? description = null,Object? timestamp = null,Object? icon = freezed,Object? color = freezed,Object? actor = freezed,Object? metadata = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,actor: freezed == actor ? _self.actor : actor // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderTimelineEvent].
extension OrderTimelineEventPatterns on OrderTimelineEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderTimelineEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderTimelineEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderTimelineEvent value)  $default,){
final _that = this;
switch (_that) {
case _OrderTimelineEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderTimelineEvent value)?  $default,){
final _that = this;
switch (_that) {
case _OrderTimelineEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String status,  String title,  String description,  String timestamp,  String? icon,  String? color,  String? actor,  String? metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderTimelineEvent() when $default != null:
return $default(_that.status,_that.title,_that.description,_that.timestamp,_that.icon,_that.color,_that.actor,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String status,  String title,  String description,  String timestamp,  String? icon,  String? color,  String? actor,  String? metadata)  $default,) {final _that = this;
switch (_that) {
case _OrderTimelineEvent():
return $default(_that.status,_that.title,_that.description,_that.timestamp,_that.icon,_that.color,_that.actor,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String status,  String title,  String description,  String timestamp,  String? icon,  String? color,  String? actor,  String? metadata)?  $default,) {final _that = this;
switch (_that) {
case _OrderTimelineEvent() when $default != null:
return $default(_that.status,_that.title,_that.description,_that.timestamp,_that.icon,_that.color,_that.actor,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderTimelineEvent implements OrderTimelineEvent {
  const _OrderTimelineEvent({required this.status, required this.title, required this.description, required this.timestamp, this.icon, this.color, this.actor, this.metadata});
  factory _OrderTimelineEvent.fromJson(Map<String, dynamic> json) => _$OrderTimelineEventFromJson(json);

@override final  String status;
@override final  String title;
@override final  String description;
@override final  String timestamp;
@override final  String? icon;
@override final  String? color;
@override final  String? actor;
@override final  String? metadata;

/// Create a copy of OrderTimelineEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderTimelineEventCopyWith<_OrderTimelineEvent> get copyWith => __$OrderTimelineEventCopyWithImpl<_OrderTimelineEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderTimelineEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderTimelineEvent&&(identical(other.status, status) || other.status == status)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.actor, actor) || other.actor == actor)&&(identical(other.metadata, metadata) || other.metadata == metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,title,description,timestamp,icon,color,actor,metadata);

@override
String toString() {
  return 'OrderTimelineEvent(status: $status, title: $title, description: $description, timestamp: $timestamp, icon: $icon, color: $color, actor: $actor, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$OrderTimelineEventCopyWith<$Res> implements $OrderTimelineEventCopyWith<$Res> {
  factory _$OrderTimelineEventCopyWith(_OrderTimelineEvent value, $Res Function(_OrderTimelineEvent) _then) = __$OrderTimelineEventCopyWithImpl;
@override @useResult
$Res call({
 String status, String title, String description, String timestamp, String? icon, String? color, String? actor, String? metadata
});




}
/// @nodoc
class __$OrderTimelineEventCopyWithImpl<$Res>
    implements _$OrderTimelineEventCopyWith<$Res> {
  __$OrderTimelineEventCopyWithImpl(this._self, this._then);

  final _OrderTimelineEvent _self;
  final $Res Function(_OrderTimelineEvent) _then;

/// Create a copy of OrderTimelineEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? title = null,Object? description = null,Object? timestamp = null,Object? icon = freezed,Object? color = freezed,Object? actor = freezed,Object? metadata = freezed,}) {
  return _then(_OrderTimelineEvent(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,actor: freezed == actor ? _self.actor : actor // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$OrderTimelineResponse {

 int get orderId; String get currentStatus; String? get estimatedCompletion; double get progressPercentage; List<OrderTimelineEvent> get events; String? get nextAction; String? get nextActionActor;
/// Create a copy of OrderTimelineResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderTimelineResponseCopyWith<OrderTimelineResponse> get copyWith => _$OrderTimelineResponseCopyWithImpl<OrderTimelineResponse>(this as OrderTimelineResponse, _$identity);

  /// Serializes this OrderTimelineResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderTimelineResponse&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.currentStatus, currentStatus) || other.currentStatus == currentStatus)&&(identical(other.estimatedCompletion, estimatedCompletion) || other.estimatedCompletion == estimatedCompletion)&&(identical(other.progressPercentage, progressPercentage) || other.progressPercentage == progressPercentage)&&const DeepCollectionEquality().equals(other.events, events)&&(identical(other.nextAction, nextAction) || other.nextAction == nextAction)&&(identical(other.nextActionActor, nextActionActor) || other.nextActionActor == nextActionActor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,orderId,currentStatus,estimatedCompletion,progressPercentage,const DeepCollectionEquality().hash(events),nextAction,nextActionActor);

@override
String toString() {
  return 'OrderTimelineResponse(orderId: $orderId, currentStatus: $currentStatus, estimatedCompletion: $estimatedCompletion, progressPercentage: $progressPercentage, events: $events, nextAction: $nextAction, nextActionActor: $nextActionActor)';
}


}

/// @nodoc
abstract mixin class $OrderTimelineResponseCopyWith<$Res>  {
  factory $OrderTimelineResponseCopyWith(OrderTimelineResponse value, $Res Function(OrderTimelineResponse) _then) = _$OrderTimelineResponseCopyWithImpl;
@useResult
$Res call({
 int orderId, String currentStatus, String? estimatedCompletion, double progressPercentage, List<OrderTimelineEvent> events, String? nextAction, String? nextActionActor
});




}
/// @nodoc
class _$OrderTimelineResponseCopyWithImpl<$Res>
    implements $OrderTimelineResponseCopyWith<$Res> {
  _$OrderTimelineResponseCopyWithImpl(this._self, this._then);

  final OrderTimelineResponse _self;
  final $Res Function(OrderTimelineResponse) _then;

/// Create a copy of OrderTimelineResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? orderId = null,Object? currentStatus = null,Object? estimatedCompletion = freezed,Object? progressPercentage = null,Object? events = null,Object? nextAction = freezed,Object? nextActionActor = freezed,}) {
  return _then(_self.copyWith(
orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as int,currentStatus: null == currentStatus ? _self.currentStatus : currentStatus // ignore: cast_nullable_to_non_nullable
as String,estimatedCompletion: freezed == estimatedCompletion ? _self.estimatedCompletion : estimatedCompletion // ignore: cast_nullable_to_non_nullable
as String?,progressPercentage: null == progressPercentage ? _self.progressPercentage : progressPercentage // ignore: cast_nullable_to_non_nullable
as double,events: null == events ? _self.events : events // ignore: cast_nullable_to_non_nullable
as List<OrderTimelineEvent>,nextAction: freezed == nextAction ? _self.nextAction : nextAction // ignore: cast_nullable_to_non_nullable
as String?,nextActionActor: freezed == nextActionActor ? _self.nextActionActor : nextActionActor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderTimelineResponse].
extension OrderTimelineResponsePatterns on OrderTimelineResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderTimelineResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderTimelineResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderTimelineResponse value)  $default,){
final _that = this;
switch (_that) {
case _OrderTimelineResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderTimelineResponse value)?  $default,){
final _that = this;
switch (_that) {
case _OrderTimelineResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int orderId,  String currentStatus,  String? estimatedCompletion,  double progressPercentage,  List<OrderTimelineEvent> events,  String? nextAction,  String? nextActionActor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderTimelineResponse() when $default != null:
return $default(_that.orderId,_that.currentStatus,_that.estimatedCompletion,_that.progressPercentage,_that.events,_that.nextAction,_that.nextActionActor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int orderId,  String currentStatus,  String? estimatedCompletion,  double progressPercentage,  List<OrderTimelineEvent> events,  String? nextAction,  String? nextActionActor)  $default,) {final _that = this;
switch (_that) {
case _OrderTimelineResponse():
return $default(_that.orderId,_that.currentStatus,_that.estimatedCompletion,_that.progressPercentage,_that.events,_that.nextAction,_that.nextActionActor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int orderId,  String currentStatus,  String? estimatedCompletion,  double progressPercentage,  List<OrderTimelineEvent> events,  String? nextAction,  String? nextActionActor)?  $default,) {final _that = this;
switch (_that) {
case _OrderTimelineResponse() when $default != null:
return $default(_that.orderId,_that.currentStatus,_that.estimatedCompletion,_that.progressPercentage,_that.events,_that.nextAction,_that.nextActionActor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderTimelineResponse implements OrderTimelineResponse {
  const _OrderTimelineResponse({required this.orderId, required this.currentStatus, this.estimatedCompletion, required this.progressPercentage, required final  List<OrderTimelineEvent> events, this.nextAction, this.nextActionActor}): _events = events;
  factory _OrderTimelineResponse.fromJson(Map<String, dynamic> json) => _$OrderTimelineResponseFromJson(json);

@override final  int orderId;
@override final  String currentStatus;
@override final  String? estimatedCompletion;
@override final  double progressPercentage;
 final  List<OrderTimelineEvent> _events;
@override List<OrderTimelineEvent> get events {
  if (_events is EqualUnmodifiableListView) return _events;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_events);
}

@override final  String? nextAction;
@override final  String? nextActionActor;

/// Create a copy of OrderTimelineResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderTimelineResponseCopyWith<_OrderTimelineResponse> get copyWith => __$OrderTimelineResponseCopyWithImpl<_OrderTimelineResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderTimelineResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderTimelineResponse&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.currentStatus, currentStatus) || other.currentStatus == currentStatus)&&(identical(other.estimatedCompletion, estimatedCompletion) || other.estimatedCompletion == estimatedCompletion)&&(identical(other.progressPercentage, progressPercentage) || other.progressPercentage == progressPercentage)&&const DeepCollectionEquality().equals(other._events, _events)&&(identical(other.nextAction, nextAction) || other.nextAction == nextAction)&&(identical(other.nextActionActor, nextActionActor) || other.nextActionActor == nextActionActor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,orderId,currentStatus,estimatedCompletion,progressPercentage,const DeepCollectionEquality().hash(_events),nextAction,nextActionActor);

@override
String toString() {
  return 'OrderTimelineResponse(orderId: $orderId, currentStatus: $currentStatus, estimatedCompletion: $estimatedCompletion, progressPercentage: $progressPercentage, events: $events, nextAction: $nextAction, nextActionActor: $nextActionActor)';
}


}

/// @nodoc
abstract mixin class _$OrderTimelineResponseCopyWith<$Res> implements $OrderTimelineResponseCopyWith<$Res> {
  factory _$OrderTimelineResponseCopyWith(_OrderTimelineResponse value, $Res Function(_OrderTimelineResponse) _then) = __$OrderTimelineResponseCopyWithImpl;
@override @useResult
$Res call({
 int orderId, String currentStatus, String? estimatedCompletion, double progressPercentage, List<OrderTimelineEvent> events, String? nextAction, String? nextActionActor
});




}
/// @nodoc
class __$OrderTimelineResponseCopyWithImpl<$Res>
    implements _$OrderTimelineResponseCopyWith<$Res> {
  __$OrderTimelineResponseCopyWithImpl(this._self, this._then);

  final _OrderTimelineResponse _self;
  final $Res Function(_OrderTimelineResponse) _then;

/// Create a copy of OrderTimelineResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? orderId = null,Object? currentStatus = null,Object? estimatedCompletion = freezed,Object? progressPercentage = null,Object? events = null,Object? nextAction = freezed,Object? nextActionActor = freezed,}) {
  return _then(_OrderTimelineResponse(
orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as int,currentStatus: null == currentStatus ? _self.currentStatus : currentStatus // ignore: cast_nullable_to_non_nullable
as String,estimatedCompletion: freezed == estimatedCompletion ? _self.estimatedCompletion : estimatedCompletion // ignore: cast_nullable_to_non_nullable
as String?,progressPercentage: null == progressPercentage ? _self.progressPercentage : progressPercentage // ignore: cast_nullable_to_non_nullable
as double,events: null == events ? _self._events : events // ignore: cast_nullable_to_non_nullable
as List<OrderTimelineEvent>,nextAction: freezed == nextAction ? _self.nextAction : nextAction // ignore: cast_nullable_to_non_nullable
as String?,nextActionActor: freezed == nextActionActor ? _self.nextActionActor : nextActionActor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

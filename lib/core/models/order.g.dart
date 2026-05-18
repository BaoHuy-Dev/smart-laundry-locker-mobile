// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Order _$OrderFromJson(Map<String, dynamic> json) => _Order(
  id: (json['id'] as num).toInt(),
  orderCode: json['orderCode'] as String?,
  userId: (json['userId'] as num).toInt(),
  type: $enumDecodeNullable(_$OrderTypeEnumMap, json['type']),
  serviceCategory: $enumDecodeNullable(
    _$ServiceCategoryEnumMap,
    json['serviceCategory'],
  ),
  pricingType: $enumDecodeNullable(_$PricingTypeEnumMap, json['pricingType']),
  lockerId: (json['lockerId'] as num).toInt(),
  locker: json['locker'] == null
      ? null
      : Locker.fromJson(json['locker'] as Map<String, dynamic>),
  lockerName: json['lockerName'] as String?,
  lockerCode: json['lockerCode'] as String?,
  boxId: (json['boxId'] as num).toInt(),
  boxNumber: (json['boxNumber'] as num?)?.toInt(),
  sendBoxNumber: (json['sendBoxNumber'] as num?)?.toInt(),
  receiveBoxNumber: (json['receiveBoxNumber'] as num?)?.toInt(),
  boxes: (json['boxes'] as List<dynamic>?)
      ?.map((e) => OrderBox.fromJson(e as Map<String, dynamic>))
      .toList(),
  status: $enumDecode(_$OrderStatusEnumMap, json['status']),
  pin: json['pin'] as String?,
  pinCode: json['pinCode'] as String?,
  customer: json['customer'] as Map<String, dynamic>?,
  senderId: (json['senderId'] as num?)?.toInt(),
  senderName: json['senderName'] as String?,
  senderPhone: json['senderPhone'] as String?,
  receiverId: (json['receiverId'] as num?)?.toInt(),
  receiverName: json['receiverName'] as String?,
  receiverPhone: json['receiverPhone'] as String?,
  totalAmount: (json['totalAmount'] as num).toDouble(),
  totalPrice: (json['totalPrice'] as num?)?.toDouble(),
  originalPrice: (json['originalPrice'] as num?)?.toDouble(),
  storagePrice: (json['storagePrice'] as num?)?.toDouble(),
  estimatedPrice: json['estimatedPrice'],
  actualPrice: (json['actualPrice'] as num?)?.toDouble(),
  discountAmount: (json['discountAmount'] as num?)?.toDouble(),
  priceBreakdown: json['priceBreakdown'] == null
      ? null
      : PriceBreakdown.fromJson(json['priceBreakdown'] as Map<String, dynamic>),
  promotionCode: json['promotionCode'] as String?,
  appliedPromotionCodes: (json['appliedPromotionCodes'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  promotionDiscount: (json['promotionDiscount'] as num?)?.toDouble(),
  discount: (json['discount'] as num?)?.toDouble(),
  promotionInfo: json['promotionInfo'] == null
      ? null
      : PromotionInfo.fromJson(json['promotionInfo'] as Map<String, dynamic>),
  promotion: json['promotion'] as Map<String, dynamic>?,
  estimatedWeight: (json['estimatedWeight'] as num?)?.toDouble(),
  actualWeight: (json['actualWeight'] as num?)?.toDouble(),
  weightUnit: json['weightUnit'] as String?,
  isOvertime: json['isOvertime'] as bool?,
  overtimeHours: (json['overtimeHours'] as num?)?.toDouble(),
  extraFee: (json['extraFee'] as num?)?.toDouble(),
  isPaid: json['isPaid'] as bool?,
  paymentRequired: json['paymentRequired'] as bool?,
  payment: json['payment'] as Map<String, dynamic>?,
  nextAction: json['nextAction'] as String?,
  nextActionMessage: json['nextActionMessage'] as String?,
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  orderDetails: (json['orderDetails'] as List<dynamic>?)
      ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  services: (json['services'] as List<dynamic>?)
      ?.map((e) => LaundryService.fromJson(e as Map<String, dynamic>))
      .toList(),
  customerNote: json['customerNote'] as String?,
  staffNote: json['staffNote'] as String?,
  deliveryAddress: json['deliveryAddress'] as String?,
  expiresAt: json['expiresAt'] as String?,
  intendedReceiveAt: json['intendedReceiveAt'] as String?,
  pickupDeadline: json['pickupDeadline'] as String?,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
  confirmedAt: json['confirmedAt'] as String?,
  collectedAt: json['collectedAt'] as String?,
  processedAt: json['processedAt'] as String?,
  readyAt: json['readyAt'] as String?,
  returnedAt: json['returnedAt'] as String?,
  completedAt: json['completedAt'] as String?,
  canceledAt: json['canceledAt'] as String?,
  cancelReason: json['cancelReason'] as String?,
);

Map<String, dynamic> _$OrderToJson(_Order instance) => <String, dynamic>{
  'id': instance.id,
  'orderCode': instance.orderCode,
  'userId': instance.userId,
  'type': _$OrderTypeEnumMap[instance.type],
  'serviceCategory': _$ServiceCategoryEnumMap[instance.serviceCategory],
  'pricingType': _$PricingTypeEnumMap[instance.pricingType],
  'lockerId': instance.lockerId,
  'locker': instance.locker?.toJson(),
  'lockerName': instance.lockerName,
  'lockerCode': instance.lockerCode,
  'boxId': instance.boxId,
  'boxNumber': instance.boxNumber,
  'sendBoxNumber': instance.sendBoxNumber,
  'receiveBoxNumber': instance.receiveBoxNumber,
  'boxes': instance.boxes?.map((e) => e.toJson()).toList(),
  'status': _$OrderStatusEnumMap[instance.status]!,
  'pin': instance.pin,
  'pinCode': instance.pinCode,
  'customer': instance.customer,
  'senderId': instance.senderId,
  'senderName': instance.senderName,
  'senderPhone': instance.senderPhone,
  'receiverId': instance.receiverId,
  'receiverName': instance.receiverName,
  'receiverPhone': instance.receiverPhone,
  'totalAmount': instance.totalAmount,
  'totalPrice': instance.totalPrice,
  'originalPrice': instance.originalPrice,
  'storagePrice': instance.storagePrice,
  'estimatedPrice': instance.estimatedPrice,
  'actualPrice': instance.actualPrice,
  'discountAmount': instance.discountAmount,
  'priceBreakdown': instance.priceBreakdown?.toJson(),
  'promotionCode': instance.promotionCode,
  'appliedPromotionCodes': instance.appliedPromotionCodes,
  'promotionDiscount': instance.promotionDiscount,
  'discount': instance.discount,
  'promotionInfo': instance.promotionInfo?.toJson(),
  'promotion': instance.promotion,
  'estimatedWeight': instance.estimatedWeight,
  'actualWeight': instance.actualWeight,
  'weightUnit': instance.weightUnit,
  'isOvertime': instance.isOvertime,
  'overtimeHours': instance.overtimeHours,
  'extraFee': instance.extraFee,
  'isPaid': instance.isPaid,
  'paymentRequired': instance.paymentRequired,
  'payment': instance.payment,
  'nextAction': instance.nextAction,
  'nextActionMessage': instance.nextActionMessage,
  'items': instance.items?.map((e) => e.toJson()).toList(),
  'orderDetails': instance.orderDetails?.map((e) => e.toJson()).toList(),
  'services': instance.services?.map((e) => e.toJson()).toList(),
  'customerNote': instance.customerNote,
  'staffNote': instance.staffNote,
  'deliveryAddress': instance.deliveryAddress,
  'expiresAt': instance.expiresAt,
  'intendedReceiveAt': instance.intendedReceiveAt,
  'pickupDeadline': instance.pickupDeadline,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
  'confirmedAt': instance.confirmedAt,
  'collectedAt': instance.collectedAt,
  'processedAt': instance.processedAt,
  'readyAt': instance.readyAt,
  'returnedAt': instance.returnedAt,
  'completedAt': instance.completedAt,
  'canceledAt': instance.canceledAt,
  'cancelReason': instance.cancelReason,
};

const _$OrderTypeEnumMap = {
  OrderType.standardDropoff: 'STANDARD_DROPOFF',
  OrderType.laundry: 'LAUNDRY',
  OrderType.storage: 'STORAGE',
};

const _$ServiceCategoryEnumMap = {
  ServiceCategory.storage: 'STORAGE',
  ServiceCategory.laundry: 'LAUNDRY',
};

const _$PricingTypeEnumMap = {
  PricingType.fixed: 'FIXED',
  PricingType.perWeight: 'PER_WEIGHT',
  PricingType.perPiece: 'PER_PIECE',
};

const _$OrderStatusEnumMap = {
  OrderStatus.initialized: 'INITIALIZED',
  OrderStatus.waiting: 'WAITING',
  OrderStatus.collected: 'COLLECTED',
  OrderStatus.processing: 'PROCESSING',
  OrderStatus.ready: 'READY',
  OrderStatus.returned: 'RETURNED',
  OrderStatus.completed: 'COMPLETED',
  OrderStatus.canceled: 'CANCELED',
};

_OrderBox _$OrderBoxFromJson(Map<String, dynamic> json) => _OrderBox(
  id: (json['id'] as num).toInt(),
  boxNumber: json['boxNumber'] as String,
  size: json['size'] as String,
);

Map<String, dynamic> _$OrderBoxToJson(_OrderBox instance) => <String, dynamic>{
  'id': instance.id,
  'boxNumber': instance.boxNumber,
  'size': instance.size,
};

_OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => _OrderItem(
  id: (json['id'] as num).toInt(),
  serviceId: (json['serviceId'] as num).toInt(),
  serviceName: json['serviceName'] as String,
  quantity: (json['quantity'] as num).toInt(),
  price: (json['price'] as num).toDouble(),
  subtotal: (json['subtotal'] as num).toDouble(),
);

Map<String, dynamic> _$OrderItemToJson(_OrderItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'serviceId': instance.serviceId,
      'serviceName': instance.serviceName,
      'quantity': instance.quantity,
      'price': instance.price,
      'subtotal': instance.subtotal,
    };

_OrderTrackingDetail _$OrderTrackingDetailFromJson(Map<String, dynamic> json) =>
    _OrderTrackingDetail(
      orderId: (json['orderId'] as num).toInt(),
      status: $enumDecode(_$OrderStatusEnumMap, json['status']),
      statusDescription: json['statusDescription'] as String,
      pinCode: json['pinCode'] as String?,
      lockerName: json['lockerName'] as String?,
      lockerCode: json['lockerCode'] as String?,
      boxNumber: (json['boxNumber'] as num?)?.toInt(),
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      estimatedReadyAt: json['estimatedReadyAt'] as String?,
      completedAt: json['completedAt'] as String?,
      isPaid: json['isPaid'] as bool,
      nextAction: json['nextAction'] as String,
    );

Map<String, dynamic> _$OrderTrackingDetailToJson(
  _OrderTrackingDetail instance,
) => <String, dynamic>{
  'orderId': instance.orderId,
  'status': _$OrderStatusEnumMap[instance.status]!,
  'statusDescription': instance.statusDescription,
  'pinCode': instance.pinCode,
  'lockerName': instance.lockerName,
  'lockerCode': instance.lockerCode,
  'boxNumber': instance.boxNumber,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
  'estimatedReadyAt': instance.estimatedReadyAt,
  'completedAt': instance.completedAt,
  'isPaid': instance.isPaid,
  'nextAction': instance.nextAction,
};

_OrderTimelineEvent _$OrderTimelineEventFromJson(Map<String, dynamic> json) =>
    _OrderTimelineEvent(
      status: json['status'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      timestamp: json['timestamp'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      actor: json['actor'] as String?,
      metadata: json['metadata'] as String?,
    );

Map<String, dynamic> _$OrderTimelineEventToJson(_OrderTimelineEvent instance) =>
    <String, dynamic>{
      'status': instance.status,
      'title': instance.title,
      'description': instance.description,
      'timestamp': instance.timestamp,
      'icon': instance.icon,
      'color': instance.color,
      'actor': instance.actor,
      'metadata': instance.metadata,
    };

_OrderTimelineResponse _$OrderTimelineResponseFromJson(
  Map<String, dynamic> json,
) => _OrderTimelineResponse(
  orderId: (json['orderId'] as num).toInt(),
  currentStatus: json['currentStatus'] as String,
  estimatedCompletion: json['estimatedCompletion'] as String?,
  progressPercentage: (json['progressPercentage'] as num).toDouble(),
  events: (json['events'] as List<dynamic>)
      .map((e) => OrderTimelineEvent.fromJson(e as Map<String, dynamic>))
      .toList(),
  nextAction: json['nextAction'] as String?,
  nextActionActor: json['nextActionActor'] as String?,
);

Map<String, dynamic> _$OrderTimelineResponseToJson(
  _OrderTimelineResponse instance,
) => <String, dynamic>{
  'orderId': instance.orderId,
  'currentStatus': instance.currentStatus,
  'estimatedCompletion': instance.estimatedCompletion,
  'progressPercentage': instance.progressPercentage,
  'events': instance.events.map((e) => e.toJson()).toList(),
  'nextAction': instance.nextAction,
  'nextActionActor': instance.nextActionActor,
};

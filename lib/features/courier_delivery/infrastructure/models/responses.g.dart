// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'responses.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourierAcceptResponse _$CourierAcceptResponseFromJson(
  Map<String, dynamic> json,
) => CourierAcceptResponse(
  orderId: json['order_id'] as String,
  orderCode: json['order_code'] as String,
  accessCode: json['access_code'] as String?,
  lockerLabel: json['locker_label'] as String?,
  lockerId: json['locker_id'] as String?,
  row: (json['row'] as num?)?.toInt(),
  column: (json['column'] as num?)?.toInt(),
  recipientName: json['recipient_name'] as String?,
  recipientPhone: json['recipient_phone'] as String?,
  cabinetName: json['cabinet_name'] as String?,
  address: json['address'] as String?,
  message: json['message'] as String,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  receiverLatitude: (json['receiver_latitude'] as num?)?.toDouble(),
  receiverLongitude: (json['receiver_longitude'] as num?)?.toDouble(),
  order: json['order'] == null
      ? null
      : OrderModel.fromJson(json['order'] as Map<String, dynamic>),
  orderDetails: (json['order_details'] as List<dynamic>?)
      ?.map((e) => OrderDetailModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CourierAcceptResponseToJson(
  CourierAcceptResponse instance,
) => <String, dynamic>{
  'order_id': instance.orderId,
  'order_code': instance.orderCode,
  'access_code': instance.accessCode,
  'locker_label': instance.lockerLabel,
  'locker_id': instance.lockerId,
  'row': instance.row,
  'column': instance.column,
  'recipient_name': instance.recipientName,
  'recipient_phone': instance.recipientPhone,
  'cabinet_name': instance.cabinetName,
  'address': instance.address,
  'message': instance.message,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'receiver_latitude': instance.receiverLatitude,
  'receiver_longitude': instance.receiverLongitude,
  'order': instance.order?.toJson(),
  'order_details': instance.orderDetails?.map((e) => e.toJson()).toList(),
};

CourierDepositOpenResponse _$CourierDepositOpenResponseFromJson(
  Map<String, dynamic> json,
) => CourierDepositOpenResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
);

Map<String, dynamic> _$CourierDepositOpenResponseToJson(
  CourierDepositOpenResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
};

CourierDepositConfirmResponse _$CourierDepositConfirmResponseFromJson(
  Map<String, dynamic> json,
) => CourierDepositConfirmResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
);

Map<String, dynamic> _$CourierDepositConfirmResponseToJson(
  CourierDepositConfirmResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
};

PickupPackageResponse _$PickupPackageResponseFromJson(
  Map<String, dynamic> json,
) => PickupPackageResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  orderCode: json['order_code'] as String,
  lockerLabel: json['locker_label'] as String,
  row: (json['row'] as num?)?.toInt(),
  column: (json['column'] as num?)?.toInt(),
);

Map<String, dynamic> _$PickupPackageResponseToJson(
  PickupPackageResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'order_code': instance.orderCode,
  'locker_label': instance.lockerLabel,
  'row': instance.row,
  'column': instance.column,
};

CourierPickupConfirmResponse _$CourierPickupConfirmResponseFromJson(
  Map<String, dynamic> json,
) => CourierPickupConfirmResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
);

Map<String, dynamic> _$CourierPickupConfirmResponseToJson(
  CourierPickupConfirmResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
};

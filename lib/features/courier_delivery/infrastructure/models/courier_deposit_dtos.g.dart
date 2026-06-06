// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'courier_deposit_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourierDepositOpenDto _$CourierDepositOpenDtoFromJson(
  Map<String, dynamic> json,
) => CourierDepositOpenDto(
  orderCode: json['orderCode'] as String,
  lockerId: json['lockerId'] as String,
);

Map<String, dynamic> _$CourierDepositOpenDtoToJson(
  CourierDepositOpenDto instance,
) => <String, dynamic>{
  'orderCode': instance.orderCode,
  'lockerId': instance.lockerId,
};

CourierDepositConfirmDto _$CourierDepositConfirmDtoFromJson(
  Map<String, dynamic> json,
) => CourierDepositConfirmDto(
  orderCode: json['orderCode'] as String,
  recipientPhone: json['recipientPhone'] as String,
  recipientName: json['recipientName'] as String,
  lockerId: json['lockerId'] as String,
  imageUrls: (json['imageUrls'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$CourierDepositConfirmDtoToJson(
  CourierDepositConfirmDto instance,
) => <String, dynamic>{
  'orderCode': instance.orderCode,
  'recipientPhone': instance.recipientPhone,
  'recipientName': instance.recipientName,
  'lockerId': instance.lockerId,
  'imageUrls': instance.imageUrls,
};

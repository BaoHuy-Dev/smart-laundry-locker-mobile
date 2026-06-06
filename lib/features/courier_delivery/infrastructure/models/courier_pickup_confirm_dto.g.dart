// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'courier_pickup_confirm_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourierPickupConfirmDto _$CourierPickupConfirmDtoFromJson(
  Map<String, dynamic> json,
) => CourierPickupConfirmDto(
  orderCode: json['orderCode'] as String,
  imageUrls: (json['imageUrls'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$CourierPickupConfirmDtoToJson(
  CourierPickupConfirmDto instance,
) => <String, dynamic>{
  'orderCode': instance.orderCode,
  'imageUrls': instance.imageUrls,
};

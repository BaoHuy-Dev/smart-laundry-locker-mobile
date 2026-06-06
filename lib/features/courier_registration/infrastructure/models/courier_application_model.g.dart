// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'courier_application_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourierApplicationModel _$CourierApplicationModelFromJson(
  Map<String, dynamic> json,
) => CourierApplicationModel(
  id: json['id'] as String,
  userId: json['userId'] as String,
  legalName: json['legalName'] as String,
  licensePlate: json['licensePlate'] as String,
  vehicleType: json['vehicleType'] as String,
  frontVehicleImageUrl: json['frontVehicleImageUrl'] as String,
  backVehicleImageUrl: json['backVehicleImageUrl'] as String,
  portraitUrl: json['portraitUrl'] as String,
  status: json['status'] as String,
  reviewedById: json['reviewedById'] as String?,
  reviewNote: json['reviewNote'] as String?,
  reviewedAt: json['reviewedAt'] as String?,
  rejectionCount: (json['rejectionCount'] as num).toInt(),
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
);

Map<String, dynamic> _$CourierApplicationModelToJson(
  CourierApplicationModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'legalName': instance.legalName,
  'licensePlate': instance.licensePlate,
  'vehicleType': instance.vehicleType,
  'frontVehicleImageUrl': instance.frontVehicleImageUrl,
  'backVehicleImageUrl': instance.backVehicleImageUrl,
  'portraitUrl': instance.portraitUrl,
  'status': instance.status,
  'reviewedById': instance.reviewedById,
  'reviewNote': instance.reviewNote,
  'reviewedAt': instance.reviewedAt,
  'rejectionCount': instance.rejectionCount,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

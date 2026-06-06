// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_application_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StaffApplicationModel _$StaffApplicationModelFromJson(
  Map<String, dynamic> json,
) => StaffApplicationModel(
  id: json['id'] as String,
  userId: json['userId'] as String,
  legalName: json['legalName'] as String,
  licensePlate: json['licensePlate'] as String,
  status: json['status'] as String,
  role: json['role'] as String,
  vehicleTypeId: json['vehicleTypeId'] as String,
  vehicleTypeName: json['vehicleTypeName'] as String,
  frontVehicleImageUrl: json['frontVehicleImageUrl'] as String?,
  backVehicleImageUrl: json['backVehicleImageUrl'] as String?,
  portraitUrl: json['portraitUrl'] as String?,
  reviewedById: json['reviewedById'] as String?,
  reviewNote: json['reviewNote'] as String?,
  reviewedAt: json['reviewedAt'] as String?,
  rejectionCount: (json['rejectionCount'] as num).toInt(),
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
);

Map<String, dynamic> _$StaffApplicationModelToJson(
  StaffApplicationModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'legalName': instance.legalName,
  'licensePlate': instance.licensePlate,
  'status': instance.status,
  'role': instance.role,
  'vehicleTypeId': instance.vehicleTypeId,
  'vehicleTypeName': instance.vehicleTypeName,
  'frontVehicleImageUrl': instance.frontVehicleImageUrl,
  'backVehicleImageUrl': instance.backVehicleImageUrl,
  'portraitUrl': instance.portraitUrl,
  'reviewedById': instance.reviewedById,
  'reviewNote': instance.reviewNote,
  'reviewedAt': instance.reviewedAt,
  'rejectionCount': instance.rejectionCount,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

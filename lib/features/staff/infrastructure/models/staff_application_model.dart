import 'package:json_annotation/json_annotation.dart';

part 'staff_application_model.g.dart';

@JsonSerializable()
class StaffApplicationModel {
  final String id;
  final String userId;
  final String legalName;
  final String licensePlate;
  final String status;
  final String role;
  final String vehicleTypeId;
  final String vehicleTypeName;
  final String? frontVehicleImageUrl;
  final String? backVehicleImageUrl;
  final String? portraitUrl;
  final String? reviewedById;
  final String? reviewNote;
  final String? reviewedAt;
  final int rejectionCount;
  final String createdAt;
  final String updatedAt;

  const StaffApplicationModel({
    required this.id,
    required this.userId,
    required this.legalName,
    required this.licensePlate,
    required this.status,
    required this.role,
    required this.vehicleTypeId,
    required this.vehicleTypeName,
    this.frontVehicleImageUrl,
    this.backVehicleImageUrl,
    this.portraitUrl,
    this.reviewedById,
    this.reviewNote,
    this.reviewedAt,
    required this.rejectionCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StaffApplicationModel.fromJson(Map<String, dynamic> json) =>
      _$StaffApplicationModelFromJson(json);

  Map<String, dynamic> toJson() => _$StaffApplicationModelToJson(this);
}

import 'package:json_annotation/json_annotation.dart';
import 'package:smart_laundry_locker/features/courier_registration/domain/entities/courier_application_entity.dart';

part 'courier_application_model.g.dart';

// model cho Courier Application response từ api
@JsonSerializable()
class CourierApplicationModel {
  final String id;
  final String userId;
  final String legalName;
  final String licensePlate;
  final String vehicleType;
  final String frontVehicleImageUrl;
  final String backVehicleImageUrl;
  final String portraitUrl;
  final String status;
  final String? reviewedById;
  final String? reviewNote;
  final String? reviewedAt;
  final int rejectionCount;
  final String createdAt;
  final String updatedAt;

  const CourierApplicationModel({
    required this.id,
    required this.userId,
    required this.legalName,
    required this.licensePlate,
    required this.vehicleType,
    required this.frontVehicleImageUrl,
    required this.backVehicleImageUrl,
    required this.portraitUrl,
    required this.status,
    this.reviewedById,
    this.reviewNote,
    this.reviewedAt,
    required this.rejectionCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CourierApplicationModel.fromJson(Map<String, dynamic> json) =>
      _$CourierApplicationModelFromJson(json);

  Map<String, dynamic> toJson() => _$CourierApplicationModelToJson(this);

  // convert model sang entity
  CourierApplicationEntity toEntity() {
    return CourierApplicationEntity(
      id: id,
      userId: userId,
      legalName: legalName,
      licensePlate: licensePlate,
      vehicleType: vehicleType,
      frontVehicleImageUrl: frontVehicleImageUrl,
      backVehicleImageUrl: backVehicleImageUrl,
      portraitUrl: portraitUrl,
      status: status,
      reviewedById: reviewedById,
      reviewNote: reviewNote,
      reviewedAt: reviewedAt != null && reviewedAt!.isNotEmpty
          ? DateTime.parse(reviewedAt!)
          : null,
      rejectionCount: rejectionCount,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }
}

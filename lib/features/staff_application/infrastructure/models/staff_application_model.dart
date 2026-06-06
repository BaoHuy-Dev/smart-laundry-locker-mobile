import 'package:smart_laundry_locker/features/staff_application/domain/entities/staff_application.dart';

class StaffApplicationModel {
  final String id;
  final String userId;
  final String legalName;
  final String licensePlate;
  final String vehicleTypeId;
  final String role;
  final String status;

  final String? vehicleTypeName;
  final String? frontVehicleImageUrl;
  final String? backVehicleImageUrl;
  final String? portraitUrl;
  final String? reviewNote;
  final String? reviewedAt;

  const StaffApplicationModel({
    required this.id,
    required this.userId,
    required this.legalName,
    required this.licensePlate,
    required this.vehicleTypeId,
    required this.role,
    required this.status,
    this.vehicleTypeName,
    this.frontVehicleImageUrl,
    this.backVehicleImageUrl,
    this.portraitUrl,
    this.reviewNote,
    this.reviewedAt,
  });

  factory StaffApplicationModel.fromJson(Map<String, dynamic> json) {
    return StaffApplicationModel(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      legalName: (json['legalName'] ?? '').toString(),
      licensePlate: (json['licensePlate'] ?? '').toString(),
      vehicleTypeId: (json['vehicleTypeId'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      vehicleTypeName: json['vehicleTypeName']?.toString(),
      frontVehicleImageUrl: json['frontVehicleImageUrl']?.toString(),
      backVehicleImageUrl: json['backVehicleImageUrl']?.toString(),
      portraitUrl: json['portraitUrl']?.toString(),
      reviewNote: json['reviewNote']?.toString(),
      reviewedAt: json['reviewedAt']?.toString(),
    );
  }

  StaffApplication toEntity() {
    return StaffApplication(
      id: id,
      userId: userId,
      legalName: legalName,
      licensePlate: licensePlate,
      vehicleTypeId: vehicleTypeId,
      vehicleTypeName: vehicleTypeName,
      role: role,
      status: StaffApplicationStatusX.fromApi(status),
      frontVehicleImageUrl: frontVehicleImageUrl,
      backVehicleImageUrl: backVehicleImageUrl,
      portraitUrl: portraitUrl,
      reviewNote: reviewNote,
      reviewedAt: (reviewedAt != null && reviewedAt!.isNotEmpty)
          ? DateTime.tryParse(reviewedAt!)
          : null,
    );
  }
}

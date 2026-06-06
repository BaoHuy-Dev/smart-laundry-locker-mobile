class StaffApplication {
  final String id;
  final String userId;
  final String legalName;
  final String licensePlate;
  final String vehicleTypeId;
  final String role;
  final StaffApplicationStatus status;

  final String? vehicleTypeName;
  final String? frontVehicleImageUrl;
  final String? backVehicleImageUrl;
  final String? portraitUrl;
  final String? reviewNote;
  final DateTime? reviewedAt;

  const StaffApplication({
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
}

enum StaffApplicationStatus { PENDING, APPROVED, REJECTED }

extension StaffApplicationStatusX on StaffApplicationStatus {
  static StaffApplicationStatus fromApi(String raw) {
    switch (raw.toUpperCase()) {
      case 'PENDING':
        return StaffApplicationStatus.PENDING;
      case 'APPROVED':
        return StaffApplicationStatus.APPROVED;
      case 'REJECTED':
        return StaffApplicationStatus.REJECTED;
      default:
        return StaffApplicationStatus.PENDING;
    }
  }
}

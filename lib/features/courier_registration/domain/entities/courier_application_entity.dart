class CourierApplicationEntity {
  final String id;
  final String userId;
  final String legalName;
  final String licensePlate;
  final String vehicleType; // 'BIKE', 'MOTORBIKE', 'CAR'
  final String frontVehicleImageUrl;
  final String backVehicleImageUrl;
  final String portraitUrl;
  final String status; // 'PENDING', 'APPROVED', 'REJECTED'
  final String? reviewedById;
  final String? reviewNote;
  final DateTime? reviewedAt;
  final int rejectionCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CourierApplicationEntity({
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

  bool get isPending => status == 'PENDING';

  bool get isApproved => status == 'APPROVED';

  bool get isRejected => status == 'REJECTED';
}

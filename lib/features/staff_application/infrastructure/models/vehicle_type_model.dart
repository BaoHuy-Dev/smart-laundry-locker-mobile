import 'package:smart_laundry_locker/features/staff_application/domain/entities/vehicle_type.dart';

class VehicleTypeModel {
  final String id;
  final String name;
  final bool isActive;

  const VehicleTypeModel({
    required this.id,
    required this.name,
    required this.isActive,
  });

  factory VehicleTypeModel.fromJson(Map<String, dynamic> json) {
    return VehicleTypeModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  VehicleType toEntity() => VehicleType(id: id, name: name, isActive: isActive);
}

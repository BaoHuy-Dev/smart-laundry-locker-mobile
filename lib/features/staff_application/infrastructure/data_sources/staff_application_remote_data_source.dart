import 'package:smart_laundry_locker/features/staff_application/infrastructure/models/staff_application_model.dart';
import 'package:smart_laundry_locker/features/staff_application/infrastructure/models/vehicle_type_model.dart';

abstract class StaffApplicationRemoteDataSource {
  Future<StaffApplicationModel> submit({
    required String legalName,
    required String licensePlate,
    required String vehicleTypeId,
    required String role,
    required String frontVehicleImagePath,
    required String backVehicleImagePath,
    required String portraitImagePath,
  });

  Future<StaffApplicationModel?> getByUserId(String userId);

  Future<List<VehicleTypeModel>> getVehicleTypes();
}

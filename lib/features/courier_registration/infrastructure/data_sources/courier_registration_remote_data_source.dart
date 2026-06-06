import 'package:smart_laundry_locker/features/courier_registration/infrastructure/models/courier_application_model.dart';

// abstract class cho remote data source
abstract class CourierRegistrationRemoteDataSource {
  // submit đơn đăng ký tài xế
  Future<CourierApplicationModel> submitApplication({
    required String legalName,
    required String licensePlate,
    required String vehicleType,
    required String frontVehicleImagePath,
    required String backVehicleImagePath,
    required String portraitImagePath,
  });

  Future<CourierApplicationModel?> checkStatus({required String userId});
}

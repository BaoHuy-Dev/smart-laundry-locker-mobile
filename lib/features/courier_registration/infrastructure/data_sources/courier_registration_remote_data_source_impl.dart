import 'package:smart_laundry_locker/core/network/api_client.dart';
import 'package:smart_laundry_locker/features/courier_registration/infrastructure/data_sources/courier_registration_remote_data_source.dart';
import 'package:smart_laundry_locker/features/courier_registration/infrastructure/models/courier_application_model.dart';
import 'package:dio/dio.dart';

class CourierRegistrationRemoteDataSourceImpl
    implements CourierRegistrationRemoteDataSource {
  final ApiClient _apiClient;

  static const String _basePath = '/staff-applications';

  CourierRegistrationRemoteDataSourceImpl(this._apiClient);

  @override
  Future<CourierApplicationModel> submitApplication({
    required String legalName,
    required String licensePlate,
    required String vehicleType,
    required String frontVehicleImagePath,
    required String backVehicleImagePath,
    required String portraitImagePath,
  }) async {
    final formData = FormData();

    // field text
    formData.fields.addAll([
      MapEntry('legalName', legalName),
      MapEntry('licensePlate', licensePlate),
      MapEntry('vehicleType', vehicleType),
    ]);

    formData.files.addAll([
      MapEntry(
        'files',
        await MultipartFile.fromFile(
          frontVehicleImagePath,
          filename: 'front_vehicle.jpg',
        ),
      ),
      MapEntry(
        'files',
        await MultipartFile.fromFile(
          backVehicleImagePath,
          filename: 'back_vehicle.jpg',
        ),
      ),
      MapEntry(
        'files',
        await MultipartFile.fromFile(
          portraitImagePath,
          filename: 'portrait.jpg',
        ),
      ),
    ]);

    final response = await _apiClient.post(
      _basePath,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    final responseData = response.data as Map<String, dynamic>;

    final data = responseData['data'] as Map<String, dynamic>? ?? responseData;

    return CourierApplicationModel.fromJson(data);
  }

  @override
  Future<CourierApplicationModel?> checkStatus({required String userId}) async {
    try {
      final response = await _apiClient.get('$_basePath/user/$userId');

      final responseData = response.data as Map<String, dynamic>;
      final data =
          responseData['data'] as Map<String, dynamic>? ?? responseData;

      return CourierApplicationModel.fromJson(data);
    } on NotFoundException {
      // user chưa đăng ký -> trả null
      return null;
    }
  }
}

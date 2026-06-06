import 'package:smart_laundry_locker/core/network/api_client.dart';
import 'package:smart_laundry_locker/features/staff_application/infrastructure/data_sources/staff_application_remote_data_source.dart';
import 'package:smart_laundry_locker/features/staff_application/infrastructure/models/staff_application_model.dart';
import 'package:smart_laundry_locker/features/staff_application/infrastructure/models/vehicle_type_model.dart';
import 'package:dio/dio.dart';

class StaffApplicationRemoteDataSourceImpl
    implements StaffApplicationRemoteDataSource {
  final ApiClient _apiClient;

  static const String _basePath = '/staff-applications';

  StaffApplicationRemoteDataSourceImpl(this._apiClient);

  @override
  Future<StaffApplicationModel> submit({
    required String legalName,
    required String licensePlate,
    required String vehicleTypeId,
    required String role,
    required String frontVehicleImagePath,
    required String backVehicleImagePath,
    required String portraitImagePath,
  }) async {
    final formData = FormData();

    // fields text
    formData.fields.addAll([
      MapEntry('legalName', legalName),
      MapEntry('licensePlate', licensePlate),
      MapEntry('vehicleTypeId', vehicleTypeId),
      MapEntry('role', role),
    ]);

    // files[]: đúng thứ tự backend
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

    final responseData = response.data;
    if (responseData is Map<String, dynamic>) {
      final data =
          responseData['data'] as Map<String, dynamic>? ?? responseData;
      return StaffApplicationModel.fromJson(data);
    }

    throw ServerException('Dữ liệu trả về không hợp lệ.');
  }

  @override
  Future<StaffApplicationModel?> getByUserId(String userId) async {
    try {
      final response = await _apiClient.get('$_basePath/user/$userId');
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final data =
            responseData['data'] as Map<String, dynamic>? ?? responseData;
        return StaffApplicationModel.fromJson(data);
      }
      throw ServerException('Dữ liệu trả về không hợp lệ.');
    } on NotFoundException {
      return null;
    }
  }

  @override
  Future<List<VehicleTypeModel>> getVehicleTypes() async {
    List<VehicleTypeModel> parseItems(dynamic data) {
      List<dynamic>? rawItems;
      if (data is List) {
        rawItems = data;
      } else if (data is Map<String, dynamic>) {
        if (data['items'] is List) {
          rawItems = data['items'] as List<dynamic>;
        } else if (data['data'] is List) {
          rawItems = data['data'] as List<dynamic>;
        } else if (data['data'] is Map<String, dynamic>) {
          final nested = data['data'] as Map<String, dynamic>;
          if (nested['items'] is List) {
            rawItems = nested['items'] as List<dynamic>;
          }
        }
      }

      if (rawItems == null) return <VehicleTypeModel>[];
      return rawItems
          .whereType<Map<String, dynamic>>()
          .map(VehicleTypeModel.fromJson)
          .toList();
    }

    final activeResponse = await _apiClient.get(
      '/vehicle-types',
      queryParameters: {'isActive': true},
    );
    final activeItems = parseItems(activeResponse.data);
    if (activeItems.isNotEmpty) return activeItems;

    final allResponse = await _apiClient.get('/vehicle-types');
    final allItems = parseItems(allResponse.data);
    if (allItems.isNotEmpty) return allItems;

    return <VehicleTypeModel>[];
  }
}

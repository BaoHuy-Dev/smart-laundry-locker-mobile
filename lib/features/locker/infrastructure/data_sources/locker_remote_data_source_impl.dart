import 'package:smart_laundry_locker/core/network/api_client.dart';
import 'package:smart_laundry_locker/features/locker/infrastructure/data_sources/locker_remote_data_source.dart';
import 'package:smart_laundry_locker/features/locker/infrastructure/models/cabinet_model.dart';
import 'package:smart_laundry_locker/features/locker/infrastructure/models/customer_cabinet_model.dart';
import 'package:smart_laundry_locker/features/locker/infrastructure/models/fixed_rent_response_model.dart';
import 'package:smart_laundry_locker/features/locker/infrastructure/models/locker_location_model.dart';
import 'package:smart_laundry_locker/features/locker/infrastructure/models/locker_rent_request_model.dart';
import 'package:smart_laundry_locker/features/locker/infrastructure/models/locker_model.dart';
import 'package:smart_laundry_locker/features/locker/infrastructure/models/responses/responses.dart';
import 'package:dio/dio.dart';

/// Implementation của LockerRemoteDataSource
/// Sử dụng ApiClient để gọi API endpoints.
class LockerRemoteDataSourceImpl implements LockerRemoteDataSource {
  final ApiClient _apiClient;

  /// API base path cho locker service
  static const String _basePath = '/lockers';

  LockerRemoteDataSourceImpl(this._apiClient);

  /// Extract data field từ API response
  /// API trả về format: {statusCode, message, data: {...}}
  Map<String, dynamic> _extractData(Response<dynamic> response) {
    if (response.data == null) return {};
    final responseData = response.data as Map<String, dynamic>;
    if (responseData['data'] == null) return {};
    return responseData['data'] as Map<String, dynamic>;
  }

  // ==================== LOCATIONS ====================

  @override
  Future<LocationsResponse> getLocations({
    int page = 1,
    int limit = 10,
    String? search,
    String? name,
    String? address,
    bool? isActive,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
      if (name != null && name.isNotEmpty) 'name': name,
      if (address != null && address.isNotEmpty) 'address': address,
      if (isActive != null) 'isActive': isActive,
    };

    final response = await _apiClient.get<Map<String, dynamic>>(
      '/locations',
      queryParameters: queryParams,
    );

    return LocationsResponse.fromJson(_extractData(response));
  }

  @override
  Future<LocationsResponse> getLocationsForCustomer({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final response = await _apiClient.get<Map<String, dynamic>>(
      '/locations/customer',
      queryParameters: queryParams,
    );

    return LocationsResponse.fromJson(_extractData(response));
  }

  @override
  Future<LocationsResponse> getLocationsForCourier({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final response = await _apiClient.get<Map<String, dynamic>>(
      '/locations/courier',
      queryParameters: queryParams,
    );

    return LocationsResponse.fromJson(_extractData(response));
  }

  @override
  Future<LockerLocationModel> getLocationById(String id) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '$_basePath/locations/$id',
    );
    final data = _extractData(response);
    return LockerLocationModel.fromJson(
      data['location'] as Map<String, dynamic>? ?? data,
    );
  }

  @override
  Future<LocationCabinetsResponse> getLocationCabinets(
    String locationId, {
    int page = 1,
    int limit = 10,
    String? status,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (status != null && status.isNotEmpty) 'status': status,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final response = await _apiClient.get<Map<String, dynamic>>(
      '$_basePath/locations/$locationId/cabinets',
      queryParameters: queryParams,
    );

    return LocationCabinetsResponse.fromJson(_extractData(response));
  }

  @override
  Future<List<CustomerCabinetModel>> getCustomerCabinets(
    String locationId,
  ) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/locations/$locationId/customer/cabinets',
    );

    final data = _extractData(response);
    final cabinetsJson = data['cabinets'] as List<dynamic>?;
    if (cabinetsJson == null) return [];

    return cabinetsJson
        .map((j) => CustomerCabinetModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  // ==================== CABINETS ====================

  @override
  Future<CabinetsResponse> getCabinets({
    int page = 1,
    int limit = 10,
    String? locationId,
    String? name,
    String? macAddress,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (locationId != null && locationId.isNotEmpty) 'locationId': locationId,
      if (name != null && name.isNotEmpty) 'name': name,
      if (macAddress != null && macAddress.isNotEmpty) 'macAddress': macAddress,
    };

    final response = await _apiClient.get<Map<String, dynamic>>(
      '$_basePath/cabinets',
      queryParameters: queryParams,
    );

    return CabinetsResponse.fromJson(_extractData(response));
  }

  @override
  Future<CabinetModel> getCabinetById(String id) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/cabinets/$id',
    );
    final data = _extractData(response);
    return CabinetModel.fromJson(
      data['cabinet'] as Map<String, dynamic>? ?? data,
    );
  }

  @override
  Future<CabinetLockersResponse> getCabinetLockers(
    String cabinetId, {
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final response = await _apiClient.get<Map<String, dynamic>>(
      '$_basePath/cabinets/$cabinetId/lockers',
      queryParameters: queryParams,
    );

    return CabinetLockersResponse.fromJson(_extractData(response));
  }

  // ==================== LOCKERS ====================

  @override
  Future<LockerModel> getLockerById(String id) async {
    final response = await _apiClient.get<Map<String, dynamic>>('/lockers/$id');
    final data = _extractData(response);
    return LockerModel.fromJson(
      data['locker'] as Map<String, dynamic>? ?? data,
    );
  }

  @override
  Future<LockersResponse> getLockersByCabinet(String cabinetId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '$_basePath/lockers/cabinet/$cabinetId',
    );
    return LockersResponse.fromJson(_extractData(response));
  }

  @override
  Future<LockersResponse> getAvailableLockers({
    String? locationId,
    String? cabinetId,
    String? sizeId,
  }) async {
    final queryParams = <String, dynamic>{
      if (locationId != null && locationId.isNotEmpty) 'locationId': locationId,
      if (cabinetId != null && cabinetId.isNotEmpty) 'cabinetId': cabinetId,
      if (sizeId != null && sizeId.isNotEmpty) 'sizeId': sizeId,
    };

    final response = await _apiClient.get<Map<String, dynamic>>(
      '$_basePath/lockers/available',
      queryParameters: queryParams,
    );

    return LockersResponse.fromJson(_extractData(response));
  }

  @override
  Future<List<LockerModel>> getLeastUsedLockers(
    String cabinetId, {
    String? sizeId,
  }) async {
    final queryParams = <String, dynamic>{
      'cabinetId': cabinetId,
      if (sizeId != null) 'sizeId': sizeId,
    };

    final response = await _apiClient.get<Map<String, dynamic>>(
      '$_basePath/least-used',
      queryParameters: queryParams,
    );

    final data = _extractData(response);
    final lockersJson = data['lockers'] as List<dynamic>?;
    if (lockersJson == null) return [];

    return lockersJson
        .map((j) => LockerModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<LockerCountResponse> getLockerCountBySize({
    required String cabinetId,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '$_basePath/count/$cabinetId',
    );

    return LockerCountResponse.fromJson(_extractData(response));
  }

  // ==================== RENTING & MANAGEMENT ====================

  @override
  Future<Map<String, dynamic>> rentLockerFlexible({
    required String lockerId,
    required String cabinetId,
    String itemType = 'OTHER',
    bool skipPhysicalOpen = false,
    String? voucherId,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '$_basePath/rent',
      data: {
        'lockerId': lockerId,
        'cabinetId': cabinetId,
        'itemType': itemType,
        'skipPhysicalOpen': skipPhysicalOpen,
        if (voucherId != null) 'voucherId': voucherId,
      },
    );
    return _extractData(response);
  }

  @override
  Future<FixedRentResponseModel> fixedRentLocker(
    LockerRentRequestModel request,
  ) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/orders/locker/fixed-rent',
      data: request.toJson(),
    );
    return FixedRentResponseModel.fromJson(_extractData(response));
  }

  @override
  Future<Map<String, dynamic>> openLocker(String lockerId) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '$_basePath/rent/open/$lockerId',
    );
    return _extractData(response);
  }

  @override
  Future<Map<String, dynamic>> closeLocker(String lockerId) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '$_basePath/rent/close/$lockerId',
    );
    return _extractData(response);
  }

  @override
  Future<Map<String, dynamic>> getRentedLockerDetail(
    String orderDetailId,
  ) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '$_basePath/rent/$orderDetailId',
    );
    return _extractData(response);
  }

  @override
  Future<Map<String, dynamic>> openLockerTemporarily(String lockerId) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '$_basePath/rent/open/$lockerId',
    );
    return _extractData(response);
  }

  @override
  Future<Map<String, dynamic>> finishRental(String lockerId) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '$_basePath/rent/finish/$lockerId',
    );
    return _extractData(response);
  }
}

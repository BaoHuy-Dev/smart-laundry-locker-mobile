import '../config/api_endpoints.dart';
import '../models/api_response.dart';
import '../models/locker.dart';
import '../network/api_client.dart';

/// Locker Service — replaces lockerService.ts
class LockerService {
  LockerService._();

  static final _dio = ApiClient.instance;

  /// Get all lockers with optional filters (e.g., storeId, status, search)
  static Future<ApiResponse<PaginatedResponse<Locker>>> getLockers({
    int page = 0,
    int size = 10,
    int? storeId,
    String? status,
    String? search,
  }) async {
    final Map<String, dynamic> params = {'page': page, 'size': size};
    if (storeId != null) params['storeId'] = storeId;
    if (status != null) params['status'] = status;
    if (search != null) params['search'] = search;

    final response = await _dio.get(
      ApiEndpoints.lockers,
      queryParameters: params,
    );
    return _parsePaginatedLockers(response.data);
  }

  static Future<ApiResponse<List<Locker>>> getAllLockers() async {
    final response = await _dio.get(ApiEndpoints.lockers);
    return _parseLockerList(response.data);
  }

  static Future<ApiResponse<List<Locker>>> getLockersByStore(
    int storeId,
  ) async {
    final response = await _dio.get(
      ApiEndpoints.lockers,
      queryParameters: {'storeId': storeId},
    );
    return _parseLockerList(response.data);
  }

  static ApiResponse<PaginatedResponse<Locker>> _parsePaginatedLockers(
    Map<String, dynamic> json,
  ) {
    final rawData = json['data'];
    if (rawData is List) {
      final items = rawData
          .map((item) => Locker.fromJson(item as Map<String, dynamic>))
          .toList();
      return ApiResponse(
        success: json['success'] as bool? ?? true,
        message: json['message'] as String?,
        timestamp: json['timestamp'] as String?,
        data: PaginatedResponse<Locker>(
          content: items,
          totalElements: items.length,
          totalPages: 1,
          size: items.length,
          number: 0,
          first: true,
          last: true,
        ),
      );
    }

    return ApiResponse<PaginatedResponse<Locker>>.fromJson(
      json,
      (value) => PaginatedResponse<Locker>.fromJson(
        value as Map<String, dynamic>,
        (item) => Locker.fromJson(item as Map<String, dynamic>),
      ),
    );
  }

  static ApiResponse<List<Locker>> _parseLockerList(Map<String, dynamic> json) {
    final rawData = json['data'];
    if (rawData is Map<String, dynamic>) {
      final content = rawData['content'] as List<dynamic>? ?? const [];
      return ApiResponse(
        success: json['success'] as bool? ?? true,
        message: json['message'] as String?,
        timestamp: json['timestamp'] as String?,
        data: content
            .map((item) => Locker.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    }

    return ApiResponse<List<Locker>>.fromJson(
      json,
      (value) => (value as List<dynamic>)
          .map((item) => Locker.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Get a single locker by ID
  static Future<ApiResponse<Locker>> getLockerById(int id) async {
    final response = await _dio.get(ApiEndpoints.lockerById(id));
    return ApiResponse<Locker>.fromJson(
      response.data,
      (json) => Locker.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get boxes for a specific locker
  static Future<ApiResponse<List<Box>>> getLockerBoxes(int id) async {
    final response = await _dio.get(ApiEndpoints.lockerBoxes(id));
    return ApiResponse<List<Box>>.fromJson(
      response.data,
      (json) => (json as List<dynamic>)
          .map((item) => Box.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  static Future<ApiResponse<List<Box>>> getBoxesByLocker(int lockerId) {
    return getLockerBoxes(lockerId);
  }

  static Future<ApiResponse<List<Box>>> getAvailableBoxes(int lockerId) async {
    final response = await _dio.get(
      ApiEndpoints.availableLockerBoxes(lockerId),
    );
    return ApiResponse<List<Box>>.fromJson(
      response.data,
      (json) => (json as List<dynamic>)
          .map((item) => Box.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> reportLocker(
    int lockerId,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.post(
      ApiEndpoints.reportLocker(lockerId),
      data: data,
    );
    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );
  }

  static Future<ApiResponse<List<Map<String, dynamic>>>> getMyReports() async {
    final response = await _dio.get(ApiEndpoints.myLockerReports);
    return ApiResponse<List<Map<String, dynamic>>>.fromJson(
      response.data,
      (json) => (json as List<dynamic>)
          .map((item) => item as Map<String, dynamic>)
          .toList(),
    );
  }
}

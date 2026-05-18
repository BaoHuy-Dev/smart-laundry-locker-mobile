import '../config/api_endpoints.dart';
import '../models/api_response.dart';
import '../models/store.dart';
import '../network/api_client.dart';

/// Store Service — replaces storeService.ts
class StoreService {
  StoreService._();

  static final _dio = ApiClient.instance;

  /// Get stores with pagination and optional search
  static Future<ApiResponse<PaginatedResponse<Store>>> getStores({
    int page = 0,
    int size = 10,
    String? search,
  }) async {
    final Map<String, dynamic> params = {'page': page, 'size': size};
    if (search != null) params['search'] = search;

    final response = await _dio.get(
      ApiEndpoints.stores,
      queryParameters: params,
    );
    return _parsePaginatedStores(response.data);
  }

  static Future<ApiResponse<List<Store>>> getAllStores() async {
    final response = await _dio.get(ApiEndpoints.stores);
    return _parseStoreList(response.data);
  }

  /// Get a specific store by ID
  static Future<ApiResponse<Store>> getStoreById(int id) async {
    final response = await _dio.get(ApiEndpoints.storeById(id));
    return ApiResponse<Store>.fromJson(
      response.data,
      (json) => Store.fromJson(json as Map<String, dynamic>),
    );
  }

  static Future<ApiResponse<List<Map<String, dynamic>>>> getNearbyStores({
    required double latitude,
    required double longitude,
    int radiusMeters = 5000,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.nearbyStores(
        latitude: latitude,
        longitude: longitude,
        radiusMeters: radiusMeters,
        limit: limit,
      ),
    );
    return ApiResponse<List<Map<String, dynamic>>>.fromJson(
      response.data,
      (json) => (json as List<dynamic>)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(),
    );
  }

  static Future<ApiResponse<PaginatedResponse<Map<String, dynamic>>>>
  getStoreRatings({required int storeId, int page = 0, int size = 10}) async {
    final response = await _dio.get(
      ApiEndpoints.storeRatings(storeId),
      queryParameters: {'page': page, 'size': size},
    );
    return ApiResponse<PaginatedResponse<Map<String, dynamic>>>.fromJson(
      response.data,
      (json) => PaginatedResponse<Map<String, dynamic>>.fromJson(
        json as Map<String, dynamic>,
        (item) => Map<String, dynamic>.from(item as Map),
      ),
    );
  }

  static ApiResponse<PaginatedResponse<Store>> _parsePaginatedStores(
    Map<String, dynamic> json,
  ) {
    final rawData = json['data'];
    if (rawData is List) {
      final items = rawData
          .map((item) => Store.fromJson(item as Map<String, dynamic>))
          .toList();
      return ApiResponse(
        success: json['success'] as bool? ?? true,
        message: json['message'] as String?,
        timestamp: json['timestamp'] as String?,
        data: PaginatedResponse<Store>(
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

    return ApiResponse<PaginatedResponse<Store>>.fromJson(
      json,
      (value) => PaginatedResponse<Store>.fromJson(
        value as Map<String, dynamic>,
        (item) => Store.fromJson(item as Map<String, dynamic>),
      ),
    );
  }

  static ApiResponse<List<Store>> _parseStoreList(Map<String, dynamic> json) {
    final rawData = json['data'];
    if (rawData is Map<String, dynamic>) {
      final content = rawData['content'] as List<dynamic>? ?? const [];
      return ApiResponse(
        success: json['success'] as bool? ?? true,
        message: json['message'] as String?,
        timestamp: json['timestamp'] as String?,
        data: content
            .map((item) => Store.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    }

    return ApiResponse<List<Store>>.fromJson(
      json,
      (value) => (value as List<dynamic>)
          .map((item) => Store.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

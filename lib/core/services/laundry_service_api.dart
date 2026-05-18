import '../config/api_endpoints.dart';
import '../models/api_response.dart';
import '../models/service.dart';
import '../network/api_client.dart';
import '../utils/app_formatters.dart';

/// Laundry Service API — replaces serviceService.ts
class LaundryServiceAPI {
  LaundryServiceAPI._();

  static final _dio = ApiClient.instance;

  /// Get available laundry services
  static Future<ApiResponse<List<LaundryService>>> getServices({
    int? storeId,
    ServiceCategory? category,
  }) async {
    final Map<String, dynamic> params = {};
    if (storeId != null) params['storeId'] = storeId;
    if (category != null) params['category'] = serviceCategoryValue(category);

    final response = await _dio.get(
      ApiEndpoints.services,
      queryParameters: params,
    );
    return ApiResponse<List<LaundryService>>.fromJson(
      response.data,
      (json) => (json as List<dynamic>)
          .map((item) => LaundryService.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  static Future<ApiResponse<List<LaundryService>>> getAllServices() {
    return getServices();
  }

  static Future<ApiResponse<List<LaundryService>>> getServicesByStore(
    int storeId,
  ) {
    return getServices(storeId: storeId);
  }

  static Future<ApiResponse<List<LaundryService>>> getServicesByCategory(
    ServiceCategory category,
  ) {
    return getServices(category: category);
  }

  static Future<ApiResponse<List<LaundryService>>>
  getServicesByStoreAndCategory(int storeId, ServiceCategory category) {
    return getServices(storeId: storeId, category: category);
  }

  static Future<ApiResponse<LaundryService>> getServiceById(int id) async {
    final response = await _dio.get(ApiEndpoints.serviceById(id));
    return ApiResponse<LaundryService>.fromJson(
      response.data,
      (json) => LaundryService.fromJson(json as Map<String, dynamic>),
    );
  }
}

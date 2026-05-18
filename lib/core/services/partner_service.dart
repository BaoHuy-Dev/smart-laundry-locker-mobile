import '../config/api_endpoints.dart';
import '../models/api_response.dart';
import '../models/order.dart';
import '../models/partner.dart';
import '../network/api_client.dart';

/// Partner Service — replaces partnerService.ts
class PartnerService {
  PartnerService._();

  static final _dio = ApiClient.instance;

  /// Get dashboard data for partner
  static Future<ApiResponse<PartnerDashboard>> getDashboard() async {
    final response = await _dio.get(ApiEndpoints.partnerDashboard);
    return ApiResponse<PartnerDashboard>.fromJson(
      response.data,
      (json) => PartnerDashboard.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get partner profile and settings
  static Future<ApiResponse<PartnerProfile>> getProfile() async {
    final response = await _dio.get(ApiEndpoints.partnerProfile);
    return ApiResponse<PartnerProfile>.fromJson(
      response.data,
      (json) => PartnerProfile.fromJson(json as Map<String, dynamic>),
    );
  }

  static Future<ApiResponse<PartnerOrderStatistics>>
  getOrderStatistics() async {
    final response = await _dio.get(ApiEndpoints.partnerOrderStatistics);
    return ApiResponse<PartnerOrderStatistics>.fromJson(
      response.data,
      (json) => PartnerOrderStatistics.fromJson(json as Map<String, dynamic>),
    );
  }

  static Future<ApiResponse<PaginatedResponse<Order>>> getOrders({
    String? status,
    int page = 0,
    int size = 10,
  }) async {
    final params = <String, dynamic>{'page': page, 'size': size};
    if (status != null && status.isNotEmpty) params['status'] = status;
    final response = await _dio.get(
      ApiEndpoints.partnerOrders,
      queryParameters: params,
    );
    return ApiResponse<PaginatedResponse<Order>>.fromJson(response.data, (
      json,
    ) {
      if (json is List<dynamic>) {
        return PaginatedResponse<Order>(
          content: json
              .map((item) => Order.fromJson(item as Map<String, dynamic>))
              .toList(),
          totalElements: json.length,
          totalPages: 1,
          size: json.length,
          number: 0,
          first: true,
          last: true,
        );
      }
      return PaginatedResponse<Order>.fromJson(
        json as Map<String, dynamic>,
        (item) => Order.fromJson(item as Map<String, dynamic>),
      );
    });
  }

  static Future<ApiResponse<StaffOrderSummary>> getStaffOrderSummary() async {
    final response = await _dio.get(ApiEndpoints.staffOrders);
    return ApiResponse<StaffOrderSummary>.fromJson(
      response.data,
      (json) => StaffOrderSummary.fromJson(json as Map<String, dynamic>),
    );
  }

  static Future<ApiResponse<List<Map<String, dynamic>>>> getStores() async {
    final response = await _dio.get(ApiEndpoints.partnerStores);
    return ApiResponse<List<Map<String, dynamic>>>.fromJson(
      response.data,
      (json) => (json as List<dynamic>)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(),
    );
  }

  static Future<ApiResponse<PartnerProfile>> registerPartner(
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.post(ApiEndpoints.partnerProfile, data: data);
    return ApiResponse<PartnerProfile>.fromJson(
      response.data,
      (json) => PartnerProfile.fromJson(json as Map<String, dynamic>),
    );
  }
}

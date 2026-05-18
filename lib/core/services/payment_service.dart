import '../config/api_endpoints.dart';
import '../models/api_response.dart';
import '../models/payment.dart';
import '../network/api_client.dart';
import '../utils/app_formatters.dart';

/// Payment Service — replaces paymentService.ts
class PaymentService {
  PaymentService._();

  static final _dio = ApiClient.instance;

  /// Initiate payment for an order and return payment URL
  static Future<ApiResponse<Payment>> createPayment(
    int orderId,
    PaymentMethod method,
  ) async {
    final response = await _dio.post(
      ApiEndpoints.createPayment,
      data: {'orderId': orderId, 'paymentMethod': paymentMethodValue(method)},
    );
    return ApiResponse<Payment>.fromJson(
      response.data,
      (json) => Payment.fromJson(json as Map<String, dynamic>),
    );
  }

  static Future<ApiResponse<Payment>> getPaymentById(int id) async {
    final response = await _dio.get(ApiEndpoints.paymentById(id));
    return ApiResponse<Payment>.fromJson(
      response.data,
      (json) => Payment.fromJson(json as Map<String, dynamic>),
    );
  }

  static Future<ApiResponse<List<Payment>>> getPaymentsByOrder(
    int orderId,
  ) async {
    final response = await _dio.get(ApiEndpoints.paymentsByOrder(orderId));
    return ApiResponse<List<Payment>>.fromJson(
      response.data,
      (json) => (json as List<dynamic>)
          .map((item) => Payment.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  static Future<ApiResponse<RefundResponse>> requestRefund(
    int paymentId,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.post(
      ApiEndpoints.paymentRefund(paymentId),
      data: data,
    );
    return ApiResponse<RefundResponse>.fromJson(
      response.data,
      (json) => RefundResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  static Future<ApiResponse<RefundResponse>> getRefundStatus(
    int refundId,
  ) async {
    final response = await _dio.get(ApiEndpoints.refundStatus(refundId));
    return ApiResponse<RefundResponse>.fromJson(
      response.data,
      (json) => RefundResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  static Future<ApiResponse<List<RefundResponse>>> getOrderRefunds(
    int orderId,
  ) async {
    final response = await _dio.get(ApiEndpoints.orderRefunds(orderId));
    return ApiResponse<List<RefundResponse>>.fromJson(
      response.data,
      (json) => (json as List<dynamic>)
          .map((item) => RefundResponse.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

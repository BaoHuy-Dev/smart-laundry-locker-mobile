import '../config/api_endpoints.dart';
import '../models/api_response.dart';
import '../models/order.dart';
import '../network/api_client.dart';
import '../utils/app_formatters.dart';

/// Order Service — replaces orderService.ts
class OrderService {
  OrderService._();

  static final _dio = ApiClient.instance;

  /// Create a new order
  static Future<ApiResponse<Order>> createOrder(
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.post(ApiEndpoints.orders, data: data);
    return ApiResponse<Order>.fromJson(
      response.data,
      (json) => Order.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get orders with pagination
  static Future<ApiResponse<PaginatedResponse<Order>>> getOrders({
    int page = 0,
    int size = 10,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.myOrders,
      queryParameters: {'page': page, 'size': size, 'sort': 'createdAt,desc'},
    );
    return ApiResponse<PaginatedResponse<Order>>.fromJson(
      response.data,
      (json) => PaginatedResponse<Order>.fromJson(
        json as Map<String, dynamic>,
        (item) => Order.fromJson(item as Map<String, dynamic>),
      ),
    );
  }

  /// Get order by ID
  static Future<ApiResponse<Order>> getOrderById(int id) async {
    final response = await _dio.get(ApiEndpoints.orderById(id));
    return ApiResponse<Order>.fromJson(
      response.data,
      (json) => Order.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Confirm order (after placing items in locker)
  static Future<ApiResponse<Order>> confirmOrder(int id) async {
    final response = await _dio.put(ApiEndpoints.confirmOrder(id));
    return ApiResponse<Order>.fromJson(
      response.data,
      (json) => Order.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Checkout order with payment method
  static Future<ApiResponse<Map<String, dynamic>>> checkoutOrder(
    int id,
    String paymentMethod,
  ) async {
    final response = await _dio.post(
      ApiEndpoints.checkoutOrder(id),
      data: {'paymentMethod': paymentMethod},
    );
    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );
  }

  /// Cancel order
  static Future<ApiResponse<Order>> cancelOrder(int id, String reason) async {
    final response = await _dio.put(
      ApiEndpoints.cancelOrder(id),
      data: {'reason': reason},
    );
    return ApiResponse<Order>.fromJson(
      response.data,
      (json) => Order.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get detailed order status tracking
  static Future<ApiResponse<OrderTrackingDetail>> getOrderStatus(int id) async {
    final response = await _dio.get(ApiEndpoints.orderStatus(id));
    return ApiResponse<OrderTrackingDetail>.fromJson(
      response.data,
      (json) => OrderTrackingDetail.fromJson(json as Map<String, dynamic>),
    );
  }

  static Future<ApiResponse<Order>> getOrderByPin(String pin) async {
    final response = await _dio.get(ApiEndpoints.orderByPin(pin));
    return ApiResponse<Order>.fromJson(
      response.data,
      (json) => Order.fromJson(json as Map<String, dynamic>),
    );
  }

  static Future<ApiResponse<Order>> getOrderByCode(String code) async {
    final response = await _dio.get(ApiEndpoints.orderByCode(code));
    return ApiResponse<Order>.fromJson(
      response.data,
      (json) => Order.fromJson(json as Map<String, dynamic>),
    );
  }

  static Future<ApiResponse<Order>> applyPromotion(
    int orderId,
    String promotionCode,
  ) async {
    final response = await _dio.put(
      ApiEndpoints.applyPromotion(orderId, promotionCode),
    );
    return ApiResponse<Order>.fromJson(
      response.data,
      (json) => Order.fromJson(json as Map<String, dynamic>),
    );
  }

  static Future<ApiResponse<Order>> removePromotion(int orderId) async {
    final response = await _dio.delete(ApiEndpoints.removePromotion(orderId));
    return ApiResponse<Order>.fromJson(
      response.data,
      (json) => Order.fromJson(json as Map<String, dynamic>),
    );
  }

  static Future<ApiResponse<Order>> completeOrder(int orderId) async {
    final response = await _dio.put(ApiEndpoints.completeOrder(orderId));
    return ApiResponse<Order>.fromJson(
      response.data,
      (json) => Order.fromJson(json as Map<String, dynamic>),
    );
  }

  static Future<ApiResponse<Order>> pickupStorageOrder(int orderId) async {
    final response = await _dio.post(ApiEndpoints.pickupStorage(orderId));
    return ApiResponse<Order>.fromJson(
      response.data,
      (json) => Order.fromJson(json as Map<String, dynamic>),
    );
  }

  static Future<ApiResponse<Order>> resetOrderPin(int orderId) async {
    final response = await _dio.post(ApiEndpoints.resetPin(orderId));
    return ApiResponse<Order>.fromJson(
      response.data,
      (json) => Order.fromJson(json as Map<String, dynamic>),
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> rateOrder(
    int orderId,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.post(
      ApiEndpoints.rateOrder(orderId),
      data: data,
    );
    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> getOrderRating(
    int orderId,
  ) async {
    final response = await _dio.get(ApiEndpoints.orderRating(orderId));
    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );
  }

  static Future<ApiResponse<List<Map<String, dynamic>>>> getMyRatings() async {
    final response = await _dio.get(ApiEndpoints.myRatings);
    return ApiResponse<List<Map<String, dynamic>>>.fromJson(
      response.data,
      (json) => (json as List<dynamic>)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(),
    );
  }

  static Future<ApiResponse<OrderTimelineResponse>> getOrderTimeline(
    int orderId,
  ) async {
    final response = await _dio.get(ApiEndpoints.orderTimeline(orderId));
    return ApiResponse<OrderTimelineResponse>.fromJson(
      response.data,
      (json) => OrderTimelineResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> createComplaint(
    int orderId,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.post(
      ApiEndpoints.orderComplaint(orderId),
      data: data,
    );
    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );
  }

  static Future<ApiResponse<List<Map<String, dynamic>>>> getOrderComplaints(
    int orderId,
  ) async {
    final response = await _dio.get(ApiEndpoints.orderComplaints(orderId));
    return ApiResponse<List<Map<String, dynamic>>>.fromJson(
      response.data,
      (json) => (json as List<dynamic>)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(),
    );
  }

  static Future<ApiResponse<List<Map<String, dynamic>>>>
  getMyComplaints() async {
    final response = await _dio.get(ApiEndpoints.myComplaints);
    return ApiResponse<List<Map<String, dynamic>>>.fromJson(
      response.data,
      (json) => (json as List<dynamic>)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(),
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> reorderFromExisting(
    int orderId,
  ) async {
    final response = await _dio.post(ApiEndpoints.reorder(orderId));
    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );
  }

  static Future<ApiResponse<Order>> collectOrder(int orderId) async {
    final response = await _dio.put(ApiEndpoints.collectOrder(orderId));
    return ApiResponse<Order>.fromJson(
      response.data,
      (json) => Order.fromJson(json as Map<String, dynamic>),
    );
  }

  static Future<ApiResponse<Order>> processOrder(int orderId) async {
    final response = await _dio.put(ApiEndpoints.processOrder(orderId));
    return ApiResponse<Order>.fromJson(
      response.data,
      (json) => Order.fromJson(json as Map<String, dynamic>),
    );
  }

  static Future<ApiResponse<Order>> markReady(int orderId) async {
    final response = await _dio.put(ApiEndpoints.readyOrder(orderId));
    return ApiResponse<Order>.fromJson(
      response.data,
      (json) => Order.fromJson(json as Map<String, dynamic>),
    );
  }

  static Future<ApiResponse<Order>> returnOrder(int orderId, int boxId) async {
    final response = await _dio.put(ApiEndpoints.returnOrder(orderId, boxId));
    return ApiResponse<Order>.fromJson(
      response.data,
      (json) => Order.fromJson(json as Map<String, dynamic>),
    );
  }

  static Map<String, dynamic> createOrderPayload({
    required OrderType type,
    required int lockerId,
    required int boxId,
    required List<int> serviceIds,
    String? customerNote,
    String? promotionCode,
    double? estimatedWeight,
    DateTime? intendedReceiveAt,
    String? receiverName,
    String? receiverPhone,
  }) {
    final typeValue = orderTypeValue(type);
    return {
      'type': typeValue,
      'serviceCategory': typeValue == 'STORAGE' ? 'STORAGE' : 'LAUNDRY',
      'lockerId': lockerId,
      'boxId': boxId,
      'serviceIds': serviceIds,
      if (customerNote != null && customerNote.trim().isNotEmpty)
        'customerNote': customerNote.trim(),
      if (promotionCode != null && promotionCode.trim().isNotEmpty)
        'promotionCode': promotionCode.trim(),
      if (estimatedWeight != null && estimatedWeight > 0)
        'estimatedWeight': estimatedWeight,
      if (intendedReceiveAt != null)
        'intendedReceiveAt': intendedReceiveAt.toIso8601String(),
      if (receiverName != null && receiverName.trim().isNotEmpty)
        'receiverName': receiverName.trim(),
      if (receiverPhone != null && receiverPhone.trim().isNotEmpty)
        'receiverPhone': receiverPhone.trim(),
    };
  }
}

import 'package:smart_laundry_locker/features/user_laundry/infrastructure/models/user_laundry_models.dart';
import 'package:smart_laundry_locker/features/user_laundry/infrastructure/services/user_gateway_client.dart';

class UserOrderService extends UserGatewayClient {
  UserOrderService(super.apiClient);

  Future<List<UserLaundryOrder>> getMyOrders({
    int page = 0,
    int size = 20,
    String? status,
  }) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/api/orders/my-orders',
      queryParameters: {
        'page': page,
        'size': size,
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );
    return unwrapList(response)
        .whereType<Map<String, dynamic>>()
        .map(UserLaundryOrder.fromJson)
        .where((order) => order.id > 0)
        .toList();
  }

  Future<UserLaundryOrder> getOrder(int orderId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/api/orders/$orderId',
    );
    return UserLaundryOrder.fromJson(unwrapMap(response));
  }

  Future<UserLaundryOrder> getOrderStatus(int orderId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/api/orders/$orderId/status',
    );
    return UserLaundryOrder.fromJson(unwrapMap(response));
  }

  Future<UserLaundryOrder> createLaundryOrder({
    required int storeId,
    required int lockerId,
    required int sendBoxId,
    required String serviceCategory,
    required List<int> serviceIds,
    String type = 'LAUNDRY',
    String? customerNote,
    String? promotionCode,
    double? estimatedWeight,
    double? totalPrice,
  }) async {
    final userId = await currentUserId();
    final response = await apiClient.post<Map<String, dynamic>>(
      '/api/orders',
      data: {
        'userId': userId,
        'storeId': storeId,
        'lockerId': lockerId,
        'sendBoxId': sendBoxId,
        'boxIds': [sendBoxId],
        'type': type,
        'serviceCategory': serviceCategory,
        'serviceIds': serviceIds,
        'customerNote': customerNote,
        'promotionCode': promotionCode,
        'estimatedWeight': estimatedWeight,
        'totalPrice': totalPrice,
      },
    );
    return UserLaundryOrder.fromJson(unwrapMap(response));
  }

  Future<UserLaundryOrder> confirmOrder(int orderId) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/api/orders/$orderId/confirm',
    );
    return UserLaundryOrder.fromJson(unwrapMap(response));
  }

  Future<UserLaundryOrder> cancelOrder(int orderId, {String? reason}) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/api/orders/$orderId/cancel',
      data: {'reason': reason},
    );
    return UserLaundryOrder.fromJson(unwrapMap(response));
  }
}

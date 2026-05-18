import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/models/order.dart';
import '../../../../core/services/order_service.dart';

part 'orders_provider.g.dart';

@riverpod
class OrdersNotifier extends _$OrdersNotifier {
  @override
  FutureOr<List<Order>> build() async {
    return _fetchOrders();
  }

  Future<List<Order>> _fetchOrders({int page = 0}) async {
    try {
      final response = await OrderService.getOrders(page: page, size: 20);
      return response.data.content;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchOrders());
  }

  Future<void> cancelOrder(int orderId, String reason) async {
    try {
      await OrderService.cancelOrder(orderId, reason);
      // Refresh list after cancelling
      await refresh();
    } catch (e) {
      rethrow;
    }
  }
}

@riverpod
Future<OrderTrackingDetail> orderTracking(
  OrderTrackingRef ref,
  int orderId,
) async {
  final response = await OrderService.getOrderStatus(orderId);
  return response.data;
}

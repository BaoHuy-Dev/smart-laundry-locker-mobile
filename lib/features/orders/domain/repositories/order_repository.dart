import 'package:smart_laundry_locker/features/orders/domain/entities/order.dart';
import 'package:smart_laundry_locker/features/orders/domain/entities/order_detail.dart';
import 'package:smart_laundry_locker/core/domain/entities/pagination.dart';
import 'package:smart_laundry_locker/features/orders/domain/entities/courier_order.dart';
import 'package:smart_laundry_locker/features/orders/domain/entities/courier_today_stats.dart';
import 'package:dartz/dartz.dart' hide Order;
import 'package:smart_laundry_locker/core/errors/failures.dart';

/// Repository Contract: OrderRepository
/// Định nghĩa interface cho data access liên quan đến orders.
abstract class OrderRepository {
  /// Lấy danh sách đơn hàng của user hiện tại (phân trang)
  /// API: GET /orders/me
  Future<Either<Failure, PaginatedResult<Order>>> getMyOrders({
    int page = 1,
    int limit = 10,
    String? status,
    String? orderCode,
    String? userId,
    String? search,
    String? orderBy,
    String? orderDirection,
    String? orderType,
  });

  /// Lấy chi tiết một đơn hàng
  /// API: GET /orders/me/:id
  Future<Either<Failure, OrderWithDetails>> getMyOrderDetail(String id);

  /// Lấy danh sách đơn hàng đang active (thuê cố định)
  /// API: GET /orders/my/active
  Future<Either<Failure, List<Order>>> getMyActiveOrders();

  /// Thanh toán nợ phí
  /// API: POST /orders/pay-fee
  Future<Either<Failure, double>> payOverdueFee(String orderId);

  /// Lịch sử đơn giao của courier
  /// API: GET /courier/history
  Future<Either<Failure, List<CourierOrder>>> getCourierOrderHistory({
    int page = 1,
    int limit = 20,
  });

  /// Thống kê đơn courier trong hôm nay
  /// API: GET /courier/stats/today
  Future<Either<Failure, CourierTodayStats>> getCourierTodayStats();

  /// Lấy danh sách đơn hàng đã nhận/hủy/hoàn thành của courier hiện tại
  /// API: GET /orders/courier/me
  Future<Either<Failure, PaginatedResult<OrderWithDetails>>> getCourierMe({
    int page = 1,
    int limit = 10,
    String? status,
  });

  /// Tạo mới mã mở tủ kiosk (OWNER)
  /// API: POST /orders/recreate-access-code
  Future<Either<Failure, bool>> recreateAccessCode(String orderDetailId);

  /// Lấy chi tiết đơn hàng cho courier
  /// API: GET /orders/courier/detail/:id
  Future<Either<Failure, OrderWithDetails>> getCourierOrderDetail(String id);

  /// Courier hủy đơn hàng
  /// API: POST /orders/courier/cancel
  Future<Either<Failure, Order>> courierCancelOrder({
    required String orderId,
    required String reason,
  });
}

class OrderWithDetails {
  final Order order;
  final List<OrderDetail> orderDetails;

  const OrderWithDetails({required this.order, required this.orderDetails});

  String get orderId => order.id;
  String get orderCode => order.orderCode;
  String get status => order.status;
  DateTime? get time => order.createdAt;

  String get originName {
    if (orderDetails.isNotEmpty) {
      return orderDetails.first.cabinetName ?? 'N/A';
    }
    return 'N/A';
  }

  String get destinationName {
    if (orderDetails.isNotEmpty) {
      final last = orderDetails.last;
      return last.receiverAddress ?? last.cabinetName ?? 'N/A';
    }
    return 'N/A';
  }

  double get income {
    // Basic income logic: total amount minus some fees,
    // or just return the total amount if that's what's shown.
    // For now, return order's total amount or similar.
    return order.accumulatedFee;
  }
}

import 'package:smart_laundry_locker/core/errors/failures.dart';
import 'package:smart_laundry_locker/features/orders/domain/entities/order.dart';
import 'package:smart_laundry_locker/features/orders/domain/repositories/order_repository.dart';
import 'package:dartz/dartz.dart' hide Order;

class CourierCancelOrderUseCase {
  final OrderRepository repository;

  CourierCancelOrderUseCase(this.repository);

  Future<Either<Failure, Order>> call(String orderId, String reason) async {
    return await repository.courierCancelOrder(
      orderId: orderId,
      reason: reason,
    );
  }
}

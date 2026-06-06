import 'package:smart_laundry_locker/core/errors/failures.dart';
import 'package:smart_laundry_locker/features/orders/domain/entities/courier_order.dart';
import 'package:smart_laundry_locker/features/orders/domain/repositories/order_repository.dart';
import 'package:dartz/dartz.dart';

class GetCourierOrderHistoryUseCase {
  final OrderRepository _repository;

  const GetCourierOrderHistoryUseCase(this._repository);

  Future<Either<Failure, List<CourierOrder>>> call({
    int page = 1,
    int limit = 20,
  }) {
    return _repository.getCourierOrderHistory(page: page, limit: limit);
  }
}

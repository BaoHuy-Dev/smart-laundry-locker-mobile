import 'package:smart_laundry_locker/features/orders/domain/repositories/order_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:smart_laundry_locker/core/errors/failures.dart';

class GetCourierOrderDetailUseCase {
  final OrderRepository _repository;

  GetCourierOrderDetailUseCase(this._repository);

  Future<Either<Failure, OrderWithDetails>> call(String id) {
    return _repository.getCourierOrderDetail(id);
  }
}

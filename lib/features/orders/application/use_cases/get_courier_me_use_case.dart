import 'package:smart_laundry_locker/core/errors/failures.dart';
import 'package:smart_laundry_locker/features/orders/domain/repositories/order_repository.dart';
import 'package:smart_laundry_locker/core/domain/entities/pagination.dart';
import 'package:dartz/dartz.dart';

class GetCourierMeUseCase {
  final OrderRepository _repository;

  const GetCourierMeUseCase(this._repository);

  Future<Either<Failure, PaginatedResult<OrderWithDetails>>> call({
    int page = 1,
    int limit = 20,
    String? status,
  }) {
    return _repository.getCourierMe(page: page, limit: limit, status: status);
  }
}

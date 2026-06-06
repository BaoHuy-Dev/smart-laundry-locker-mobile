import 'package:smart_laundry_locker/core/errors/failures.dart';
import 'package:smart_laundry_locker/features/logistics_send/domain/repositories/logistics_send_repository.dart';
import 'package:dartz/dartz.dart';

class CustomerCancelOrderUseCase {
  final LogisticsSendRepository _repository;

  CustomerCancelOrderUseCase(this._repository);

  Future<Either<Failure, bool>> call(String orderId) async {
    return await _repository.customerCancelOrder(orderId);
  }
}

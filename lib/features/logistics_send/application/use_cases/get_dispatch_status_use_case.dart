import 'package:smart_laundry_locker/core/errors/failures.dart';
import 'package:smart_laundry_locker/features/logistics_send/domain/entities/dispatch_status_entity.dart';
import 'package:smart_laundry_locker/features/logistics_send/domain/repositories/logistics_send_repository.dart';
import 'package:dartz/dartz.dart';

class GetDispatchStatusUseCase {
  final LogisticsSendRepository _repository;

  GetDispatchStatusUseCase(this._repository);

  Future<Either<Failure, DispatchStatusEntity>> execute(String dispatchId) {
    return _repository.getDispatchStatus(dispatchId);
  }
}

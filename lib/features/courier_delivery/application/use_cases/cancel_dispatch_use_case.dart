import 'package:smart_laundry_locker/core/errors/failures.dart';
import 'package:smart_laundry_locker/features/courier_delivery/domain/repositories/courier_delivery_repository.dart';
import 'package:dartz/dartz.dart';

class CancelDispatchUseCase {
  final CourierDeliveryRepository _repository;

  CancelDispatchUseCase(this._repository);

  Future<Either<Failure, bool>> call(String dispatchId) async {
    try {
      final success = await _repository.cancelDispatch(dispatchId);
      return Right(success);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

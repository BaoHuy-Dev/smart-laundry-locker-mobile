import 'package:smart_laundry_locker/core/errors/failures.dart';
import 'package:smart_laundry_locker/features/courier_delivery/domain/repositories/courier_delivery_repository.dart';
import 'package:dartz/dartz.dart';

class DepositOpenLockerUseCase {
  final CourierDeliveryRepository _repository;

  DepositOpenLockerUseCase(this._repository);

  Future<Either<Failure, bool>> call(String orderCode, String lockerId) async {
    try {
      final success = await _repository.depositOpenLocker(orderCode, lockerId);
      return Right(success);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

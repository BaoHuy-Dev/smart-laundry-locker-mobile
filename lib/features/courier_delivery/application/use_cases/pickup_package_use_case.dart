import 'package:smart_laundry_locker/core/errors/failures.dart';
import 'package:smart_laundry_locker/features/courier_delivery/domain/repositories/courier_delivery_repository.dart';
import 'package:smart_laundry_locker/features/courier_delivery/infrastructure/models/responses.dart';
import 'package:dartz/dartz.dart';

class PickupPackageUseCase {
  final CourierDeliveryRepository _repository;

  PickupPackageUseCase(this._repository);

  Future<Either<Failure, PickupPackageResponse>> call(String accessCode) async {
    try {
      final response = await _repository.pickupPackage(accessCode);
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

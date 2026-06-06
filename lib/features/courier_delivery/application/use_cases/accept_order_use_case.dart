import 'package:smart_laundry_locker/core/errors/failures.dart';
import 'package:smart_laundry_locker/features/courier_delivery/domain/repositories/courier_delivery_repository.dart';
import 'package:smart_laundry_locker/features/courier_delivery/infrastructure/models/responses.dart';
import 'package:dartz/dartz.dart';

class AcceptOrderUseCase {
  final CourierDeliveryRepository _repository;

  AcceptOrderUseCase(this._repository);

  Future<Either<Failure, CourierAcceptResponse>> call(String dispatchId) async {
    try {
      final response = await _repository.acceptOrder(dispatchId);
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

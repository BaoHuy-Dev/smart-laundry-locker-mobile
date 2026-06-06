import 'package:smart_laundry_locker/features/courier_delivery/domain/repositories/courier_delivery_repository.dart';
import 'package:smart_laundry_locker/features/courier_delivery/infrastructure/models/responses.dart';
import 'package:smart_laundry_locker/core/errors/failures.dart';
import 'package:dartz/dartz.dart';

class GetActiveDeliveryUseCase {
  final CourierDeliveryRepository repository;

  GetActiveDeliveryUseCase(this.repository);

  Future<Either<Failure, CourierAcceptResponse>> call() async {
    try {
      final result = await repository.getCourierActiveDelivery();
      return Right(CourierAcceptResponse.fromJson(result));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

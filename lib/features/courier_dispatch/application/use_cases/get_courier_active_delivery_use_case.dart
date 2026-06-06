import 'package:smart_laundry_locker/features/courier_dispatch/domain/entities/courier_active_delivery.dart';
import 'package:smart_laundry_locker/features/courier_dispatch/domain/repositories/courier_dispatch_repository.dart';
import 'package:dartz/dartz.dart';

import 'package:smart_laundry_locker/core/errors/failures.dart';

class GetCourierActiveDeliveryUseCase {
  final CourierDispatchRepository repository;

  GetCourierActiveDeliveryUseCase(this.repository);

  Future<Either<Failure, CourierActiveDelivery>> call() async {
    try {
      final result = await repository.getCourierActiveDelivery();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

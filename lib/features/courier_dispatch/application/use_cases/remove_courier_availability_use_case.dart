import 'package:smart_laundry_locker/core/errors/failures.dart';
import 'package:smart_laundry_locker/features/courier_dispatch/domain/repositories/courier_dispatch_repository.dart';
import 'package:dartz/dartz.dart';

class RemoveCourierAvailabilityUseCase {
  final CourierDispatchRepository _repository;

  RemoveCourierAvailabilityUseCase(this._repository);

  Future<Either<Failure, void>> call() async {
    try {
      await _repository.removeAvailability();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

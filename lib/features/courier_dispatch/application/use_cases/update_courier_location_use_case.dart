import 'package:smart_laundry_locker/core/errors/failures.dart';
import 'package:smart_laundry_locker/features/courier_dispatch/domain/repositories/courier_dispatch_repository.dart';
import 'package:dartz/dartz.dart';

class UpdateCourierLocationUseCase {
  final CourierDispatchRepository _repository;

  UpdateCourierLocationUseCase(this._repository);

  Future<Either<Failure, void>> call(double latitude, double longitude) async {
    try {
      await _repository.updateLocation(latitude, longitude);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

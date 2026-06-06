import 'package:dartz/dartz.dart';
import 'package:smart_laundry_locker/core/errors/failures.dart';
import 'package:smart_laundry_locker/features/courier_registration/domain/entities/courier_application_entity.dart';
import 'package:smart_laundry_locker/features/courier_registration/domain/repositories/courier_registration_repository.dart';

class CheckCourierStatusUseCase {
  final CourierRegistrationRepository _repository;

  CheckCourierStatusUseCase(this._repository);

  Future<Either<Failure, CourierApplicationEntity?>> call(
    CheckCourierStatusParams params,
  ) async {
    return await _repository.checkApplicationStatus(userId: params.userId);
  }
}

class CheckCourierStatusParams {
  final String userId;

  const CheckCourierStatusParams({required this.userId});
}

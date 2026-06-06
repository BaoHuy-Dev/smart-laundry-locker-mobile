import 'package:smart_laundry_locker/core/errors/failures.dart';
import 'package:smart_laundry_locker/features/staff_application/domain/entities/staff_application.dart';
import 'package:smart_laundry_locker/features/staff_application/domain/repositories/staff_application_repository.dart';
import 'package:dartz/dartz.dart';

class GetStaffApplicationStatusUseCase {
  final StaffApplicationRepository _repository;

  GetStaffApplicationStatusUseCase(this._repository);

  Future<Either<Failure, StaffApplication?>> call(String userId) {
    return _repository.getStatus(userId);
  }
}

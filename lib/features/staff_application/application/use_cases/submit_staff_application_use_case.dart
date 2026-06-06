import 'package:smart_laundry_locker/core/errors/failures.dart';
import 'package:smart_laundry_locker/features/staff_application/domain/entities/staff_application.dart';
import 'package:smart_laundry_locker/features/staff_application/domain/repositories/staff_application_repository.dart';
import 'package:dartz/dartz.dart';

class SubmitStaffApplicationUseCase {
  final StaffApplicationRepository _repository;

  SubmitStaffApplicationUseCase(this._repository);

  Future<Either<Failure, StaffApplication>> call(
    SubmitStaffApplicationParams params,
  ) {
    return _repository.submit(params);
  }
}

class SubmitStaffApplicationParams {
  final String legalName;
  final String licensePlate;
  final String vehicleTypeId;
  final String role;

  final String frontVehicleImagePath;
  final String backVehicleImagePath;
  final String portraitImagePath;

  const SubmitStaffApplicationParams({
    required this.legalName,
    required this.licensePlate,
    required this.vehicleTypeId,
    required this.role,
    required this.frontVehicleImagePath,
    required this.backVehicleImagePath,
    required this.portraitImagePath,
  });
}

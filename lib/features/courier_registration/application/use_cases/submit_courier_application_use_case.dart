import 'package:dartz/dartz.dart';
import 'package:smart_laundry_locker/core/errors/failures.dart';
import 'package:smart_laundry_locker/features/courier_registration/domain/entities/courier_application_entity.dart';
import 'package:smart_laundry_locker/features/courier_registration/domain/repositories/courier_registration_repository.dart';

class SubmitCourierApplicationUseCase {
  final CourierRegistrationRepository _repository;

  SubmitCourierApplicationUseCase(this._repository);

  Future<Either<Failure, CourierApplicationEntity>> call(
    SubmitCourierApplicationParams params,
  ) async {
    return await _repository.submitApplication(
      legalName: params.legalName,
      licensePlate: params.licensePlate,
      vehicleType: params.vehicleType,
      frontVehicleImagePath: params.frontVehicleImagePath,
      backVehicleImagePath: params.backVehicleImagePath,
      portraitImagePath: params.portraitImagePath,
    );
  }
}

class SubmitCourierApplicationParams {
  final String legalName;
  final String licensePlate;
  final String vehicleType; // 'BIKE', 'MOTORBIKE', 'CAR'
  final String frontVehicleImagePath;
  final String backVehicleImagePath;
  final String portraitImagePath;

  const SubmitCourierApplicationParams({
    required this.legalName,
    required this.licensePlate,
    required this.vehicleType,
    required this.frontVehicleImagePath,
    required this.backVehicleImagePath,
    required this.portraitImagePath,
  });
}

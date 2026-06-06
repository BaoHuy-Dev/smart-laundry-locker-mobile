import 'package:dartz/dartz.dart';
import 'package:smart_laundry_locker/core/errors/failures.dart';
import 'package:smart_laundry_locker/features/courier_registration/domain/entities/courier_application_entity.dart';

abstract class CourierRegistrationRepository {
  Future<Either<Failure, CourierApplicationEntity>> submitApplication({
    required String legalName,
    required String licensePlate,
    required String vehicleType,
    required String frontVehicleImagePath,
    required String backVehicleImagePath,
    required String portraitImagePath,
  });

  //check status đơn đăng ký
  Future<Either<Failure, CourierApplicationEntity?>> checkApplicationStatus({
    required String userId,
  });
}

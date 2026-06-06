import 'package:smart_laundry_locker/core/errors/failures.dart';
import 'package:smart_laundry_locker/features/staff_application/application/use_cases/submit_staff_application_use_case.dart';
import 'package:smart_laundry_locker/features/staff_application/domain/entities/staff_application.dart';
import 'package:smart_laundry_locker/features/staff_application/domain/entities/vehicle_type.dart';
import 'package:dartz/dartz.dart';

abstract class StaffApplicationRepository {
  Future<Either<Failure, StaffApplication>> submit(
    SubmitStaffApplicationParams params,
  );

  Future<Either<Failure, StaffApplication?>> getStatus(String userId);

  Future<Either<Failure, List<VehicleType>>> getVehicleTypes();
}

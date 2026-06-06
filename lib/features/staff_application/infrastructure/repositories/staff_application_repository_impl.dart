import 'package:smart_laundry_locker/core/errors/failures.dart';
import 'package:smart_laundry_locker/core/network/api_client.dart';
import 'package:smart_laundry_locker/features/staff_application/application/use_cases/submit_staff_application_use_case.dart';
import 'package:smart_laundry_locker/features/staff_application/domain/entities/staff_application.dart';
import 'package:smart_laundry_locker/features/staff_application/domain/entities/vehicle_type.dart';
import 'package:smart_laundry_locker/features/staff_application/domain/repositories/staff_application_repository.dart';
import 'package:smart_laundry_locker/features/staff_application/infrastructure/data_sources/staff_application_remote_data_source.dart';
import 'package:dartz/dartz.dart';

class StaffApplicationRepositoryImpl implements StaffApplicationRepository {
  final StaffApplicationRemoteDataSource _remote;

  StaffApplicationRepositoryImpl({
    required StaffApplicationRemoteDataSource remote,
  }) : _remote = remote;

  @override
  Future<Either<Failure, StaffApplication>> submit(
    SubmitStaffApplicationParams params,
  ) async {
    try {
      final model = await _remote.submit(
        legalName: params.legalName,
        licensePlate: params.licensePlate,
        vehicleTypeId: params.vehicleTypeId,
        role: params.role,
        frontVehicleImagePath: params.frontVehicleImagePath,
        backVehicleImagePath: params.backVehicleImagePath,
        portraitImagePath: params.portraitImagePath,
      );
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, code: '409'));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on AuthorizationException catch (e) {
      return Left(AuthorizationFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, StaffApplication?>> getStatus(String userId) async {
    try {
      final model = await _remote.getByUserId(userId);
      return Right(model?.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on AuthorizationException catch (e) {
      return Left(AuthorizationFailure(e.message));
    } on NotFoundException {
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<VehicleType>>> getVehicleTypes() async {
    try {
      final models = await _remote.getVehicleTypes();
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on AuthorizationException catch (e) {
      return Left(AuthorizationFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}

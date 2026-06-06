import 'package:dartz/dartz.dart';
import 'package:smart_laundry_locker/core/errors/failures.dart';
import 'package:smart_laundry_locker/core/network/api_client.dart';
import 'package:smart_laundry_locker/features/courier_registration/domain/entities/courier_application_entity.dart';
import 'package:smart_laundry_locker/features/courier_registration/domain/repositories/courier_registration_repository.dart';
import 'package:smart_laundry_locker/features/courier_registration/infrastructure/data_sources/courier_registration_remote_data_source.dart';
import 'package:smart_laundry_locker/features/courier_registration/infrastructure/data_sources/courier_registration_remote_data_source_impl.dart';

class CourierRegistrationRepositoryImpl
    implements CourierRegistrationRepository {
  final CourierRegistrationRemoteDataSource _remoteDataSource;

  CourierRegistrationRepositoryImpl({
    CourierRegistrationRemoteDataSource? remoteDataSource,
    ApiClient? apiClient,
  }) : _remoteDataSource =
           remoteDataSource ??
           CourierRegistrationRemoteDataSourceImpl(apiClient ?? ApiClient());

  @override
  Future<Either<Failure, CourierApplicationEntity>> submitApplication({
    required String legalName,
    required String licensePlate,
    required String vehicleType,
    required String frontVehicleImagePath,
    required String backVehicleImagePath,
    required String portraitImagePath,
  }) async {
    try {
      final model = await _remoteDataSource.submitApplication(
        legalName: legalName,
        licensePlate: licensePlate,
        vehicleType: vehicleType,
        frontVehicleImagePath: frontVehicleImagePath,
        backVehicleImagePath: backVehicleImagePath,
        portraitImagePath: portraitImagePath,
      );

      return Right(model.toEntity());
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

  @override
  Future<Either<Failure, CourierApplicationEntity?>> checkApplicationStatus({
    required String userId,
  }) async {
    try {
      final model = await _remoteDataSource.checkStatus(userId: userId);

      if (model == null) {
        // user chưa đăng ký
        return const Right(null);
      }

      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on NotFoundException {
      // user chưa đăng ký -> trả null
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}

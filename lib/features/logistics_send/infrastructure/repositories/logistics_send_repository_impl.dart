import 'package:smart_laundry_locker/core/errors/failures.dart';
import 'package:smart_laundry_locker/core/network/api_client.dart';
import 'package:smart_laundry_locker/features/logistics_send/domain/entities/dispatch_status_entity.dart';
import 'package:smart_laundry_locker/features/logistics_send/domain/entities/request_send_package_result.dart';
import 'package:smart_laundry_locker/features/logistics_send/domain/entities/send_package_request.dart';
import 'package:smart_laundry_locker/features/logistics_send/domain/repositories/logistics_send_repository.dart';
import 'package:smart_laundry_locker/features/logistics_send/infrastructure/data_sources/logistics_send_remote_datasource.dart';
import 'package:smart_laundry_locker/features/logistics_send/infrastructure/models/send_package_dto.dart';
import 'package:dartz/dartz.dart';

class LogisticsSendRepositoryImpl implements LogisticsSendRepository {
  final LogisticsSendRemoteDataSource _remoteDataSource;

  LogisticsSendRepositoryImpl({LogisticsSendRemoteDataSource? remoteDataSource})
    : _remoteDataSource =
          remoteDataSource ?? LogisticsSendRemoteDataSourceImpl();

  @override
  Future<Either<Failure, RequestSendPackageResult>> sendPackage(
    SendPackageRequest request,
  ) async {
    try {
      final dto = SendPackageDto(
        recipientPhone: request.recipientPhone,
        recipientName: request.recipientName,
        itemType: request.itemType,
        lockerId: request.lockerId,
        senderAddress: request.senderAddress,
        receiverAddress: request.receiverAddress,
        note: request.note,
        logisticsType: request.logisticsType,
        pickupAddress: request.pickupAddress,
        pickupLatitude: request.pickupLatitude,
        pickupLongitude: request.pickupLongitude,
        receiverLatitude: request.receiverLatitude,
        receiverLongitude: request.receiverLongitude,
        voucherId: request.voucherId,
      );

      final response = await _remoteDataSource.sendPackage(dto);
      return Right(
        RequestSendPackageResult(
          dispatchId: response.dispatchId,
          orderId: response.orderId,
          status: response.status,
          message: response.message,
        ),
      );
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
  Future<Either<Failure, DispatchStatusEntity>> getDispatchStatus(
    String dispatchId,
  ) async {
    try {
      final response = await _remoteDataSource.getDispatchStatus(dispatchId);
      return Right(
        DispatchStatusEntity(
          status: response.status,
          courierId: response.courierId,
          courierName: response.courierName,
          courierPhone: response.courierPhone,
          orderCode: response.orderCode,
          orderId: response.orderId,
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> customerCancelOrder(String orderId) async {
    try {
      final success = await _remoteDataSource.customerCancelOrder(orderId);
      return Right(success);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}

import 'package:smart_laundry_locker/core/errors/failures.dart';
import 'package:smart_laundry_locker/features/logistics_send/domain/entities/dispatch_status_entity.dart';
import 'package:smart_laundry_locker/features/logistics_send/domain/entities/request_send_package_result.dart';
import 'package:smart_laundry_locker/features/logistics_send/domain/entities/send_package_request.dart';
import 'package:dartz/dartz.dart';

abstract class LogisticsSendRepository {
  Future<Either<Failure, RequestSendPackageResult>> sendPackage(
    SendPackageRequest request,
  );

  Future<Either<Failure, DispatchStatusEntity>> getDispatchStatus(
    String dispatchId,
  );

  Future<Either<Failure, bool>> customerCancelOrder(String orderId);
}

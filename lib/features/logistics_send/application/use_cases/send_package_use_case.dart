import 'package:smart_laundry_locker/core/errors/failures.dart';
import 'package:smart_laundry_locker/features/logistics_send/domain/entities/request_send_package_result.dart';
import 'package:smart_laundry_locker/features/logistics_send/domain/entities/send_package_request.dart';
import 'package:smart_laundry_locker/features/logistics_send/domain/repositories/logistics_send_repository.dart';
import 'package:dartz/dartz.dart';

class SendPackageUseCase {
  final LogisticsSendRepository _repository;

  SendPackageUseCase(this._repository);

  Future<Either<Failure, RequestSendPackageResult>> call(
    SendPackageRequest request,
  ) async {
    return _repository.sendPackage(request);
  }
}

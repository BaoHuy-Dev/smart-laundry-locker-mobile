import 'package:smart_laundry_locker/core/errors/failures.dart';
import 'package:smart_laundry_locker/features/courier_delivery/domain/repositories/courier_delivery_repository.dart';
import 'package:smart_laundry_locker/features/courier_delivery/infrastructure/models/responses.dart';
import 'package:dartz/dartz.dart';

class VerifyCourierCodeUseCase {
  final CourierDeliveryRepository _repository;

  VerifyCourierCodeUseCase(this._repository);

  Future<Either<Failure, CourierVerifyCodeResponse>> call(String code) async {
    try {
      final response = await _repository.verifyCourierCode(code);
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

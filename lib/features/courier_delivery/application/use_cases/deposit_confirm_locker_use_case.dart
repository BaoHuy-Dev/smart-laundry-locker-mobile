import 'package:smart_laundry_locker/core/errors/failures.dart';
import 'package:smart_laundry_locker/features/courier_delivery/domain/repositories/courier_delivery_repository.dart';
import 'package:dartz/dartz.dart';
import 'dart:io';

class DepositConfirmLockerUseCase {
  final CourierDeliveryRepository _repository;

  DepositConfirmLockerUseCase(this._repository);

  Future<Either<Failure, bool>> call({
    required String orderCode,
    required String recipientPhone,
    required String recipientName,
    required String lockerId,
    List<String>? imageUrls,
  }) async {
    try {
      final success = await _repository.depositConfirmLocker(
        orderCode: orderCode,
        recipientPhone: recipientPhone,
        recipientName: recipientName,
        lockerId: lockerId,
        imageUrls: imageUrls,
      );
      return Right(success);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, String>> uploadEvidence(File imageFile) async {
    try {
      final url = await _repository.uploadDeliveryEvidence(imageFile);
      return Right(url);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

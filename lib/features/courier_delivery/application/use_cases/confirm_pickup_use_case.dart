import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/courier_delivery_repository.dart';

class ConfirmPickupUseCase {
  final CourierDeliveryRepository repository;

  ConfirmPickupUseCase(this.repository);

  Future<Either<Failure, bool>> call(
    String orderCode, {
    List<String>? imageUrls,
  }) async {
    try {
      final success = await repository.confirmPickup(
        orderCode,
        imageUrls: imageUrls,
      );
      return Right(success);
    } catch (e) {
      return Left(ServerFailure('Lỗi khi xác nhận lấy hàng: ${e.toString()}'));
    }
  }
}

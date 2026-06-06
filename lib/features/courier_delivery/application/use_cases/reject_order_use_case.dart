import 'package:smart_laundry_locker/features/courier_delivery/domain/repositories/courier_delivery_repository.dart';

class RejectOrderUseCase {
  final CourierDeliveryRepository repository;

  RejectOrderUseCase(this.repository);

  Future<bool> call(String dispatchId, {String? reason}) {
    return repository.rejectOrder(dispatchId, reason: reason);
  }
}

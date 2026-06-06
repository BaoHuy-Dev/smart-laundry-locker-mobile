import 'package:smart_laundry_locker/features/courier_delivery/infrastructure/models/responses.dart';
import 'dart:io';

abstract class CourierDeliveryRepository {
  Future<CourierAcceptResponse> acceptOrder(String dispatchId);
  Future<CourierVerifyCodeResponse> verifyCourierCode(String code);

  Future<bool> depositOpenLocker(String orderCode, String lockerId);

  Future<bool> depositConfirmLocker({
    required String orderCode,
    required String recipientPhone,
    required String recipientName,
    required String lockerId,
    List<String>? imageUrls,
  });

  Future<bool> confirmPickup(String orderCode, {List<String>? imageUrls});

  Future<String> uploadDeliveryEvidence(File imageFile);

  Future<PickupPackageResponse> pickupPackage(String accessCode);

  Future<bool> cancelDispatch(String dispatchId);
  Future<bool> rejectOrder(String dispatchId, {String? reason});
  Future<Map<String, dynamic>> getCourierActiveDelivery();
}

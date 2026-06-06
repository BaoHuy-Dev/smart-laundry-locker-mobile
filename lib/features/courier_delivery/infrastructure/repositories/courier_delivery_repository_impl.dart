import 'package:smart_laundry_locker/features/courier_delivery/domain/repositories/courier_delivery_repository.dart';
import 'package:smart_laundry_locker/features/courier_delivery/infrastructure/data_sources/courier_delivery_remote_datasource.dart';
import 'package:smart_laundry_locker/features/courier_delivery/infrastructure/models/courier_accept_dto.dart';
import 'package:smart_laundry_locker/features/courier_delivery/infrastructure/models/courier_deposit_dtos.dart';
import 'package:smart_laundry_locker/features/courier_delivery/infrastructure/models/courier_pickup_confirm_dto.dart';
import 'package:smart_laundry_locker/features/courier_delivery/infrastructure/models/courier_reject_dto.dart';
import 'package:smart_laundry_locker/features/courier_delivery/infrastructure/models/pickup_package_dto.dart';
import 'package:smart_laundry_locker/features/courier_delivery/infrastructure/models/responses.dart';
import 'dart:io';

class CourierDeliveryRepositoryImpl implements CourierDeliveryRepository {
  final CourierDeliveryRemoteDataSource _remoteDataSource;

  CourierDeliveryRepositoryImpl({
    CourierDeliveryRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource =
           remoteDataSource ?? CourierDeliveryRemoteDataSourceImpl();

  @override
  Future<CourierAcceptResponse> acceptOrder(String dispatchId) async {
    final dto = CourierAcceptDto(dispatchId: dispatchId);
    return await _remoteDataSource.acceptOrder(dto);
  }

  @override
  Future<CourierVerifyCodeResponse> verifyCourierCode(String code) async {
    return await _remoteDataSource.verifyCourierCode(code);
  }

  @override
  Future<bool> depositOpenLocker(String orderCode, String lockerId) async {
    final dto = CourierDepositOpenDto(orderCode: orderCode, lockerId: lockerId);
    final response = await _remoteDataSource.depositOpenLocker(dto);
    return response.success;
  }

  @override
  Future<bool> depositConfirmLocker({
    required String orderCode,
    required String recipientPhone,
    required String recipientName,
    required String lockerId,
    List<String>? imageUrls,
  }) async {
    final dto = CourierDepositConfirmDto(
      orderCode: orderCode,
      recipientPhone: recipientPhone,
      recipientName: recipientName,
      lockerId: lockerId,
      imageUrls: imageUrls,
    );
    final response = await _remoteDataSource.confirmDeposit(dto);
    return response.success;
  }

  @override
  Future<bool> confirmPickup(
    String orderCode, {
    List<String>? imageUrls,
  }) async {
    final dto = CourierPickupConfirmDto(
      orderCode: orderCode,
      imageUrls: imageUrls,
    );
    final response = await _remoteDataSource.confirmPickup(dto);
    return response.success;
  }

  @override
  Future<PickupPackageResponse> pickupPackage(String accessCode) async {
    final dto = PickupPackageDto(accessCode: accessCode);
    return await _remoteDataSource.pickupPackage(dto);
  }

  @override
  Future<String> uploadDeliveryEvidence(File imageFile) async {
    return _remoteDataSource.uploadDeliveryEvidence(imageFile);
  }

  @override
  Future<bool> cancelDispatch(String dispatchId) async {
    return _remoteDataSource.cancelDispatch(dispatchId);
  }

  @override
  Future<bool> rejectOrder(String dispatchId, {String? reason}) async {
    final dto = CourierRejectDto(dispatchId: dispatchId, reason: reason);
    final response = await _remoteDataSource.rejectOrder(dto);
    return response.success;
  }

  @override
  Future<Map<String, dynamic>> getCourierActiveDelivery() async {
    return await _remoteDataSource.getCourierActiveDelivery();
  }
}

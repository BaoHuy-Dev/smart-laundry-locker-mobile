import 'package:smart_laundry_locker/features/courier_delivery/infrastructure/models/courier_accept_dto.dart';
import 'package:smart_laundry_locker/features/courier_delivery/infrastructure/models/courier_deposit_dtos.dart';
import 'package:smart_laundry_locker/features/courier_delivery/infrastructure/models/courier_pickup_confirm_dto.dart';
import 'package:smart_laundry_locker/features/courier_delivery/infrastructure/models/courier_reject_dto.dart';
import 'package:smart_laundry_locker/features/courier_delivery/infrastructure/models/pickup_package_dto.dart';
import 'package:smart_laundry_locker/features/courier_delivery/infrastructure/models/responses.dart';
import 'package:smart_laundry_locker/core/services/token_service.dart';
import 'package:dio/dio.dart';
import 'dart:io';

import '../../../../core/network/dio_client.dart';

abstract class CourierDeliveryRemoteDataSource {
  Future<CourierAcceptResponse> acceptOrder(CourierAcceptDto dto);
  Future<CourierVerifyCodeResponse> verifyCourierCode(String code);
  Future<CourierDepositOpenResponse> depositOpenLocker(
    CourierDepositOpenDto dto,
  );
  Future<CourierDepositConfirmResponse> confirmDeposit(
    CourierDepositConfirmDto dto,
  );
  Future<CourierPickupConfirmResponse> confirmPickup(
    CourierPickupConfirmDto dto,
  );
  Future<PickupPackageResponse> pickupPackage(PickupPackageDto dto);
  Future<String> uploadDeliveryEvidence(File imageFile);
  Future<bool> cancelDispatch(String dispatchId);
  Future<CourierRejectResponse> rejectOrder(CourierRejectDto dto);
  Future<Map<String, dynamic>> getCourierActiveDelivery();
}

class CourierDeliveryRemoteDataSourceImpl
    implements CourierDeliveryRemoteDataSource {
  final Dio _dio;

  CourierDeliveryRemoteDataSourceImpl({Dio? dio})
    : _dio = dio ?? DioClient.instance.dio;

  @override
  Future<CourierAcceptResponse> acceptOrder(CourierAcceptDto dto) async {
    final response = await _dio.post(
      '/logistics/courier/accept',
      data: dto.toJson(),
    );
    return CourierAcceptResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<CourierVerifyCodeResponse> verifyCourierCode(String code) async {
    final response = await _dio.post(
      '/logistics/courier/verify-code',
      data: {'code': code},
    );
    return CourierVerifyCodeResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<CourierDepositOpenResponse> depositOpenLocker(
    CourierDepositOpenDto dto,
  ) async {
    final response = await _dio.post(
      '/logistics/courier/deposit/open',
      data: dto.toJson(),
    );
    return CourierDepositOpenResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<CourierDepositConfirmResponse> confirmDeposit(
    CourierDepositConfirmDto dto,
  ) async {
    final response = await _dio.post(
      '/logistics/courier/deposit/confirm',
      data: dto.toJson(),
    );
    return CourierDepositConfirmResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<PickupPackageResponse> pickupPackage(PickupPackageDto dto) async {
    final response = await _dio.post('/logistics/pickup', data: dto.toJson());
    return PickupPackageResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<CourierPickupConfirmResponse> confirmPickup(
    CourierPickupConfirmDto dto,
  ) async {
    final response = await _dio.post(
      '/logistics/courier/pickup-confirm',
      data: dto.toJson(),
    );

    return CourierPickupConfirmResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<String> uploadDeliveryEvidence(File imageFile) async {
    final fileName = imageFile.path.split('/').last.split('\\').last;

    final token = await TokenService.getAccessToken();
    final options = Options(
      contentType: 'multipart/form-data',
      headers: {
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    for (final endpoint in const ['/storage/upload', '/files/upload']) {
      try {
        final formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(
            imageFile.path,
            filename: fileName,
          ),
        });

        final response = await _dio.post(
          endpoint,
          data: formData,
          options: options,
        );
        final payload = response.data as Map<String, dynamic>? ?? {};
        final data = payload['data'];

        String? readUrl(dynamic raw) {
          if (raw is String && raw.trim().isNotEmpty) return raw.trim();
          if (raw is Map<String, dynamic>) {
            final candidates = [raw['url'], raw['fileUrl'], raw['location']];
            for (final c in candidates) {
              if (c is String && c.trim().isNotEmpty) return c.trim();
            }
          }
          return null;
        }

        final url =
            readUrl(data) ??
            readUrl(payload['result']) ??
            readUrl(payload['file']) ??
            readUrl(payload['url']);

        if (url != null) return url;
      } catch (e) {
        // Try next endpoint.
        print('[Upload] Failed to upload to $endpoint: $e');
      }
    }

    throw Exception('Không thể upload ảnh bằng chứng giao hàng');
  }

  @override
  Future<bool> cancelDispatch(String dispatchId) async {
    final response = await _dio.delete('/orders/dispatch/$dispatchId');
    final data = response.data as Map<String, dynamic>? ?? const {};
    final success = data['success'];
    if (success is bool) return success;
    return response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300;
  }

  @override
  Future<CourierRejectResponse> rejectOrder(CourierRejectDto dto) async {
    final response = await _dio.post(
      '/logistics/courier/reject',
      data: dto.toJson(),
    );
    return CourierRejectResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<Map<String, dynamic>> getCourierActiveDelivery() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/orders/courier/active',
    );
    final responseData = response.data ?? {};
    return responseData['data'] as Map<String, dynamic>? ?? responseData;
  }
}

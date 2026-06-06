import 'package:smart_laundry_locker/features/logistics_send/infrastructure/models/dispatch_status_response.dart';
import 'package:smart_laundry_locker/features/logistics_send/infrastructure/models/request_send_package_response.dart';
import 'package:smart_laundry_locker/features/logistics_send/infrastructure/models/send_package_dto.dart';

import '../../../../core/network/api_client.dart';

abstract class LogisticsSendRemoteDataSource {
  Future<RequestSendPackageResponse> sendPackage(SendPackageDto dto);
  Future<DispatchStatusResponse> getDispatchStatus(String dispatchId);
  Future<bool> customerCancelOrder(String orderId);
}

class LogisticsSendRemoteDataSourceImpl
    implements LogisticsSendRemoteDataSource {
  final ApiClient _apiClient;

  LogisticsSendRemoteDataSourceImpl({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  @override
  Future<RequestSendPackageResponse> sendPackage(SendPackageDto dto) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/logistics/send',
      data: dto.toJson(),
    );

    final rawData = response.data as Map<String, dynamic>;
    final innerData = rawData['data'] as Map<String, dynamic>? ?? rawData;

    return RequestSendPackageResponse.fromJson(innerData);
  }

  @override
  Future<DispatchStatusResponse> getDispatchStatus(String dispatchId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/logistics/dispatch/$dispatchId',
    );

    final rawData = response.data as Map<String, dynamic>;
    final innerData = rawData['data'] as Map<String, dynamic>? ?? rawData;

    return DispatchStatusResponse.fromJson(innerData);
  }

  @override
  Future<bool> customerCancelOrder(String orderId) async {
    final response = await _apiClient.post(
      '/logistics/customer/cancel',
      data: {'orderId': orderId},
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }
}

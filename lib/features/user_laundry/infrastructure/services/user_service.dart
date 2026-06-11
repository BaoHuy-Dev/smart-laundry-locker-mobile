import 'package:smart_laundry_locker/features/user_laundry/infrastructure/services/user_gateway_client.dart';

class UserService extends UserGatewayClient {
  UserService(super.apiClient);

  Future<Map<String, dynamic>> getProfile() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/api/user/profile',
    );
    return unwrapMap(response);
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await apiClient.put<Map<String, dynamic>>(
      '/api/user/profile',
      data: data,
    );
    return unwrapMap(response);
  }

  Future<Map<String, dynamic>> getStatistics() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/api/user/me/statistics',
    );
    return unwrapMap(response);
  }

  Future<void> updateFcmToken(String token) async {
    await apiClient.post<Map<String, dynamic>>(
      '/api/user/fcm-token',
      data: {'token': token},
    );
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await apiClient.put<Map<String, dynamic>>(
      '/api/user/password',
      data: {'oldPassword': oldPassword, 'newPassword': newPassword},
    );
  }
}

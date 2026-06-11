import 'package:smart_laundry_locker/core/services/token_service.dart';
import 'package:smart_laundry_locker/features/user_laundry/infrastructure/services/user_gateway_client.dart';

class UserAuthService extends UserGatewayClient {
  UserAuthService(super.apiClient);

  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/api/auth/login',
      data: {'identifier': identifier, 'password': password},
    );
    final data = unwrapMap(response);
    final accessToken = data['accessToken']?.toString();
    final refreshToken = data['refreshToken']?.toString();
    if (accessToken != null && refreshToken != null) {
      await TokenService.saveTokens(accessToken, refreshToken);
      apiClient.setAuthToken(accessToken);
    }
    return data;
  }

  Future<Map<String, dynamic>> register({
    required int userId,
    required String password,
    String? email,
    String? phoneNumber,
    String? firstName,
    String? lastName,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/api/auth/register',
      data: {
        'userId': userId,
        'email': email,
        'phoneNumber': phoneNumber,
        'firstName': firstName,
        'lastName': lastName,
        'roles': ['CUSTOMER'],
        'password': password,
      },
    );
    return unwrapMap(response);
  }

  Future<void> sendEmailOtp(String email) async {
    await apiClient.post<Map<String, dynamic>>(
      '/api/auth/email/send-otp',
      data: {'email': email},
    );
  }

  Future<Map<String, dynamic>> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/api/auth/email/verify-otp',
      data: {'email': email, 'otp': otp},
    );
    return unwrapMap(response);
  }

  Future<Map<String, dynamic>> completeEmailRegistration({
    required String tempToken,
    required String password,
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/api/auth/email/complete-registration',
      data: {
        'tempToken': tempToken,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
      },
    );
    final data = unwrapMap(response);
    final accessToken = data['accessToken']?.toString();
    final refreshToken = data['refreshToken']?.toString();
    if (accessToken != null && refreshToken != null) {
      await TokenService.saveTokens(accessToken, refreshToken);
      apiClient.setAuthToken(accessToken);
    }
    return data;
  }

  Future<void> logout() async {
    final refreshToken = await TokenService.getRefreshToken();
    try {
      await apiClient.post<Map<String, dynamic>>(
        '/api/auth/logout',
        data: {'refreshToken': refreshToken},
      );
    } finally {
      await TokenService.clearTokens();
      apiClient.clearAuthToken();
    }
  }
}

import '../config/api_endpoints.dart';
import '../models/api_response.dart';
import '../models/user.dart';
import '../network/api_client.dart';

/// Authentication Service — replaces authService.ts
class AuthService {
  AuthService._();

  static final _dio = ApiClient.instance;

  /// Phone Login - Firebase phone authentication
  static Future<ApiResponse<Map<String, dynamic>>> phoneLogin(
    String idToken,
  ) async {
    final response = await _dio.post(
      ApiEndpoints.phoneLogin,
      data: {'idToken': idToken},
    );
    // Since PhoneLoginResponse isn't fully typed in Dart yet, returning Map
    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );
  }

  /// Complete Registration after phone login
  static Future<ApiResponse<Map<String, dynamic>>> completeRegistration(
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.post(
      ApiEndpoints.completeRegistration,
      data: data,
    );
    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );
  }

  /// Send Email OTP
  static Future<ApiResponse<Map<String, dynamic>>> sendEmailOtp(
    String email,
  ) async {
    final response = await _dio.post(
      ApiEndpoints.emailSendOtp,
      data: {'email': email},
    );
    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );
  }

  /// Verify Email OTP
  static Future<ApiResponse<Map<String, dynamic>>> verifyEmailOtp(
    String email,
    String otp,
  ) async {
    final response = await _dio.post(
      ApiEndpoints.emailVerifyOtp,
      data: {'email': email, 'otp': otp},
    );
    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );
  }

  /// Complete Registration after email OTP verification
  static Future<ApiResponse<Map<String, dynamic>>> emailCompleteRegistration(
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.post(
      ApiEndpoints.emailCompleteRegistration,
      data: data,
    );
    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );
  }

  /// Refresh Token
  static Future<ApiResponse<AuthTokens>> refreshToken(String token) async {
    final response = await _dio.post(
      ApiEndpoints.refreshToken,
      data: {'refreshToken': token},
    );
    return ApiResponse<AuthTokens>.fromJson(
      response.data,
      (json) => AuthTokens.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Logout
  static Future<ApiResponse<Map<String, dynamic>>> logout(String token) async {
    final response = await _dio.post(
      ApiEndpoints.logout,
      data: {'refreshToken': token},
    );
    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );
  }

  /// Forgot password - send OTP to email
  static Future<ApiResponse<Map<String, dynamic>>> forgotPassword(
    String email,
  ) async {
    final response = await _dio.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );
    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );
  }

  /// Reset password with email OTP
  static Future<ApiResponse<Map<String, dynamic>>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.resetPassword,
      data: {'email': email, 'otp': otp, 'newPassword': newPassword},
    );
    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );
  }

  /// Get User Profile
  static Future<ApiResponse<User>> getProfile() async {
    final response = await _dio.get(ApiEndpoints.userProfile);
    return ApiResponse<User>.fromJson(
      response.data,
      (json) => User.fromJson(json as Map<String, dynamic>),
    );
  }
}

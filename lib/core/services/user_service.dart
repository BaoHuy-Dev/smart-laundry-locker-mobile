import '../config/api_endpoints.dart';
import '../models/api_response.dart';
import '../models/user.dart';
import '../network/api_client.dart';

/// User Service — replaces userService.ts
class UserService {
  UserService._();

  static final _dio = ApiClient.instance;

  static Future<ApiResponse<User>> getProfile() async {
    final response = await _dio.get(ApiEndpoints.userProfile);
    return ApiResponse<User>.fromJson(
      response.data,
      (json) => User.fromJson(json as Map<String, dynamic>),
    );
  }

  static Future<ApiResponse<User>> updateProfile(
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.put(ApiEndpoints.userProfile, data: data);
    return ApiResponse<User>.fromJson(
      response.data,
      (json) => User.fromJson(json as Map<String, dynamic>),
    );
  }

  static Future<ApiResponse<User>> updateAvatar(String imageUrl) async {
    final response = await _dio.put(
      ApiEndpoints.userAvatar,
      data: {'imageUrl': imageUrl},
    );
    return ApiResponse<User>.fromJson(
      response.data,
      (json) => User.fromJson(json as Map<String, dynamic>),
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> changePassword(
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.put(ApiEndpoints.userPassword, data: data);
    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> registerFcmToken(
    String fcmToken,
  ) async {
    final response = await _dio.post(
      ApiEndpoints.userFcmToken,
      data: {'fcmToken': fcmToken},
    );
    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> removeFcmToken(
    String fcmToken,
  ) async {
    final response = await _dio.delete(
      ApiEndpoints.userFcmToken,
      queryParameters: {'fcmToken': fcmToken},
    );
    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> getUserStatistics() async {
    final response = await _dio.get(ApiEndpoints.userStatistics);
    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );
  }
}

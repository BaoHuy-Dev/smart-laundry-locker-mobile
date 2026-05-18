import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/env_config.dart';
import '../config/api_endpoints.dart';
import 'token_storage.dart';

/// Interceptor to handle Bearer tokens and 401 Unauthorized token refresh.
/// Mapped from RN's api.ts interceptor logic.
class AuthInterceptor extends QueuedInterceptor {
  final Dio dio;

  /// Optional callback to force logout if refresh token is invalid
  /// Set this from the AuthProvider (similar to RN's _logoutCallback)
  static Future<void> Function()? onForceLogout;

  AuthInterceptor(this.dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await TokenStorage.getAccessToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    if (kDebugMode) {
      print('API Request: [${options.method}] ${options.uri}');
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;

    // Check for "E_LOYALTY001" (usually indicates JWT userId no longer exists)
    final responseData = response?.data;
    if (response?.statusCode == 400 &&
        responseData is Map &&
        responseData['code'] == 'E_LOYALTY001') {
      await _handleForceLogout();
      return handler.next(err);
    }

    // Handle 401 Unauthorized token refresh
    if (response?.statusCode == 401) {
      // Create a new separate Dio instance for refreshing to avoid interceptor loop
      final refreshDio = Dio(BaseOptions(baseUrl: EnvConfig.apiUrl));
      final refreshToken = await TokenStorage.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        await _handleForceLogout();
        return handler.next(err);
      }

      try {
        final refreshResponse = await refreshDio.post(
          ApiEndpoints.refreshToken,
          data: {'refreshToken': refreshToken},
        );

        if (refreshResponse.statusCode == 200) {
          final data = refreshResponse.data['data'];
          final newAccessToken = data['accessToken'];
          final newRefreshToken = data['refreshToken'] ?? refreshToken;

          await TokenStorage.setTokens(newAccessToken, newRefreshToken);

          // Retry the original request with the new token
          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer $newAccessToken';

          final retryResponse = await dio.fetch(options);
          return handler.resolve(retryResponse);
        } else {
          await _handleForceLogout();
          return handler.next(err);
        }
      } catch (e) {
        await _handleForceLogout();
        return handler.next(err);
      }
    }

    return handler.next(err);
  }

  Future<void> _handleForceLogout() async {
    await TokenStorage.clearTokens();
    if (onForceLogout != null) {
      try {
        await onForceLogout!();
      } catch (_) {}
    }
  }
}

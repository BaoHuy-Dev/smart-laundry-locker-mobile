import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/env_config.dart';
import '../constants/app_constants.dart';
import 'auth_interceptor.dart';

/// Centralized Dio client instance — replaces Axios instance from RN.
class ApiClient {
  ApiClient._();

  static Dio? _dio;

  static Dio get instance {
    if (_dio != null) return _dio!;

    _dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.apiUrl,
        connectTimeout: AppConstants.apiTimeout,
        receiveTimeout: AppConstants.apiTimeout,
        sendTimeout: AppConstants.apiTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Add interceptors
    _dio!.interceptors.add(AuthInterceptor(_dio!));

    // Logging interceptor for debugging
    if (kDebugMode) {
      _dio!.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
        ),
      );
    }

    return _dio!;
  }
}

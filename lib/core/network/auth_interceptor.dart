import 'package:smart_laundry_locker/core/network/dio_client.dart';
import 'package:smart_laundry_locker/core/routing/app_router.dart';
import 'package:smart_laundry_locker/core/services/token_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

/// Interceptor to handle authentication errors (401 Unauthorized)
class AuthInterceptor extends Interceptor {
  static bool _isHandling401 = false;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      if (_isHandling401) {
        return handler.next(err);
      }
      _isHandling401 = true;

      debugPrint(
        'AuthInterceptor: 401 Unauthorized detected. Triggering logout.',
      );

      // 1. Clear local tokens
      await TokenService.clearTokens();

      // 2. Clear Dio authorization header
      DioClient.instance.clearAuthToken();

      // 3. Show notification
      SmartDialog.showToast('Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.');

      // 4. Redirect to onboarding
      AppRouter.router.go(AppRouter.onboarding);

      // Reset flag after a delay to allow navigation to complete
      Future.delayed(const Duration(seconds: 2), () {
        _isHandling401 = false;
      });
    }

    return handler.next(err);
  }
}

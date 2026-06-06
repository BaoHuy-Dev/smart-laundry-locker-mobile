import 'dart:typed_data';

import 'package:smart_laundry_locker/core/network/api_client.dart';
import 'package:smart_laundry_locker/core/services/token_service.dart';
import 'package:smart_laundry_locker/core/errors/failures.dart';
import 'package:smart_laundry_locker/features/auth/domain/entities/face_verify_result_entity.dart';
import 'package:smart_laundry_locker/features/auth/application/use_cases/confirm_qr_login_use_case.dart';
import 'package:smart_laundry_locker/features/auth/application/use_cases/login_use_case.dart';
import 'package:smart_laundry_locker/features/auth/application/use_cases/login_with_face_use_case.dart';
import 'package:smart_laundry_locker/features/auth/domain/entities/auth_token_entity.dart';
import 'package:smart_laundry_locker/features/auth/infrastructure/utils/qr_session_id_parser.dart';
import 'package:flutter/foundation.dart';

class LoginProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final LoginWithFaceUseCase _loginWithFaceUseCase;
  final ConfirmQrLoginUseCase _confirmQrLoginUseCase;
  final ApiClient _apiClient;

  LoginProvider({
    required LoginUseCase loginUseCase,
    required LoginWithFaceUseCase loginWithFaceUseCase,
    required ConfirmQrLoginUseCase confirmQrLoginUseCase,
    required ApiClient apiClient,
  }) : _loginUseCase = loginUseCase,
       _loginWithFaceUseCase = loginWithFaceUseCase,
       _confirmQrLoginUseCase = confirmQrLoginUseCase,
       _apiClient = apiClient;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  bool _isSuccess = false;
  bool get isSuccess => _isSuccess;

  AuthTokenEntity? _authToken;
  AuthTokenEntity? get authToken => _authToken;

  String? _matchedUserId;
  String? get matchedUserId => _matchedUserId;

  bool _isFaceMatched = false;
  bool get isFaceMatched => _isFaceMatched;

  bool _isQrConfirmLoading = false;
  bool get isQrConfirmLoading => _isQrConfirmLoading;

  bool? _qrConfirmSuccess;
  bool? get qrConfirmSuccess => _qrConfirmSuccess;

  String? _qrError;
  String? get qrError => _qrError;

  Future<void> onQrScanned(String qrRawContent) async {
    _isQrConfirmLoading = true;
    _qrError = null;
    _qrConfirmSuccess = null;
    notifyListeners();

    final sessionId = parseQrSessionId(qrRawContent);
    if (sessionId == null || sessionId.isEmpty) {
      _isQrConfirmLoading = false;
      _qrError = 'Không đọc được mã phiên từ QR. Vui lòng thử mã khác.';
      notifyListeners();
      return;
    }

    final result = await _confirmQrLoginUseCase(
      ConfirmQrLoginParams(sessionId: sessionId),
    );

    result.fold(_handleQrFailure, (ok) {
      _isQrConfirmLoading = false;
      _qrConfirmSuccess = ok;
      _qrError = ok ? null : 'Xác nhận thất bại.';
      notifyListeners();
    });
  }

  void _handleQrFailure(Failure failure) {
    _isQrConfirmLoading = false;
    _qrConfirmSuccess = false;
    if (failure is QrExpiredFailure) {
      _qrError = failure.message;
    } else if (failure is QrAlreadyUsedFailure) {
      _qrError = failure.message;
    } else if (failure is AuthenticationFailure) {
      _qrError = failure.message;
    } else {
      _qrError = failure.message;
    }
    notifyListeners();
  }

  void clearQrLoginState() {
    _isQrConfirmLoading = false;
    _qrConfirmSuccess = null;
    _qrError = null;
    notifyListeners();
  }

  Future<void> login({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    _isSuccess = false;
    notifyListeners();

    final params = LoginParams.fromForm(email: email, password: password);

    final result = await _loginUseCase(params);

    result.fold(_handleFailure, _handleLoginSuccess);
  }

  Future<void> loginWithFace({required Uint8List imageBytes}) async {
    _isLoading = true;
    _error = null;
    _isSuccess = false;
    _isFaceMatched = false;
    _matchedUserId = null;
    notifyListeners();

    final params = LoginWithFaceParams(imageBytes: imageBytes);
    final result = await _loginWithFaceUseCase(params);
    result.fold(_handleFailure, _handleFaceVerifySuccess);
  }

  void _handleFailure(Failure failure) {
    _isLoading = false;
    _error = failure.message;
    _isSuccess = false;
    _isFaceMatched = false;
    _matchedUserId = null;
    notifyListeners();
  }

  Future<void> _handleFaceVerifySuccess(FaceVerifyResultEntity result) async {
    _isLoading = false;
    _error = null;
    _isSuccess = false;
    _isFaceMatched = false;
    _matchedUserId = null;

    if (result.token != null) {
      _isSuccess = true;
      _authToken = result.token;

      await TokenService.saveTokens(
        result.token!.accessToken,
        result.token!.refreshToken,
      );
      _apiClient.setAuthToken(result.token!.accessToken);
    } else if (result.matchedUserId != null) {
      _isFaceMatched = true;
      _matchedUserId = result.matchedUserId;
    }

    notifyListeners();
  }

  Future<void> _handleLoginSuccess(AuthTokenEntity tokenEntity) async {
    _isLoading = false;
    _error = null;
    _isSuccess = true;
    _isFaceMatched = false;
    _matchedUserId = null;
    _authToken = tokenEntity;

    await TokenService.saveTokens(
      tokenEntity.accessToken,
      tokenEntity.refreshToken,
    );

    _apiClient.setAuthToken(tokenEntity.accessToken);
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _isLoading = false;
    _error = null;
    _isSuccess = false;
    _isFaceMatched = false;
    _matchedUserId = null;
    _authToken = null;
    _isQrConfirmLoading = false;
    _qrConfirmSuccess = null;
    _qrError = null;
    notifyListeners();
  }
}

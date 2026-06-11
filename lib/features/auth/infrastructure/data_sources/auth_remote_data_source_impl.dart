import 'package:smart_laundry_locker/core/network/api_client.dart';
import 'package:smart_laundry_locker/features/auth/infrastructure/data_sources/auth_remote_data_source.dart';
import 'package:smart_laundry_locker/features/auth/infrastructure/models/login_request_model.dart';
import 'package:smart_laundry_locker/features/auth/infrastructure/models/qr_confirm_request_model.dart';
import 'package:smart_laundry_locker/features/auth/infrastructure/models/register_request_model.dart';
import 'package:smart_laundry_locker/features/auth/infrastructure/models/verify_otp_request_model.dart';
import 'package:dio/dio.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  static const String _basePath = '/auth';

  AuthRemoteDataSourceImpl(this._apiClient);

  Map<String, dynamic> _extractData(Response<dynamic> response) {
    final responseData = response.data as Map<String, dynamic>;
    return responseData['data'] as Map<String, dynamic>? ?? responseData;
  }

  @override
  Future<Map<String, dynamic>> register(RegisterRequestModel request) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '$_basePath/register',
      data: request.toJson(),
    );

    return _extractData(response);
  }

  @override
  Future<Map<String, dynamic>> login(LoginRequestModel request) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/api/auth/login',
      data: {'identifier': request.email, 'password': request.password},
    );

    return _extractData(response);
  }

  @override
  Future<Map<String, dynamic>> faceVerify({
    required String imageBase64,
    required double threshold,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '$_basePath/ai/verify',
      data: {'image_base64': imageBase64, 'threshold': threshold},
    );
    return _extractData(response);
  }

  @override
  Future<Map<String, dynamic>> verifyOtp(VerifyOtpRequestModel request) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '$_basePath/verify-otp',
      data: request.toJson(),
    );

    return _extractData(response);
  }

  @override
  Future<Map<String, dynamic>> confirmQrLogin(
    QrConfirmRequestModel request,
  ) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '$_basePath/qr/confirm',
      data: request.toJson(),
    );
    return _extractData(response);
  }

  @override
  Future<Map<String, dynamic>> faceRegister({
    required String userId,
    required List<String> imagesBase64,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '$_basePath/ai/register',
      data: {'userId': userId, 'images_base64': imagesBase64},
    );
    return _extractData(response);
  }
}

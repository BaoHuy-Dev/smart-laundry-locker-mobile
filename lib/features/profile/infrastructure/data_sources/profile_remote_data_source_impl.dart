import 'package:smart_laundry_locker/core/network/api_client.dart';
import 'package:smart_laundry_locker/features/profile/infrastructure/data_sources/profile_remote_data_source.dart';
import 'package:dio/dio.dart';

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient _apiClient;

  static const String _basePath = '/users';
  static const String _courierBasePath = '/staff-applications';

  ProfileRemoteDataSourceImpl(this._apiClient);

  Map<String, dynamic> _extractData(Response<dynamic> response) {
    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>? ?? responseData;

    final nestedUser = data['user'];
    if (nestedUser is Map<String, dynamic>) {
      return nestedUser;
    }

    return data;
  }

  @override
  Future<Map<String, dynamic>> getProfile() async {
    final response = await _apiClient.get('$_basePath/me');
    final profile = _extractData(response);
    final phone = profile['phoneNumber']?.toString();
    final userId = profile['id']?.toString();
    final needEnrichPhone = phone == null || phone.trim().isEmpty;
    if (needEnrichPhone && userId != null && userId.isNotEmpty) {
      try {
        final detailResponse = await _apiClient.get('$_basePath/$userId');
        final detail = _extractData(detailResponse);
        return <String, dynamic>{
          ...detail,
          ...profile,
          'phoneNumber': detail['phoneNumber'] ?? profile['phoneNumber'],
        };
      } catch (_) {}
    }

    return profile;
  }

  @override
  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    final response = await _apiClient.put('$_basePath/$userId', data: data);
    return _extractData(response);
  }

  @override
  Future<Map<String, dynamic>> getCourierProfile(String userId) async {
    final response = await _apiClient.get('$_courierBasePath/user/$userId');
    return _extractData(response);
  }

  @override
  Future<Map<String, dynamic>> uploadAvatar({
    required String userId,
    required String filePath,
  }) async {
    final fileName = filePath.split('/').last.split('\\').last;
    final formData = FormData.fromMap({
      'files': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    final response = await _apiClient.put('$_basePath/$userId', data: formData);

    return _extractData(response);
  }

  @override
  Future<bool> verifyCurrentPassword({
    required String email,
    required String currentPassword,
  }) async {
    final response = await _apiClient.post(
      '/auth/login',
      data: {'email': email, 'password': currentPassword},
    );

    final data = _extractData(response);
    final accessToken = data['accessToken'] ?? data['access_token'];
    return accessToken != null && accessToken.toString().isNotEmpty;
  }

  @override
  Future<bool> changePassword({
    required String email,
    required String newPassword,
  }) async {
    final response = await _apiClient.post(
      '/auth/change-password',
      data: {'email': email, 'newPassword': newPassword},
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final success = data['success'];
      if (success is bool) return success;
    }
    return true;
  }

  @override
  Future<bool> getFaceRegistrationStatus(String userId) async {
    final response = await _apiClient.get<dynamic>(
      '/auth/ai/registered/$userId',
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final isRegistered = data['isRegistered'];
      if (isRegistered is bool) return isRegistered;

      // Handle nested data if necessary
      final innerData = data['data'];
      if (innerData is Map<String, dynamic>) {
        final innerRegistered = innerData['isRegistered'];
        if (innerRegistered is bool) return innerRegistered;
      }
    }
    return false;
  }
}

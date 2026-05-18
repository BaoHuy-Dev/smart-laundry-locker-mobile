import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

/// Handles secure storage of authentication tokens.
/// Replaces `expo-secure-store` implementation from RN's api.ts.
class TokenStorage {
  TokenStorage._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// Get the Access Token
  static Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: AppConstants.accessTokenKey);
    } catch (e) {
      return null;
    }
  }

  /// Get the Refresh Token
  static Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: AppConstants.refreshTokenKey);
    } catch (e) {
      return null;
    }
  }

  /// Save both tokens
  static Future<void> setTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: AppConstants.accessTokenKey, value: accessToken);
    await _storage.write(
      key: AppConstants.refreshTokenKey,
      value: refreshToken,
    );
  }

  /// Delete both tokens (e.g., on logout)
  static Future<void> clearTokens() async {
    await _storage.delete(key: AppConstants.accessTokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
  }
}

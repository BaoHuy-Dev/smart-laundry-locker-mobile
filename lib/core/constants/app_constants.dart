/// App-wide constants — replaces constants/ READMEs placeholder values.
class AppConstants {
  AppConstants._();

  static const String appName = 'Lock.R Locker';
  static const String appTagline = 'Locker thông minh, tiện lợi';

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 60);
  static const Duration splashDuration = Duration(milliseconds: 4500);

  // Pagination
  static const int defaultPageSize = 10;

  // Token storage keys (same keys as RN SecureStore)
  static const String accessTokenKey = 'accessToken';
  static const String refreshTokenKey = 'refreshToken';
}

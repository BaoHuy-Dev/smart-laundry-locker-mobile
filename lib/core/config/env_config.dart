import 'package:envied/envied.dart';

part 'env_config.g.dart';

@Envied(path: '.env')
abstract class EnvConfig {
  @EnviedField(
    varName: 'API_BASE_URL',
    defaultValue: 'https://api-dev.aisl.io.vn',
    //'http://10.0.2.2:3000', // 10.0.2.2 is Android emulator's alias for host localhost
  )
  static const String apiBaseUrl = _EnvConfig.apiBaseUrl;

  // Web Client ID (for backend authentication - server-side verification)
  // @EnviedField(varName: 'GOOGLE_WEB_CLIENT_ID', defaultValue: '')
  // static const String googleWebClientId = _EnvConfig.googleWebClientId;

  // @EnviedField(varName: 'GOOGLE_MAPS_API_KEY', defaultValue: '')
  // static const String googleMapsApiKey = _EnvConfig.googleMapsApiKey;

  // iOS Client ID (for iOS native authentication)
  // @EnviedField(varName: 'GOOGLE_IOS_CLIENT_ID', defaultValue: '')
  // static const String googleIosClientId = _EnvConfig.googleIosClientId;

  // @EnviedField(varName: 'GOOGLE_ANDROID_CLIENT_ID', defaultValue: '')
  // static const String googleAndroidClientId = _EnvConfig.googleAndroidClientId;
}

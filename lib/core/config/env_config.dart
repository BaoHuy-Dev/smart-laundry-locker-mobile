import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration — replaces process.env.EXPO_PUBLIC_* from React Native.
///
/// Usage:
///   EnvConfig.apiUrl  // → "http://10.0.2.2:8080/api"
class EnvConfig {
  EnvConfig._();

  static String get apiUrl =>
      dotenv.env['API_URL'] ?? 'http://10.0.2.2:8080/api';

  static String get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';

  static String get firebaseAuthDomain =>
      dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? '';

  static String get firebaseProjectId =>
      dotenv.env['FIREBASE_PROJECT_ID'] ?? '';

  static String get firebaseStorageBucket =>
      dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '';

  static String get firebaseMessagingSenderId =>
      dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';

  static String get firebaseAppId => dotenv.env['FIREBASE_APP_ID'] ?? '';

  static String get firebaseMeasurementId =>
      dotenv.env['FIREBASE_MEASUREMENT_ID'] ?? '';
}

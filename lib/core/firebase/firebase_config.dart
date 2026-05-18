import 'package:firebase_core/firebase_core.dart';
import '../config/env_config.dart';

/// Firebase initialization using credentials from .env.
/// Replaces the manual RN firebase setup.
class FirebaseConfig {
  FirebaseConfig._();

  static Future<void> initialize() async {
    // Note: We use manual configuration here mapped from .env instead of
    // flutterfire generated DefaultFirebaseOptions to match the RN structure exactly.
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: EnvConfig.firebaseApiKey,
        appId: EnvConfig.firebaseAppId,
        messagingSenderId: EnvConfig.firebaseMessagingSenderId,
        projectId: EnvConfig.firebaseProjectId,
        authDomain: EnvConfig.firebaseAuthDomain.isNotEmpty
            ? EnvConfig.firebaseAuthDomain
            : null,
        storageBucket: EnvConfig.firebaseStorageBucket.isNotEmpty
            ? EnvConfig.firebaseStorageBucket
            : null,
        measurementId: EnvConfig.firebaseMeasurementId.isNotEmpty
            ? EnvConfig.firebaseMeasurementId
            : null,
      ),
    );
  }
}

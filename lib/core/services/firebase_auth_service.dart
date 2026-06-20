import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_laundry_locker/core/config/env_config.dart';

/// Wraps Firebase Auth so phone + Google all yield a single Firebase ID token
/// that the backend verifies via `POST /api/auth/firebase`.
class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  bool _googleInitialized = false;

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    // google_sign_in v7 requires an explicit initialize() before authenticate().
    // serverClientId (Web client ID) makes Google return an ID token whose
    // audience the backend / Firebase can verify.
    await GoogleSignIn.instance.initialize(
      serverClientId: EnvConfig.googleWebClientId,
    );
    _googleInitialized = true;
  }

  /// Google sign-in -> Firebase credential -> Firebase ID token.
  /// Returns null when the user cancels the Google chooser.
  Future<String?> signInWithGoogle() async {
    try {
      await _ensureGoogleInitialized();

      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final String? googleIdToken = googleAuth.idToken;
      if (googleIdToken == null) {
        throw Exception('Google ID Token is null');
      }

      final credential = GoogleAuthProvider.credential(idToken: googleIdToken);
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      return await userCredential.user?.getIdToken();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return null; // Cancelled by user
      }
      debugPrint('Google Sign In Error: $e');
      rethrow;
    } catch (e) {
      debugPrint('Google Sign In Error: $e');
      rethrow;
    }
  }

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) codeSent,
    required Function(String error) verificationFailed,
  }) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        verificationFailed(e.message ?? 'Unknown error during phone verification');
      },
      codeSent: (String verificationId, int? resendToken) {
        codeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<String?> confirmOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final idToken = await userCredential.user?.getIdToken();
      return idToken;
    } catch (e) {
      debugPrint('OTP Confirm Error: $e');
      rethrow;
    }
  }
}

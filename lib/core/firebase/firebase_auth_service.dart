import 'package:firebase_auth/firebase_auth.dart';

/// Service to interact with Firebase Authentication.
/// Specifically handles the Phone Authentication flow used in RN's PhoneLogin.
class FirebaseAuthService {
  FirebaseAuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Gets the current Firebase user
  static User? get currentUser => _auth.currentUser;

  /// Gets the current ID token for the backend API
  static Future<String?> getIdToken([bool forceRefresh = false]) async {
    return await _auth.currentUser?.getIdToken(forceRefresh);
  }

  /// Initiates Phone Number verification
  static Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  /// Signs in with SMS code
  static Future<UserCredential> signInWithCredential(
    PhoneAuthCredential credential,
  ) async {
    return await _auth.signInWithCredential(credential);
  }

  /// Creates a PhoneAuthCredential from verification ID and SMS code
  static PhoneAuthCredential getCredential({
    required String verificationId,
    required String smsCode,
  }) {
    return PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
  }

  /// Signs out from Firebase
  static Future<void> signOut() async {
    await _auth.signOut();
  }
}

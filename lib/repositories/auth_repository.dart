// lib/repositories/auth_repository.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:quiz_panel/utils/app_strings.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepository(this._firebaseAuth);

  // --- 1. Get Authentication Status ---
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // --- 2. Sign In with Email & Password ---
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        throw 'Wrong password provided for that user.';
      } else if (e.code == 'network-request-failed') {
        throw 'Network error. Please check your internet connection.';
      } else {
        throw e.message ?? 'An error occurred.';
      }
    } catch (e) {
      throw 'An unknown error occurred. Please try again.';
    }
  }

  // --- 3. Sign Out ---
  Future<void> signOut() async {
    try {
      // await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // --- 4. Register with Email & Password ---
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw AppStrings.weakPasswordError;
      } else if (e.code == 'email-already-in-use') {
        throw AppStrings.emailInUseError;
      } else if (e.code == 'network-request-failed') {
        throw AppStrings.networkError;
      } else {
        throw e.message ?? AppStrings.genericError;
      }
    } catch (e) {
      throw AppStrings.genericError;
    }
  }

  // --- 6. Send Email Verification ---
  Future<void> sendEmailVerification(User user) async {
    try {
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw 'Failed to send verification email. Please try again.';
    }
  }

  // --- 7. Send Password Reset Email ---
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw 'Failed to send password reset email. Please try again.';
    }
  }

  // --- 8. Verify Phone Number ---
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(FirebaseAuthException e) onVerificationFailed,
    required void Function(PhoneAuthCredential credential) onVerificationCompleted,
  }) async {
    try {
      if (kIsWeb) {
        throw Exception('Phone Auth is not supported on Web');
      }

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: onVerificationCompleted,
        verificationFailed: onVerificationFailed,
        codeSent: onCodeSent,
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-retrieval timeout
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      throw 'Failed to verify phone number: ${e.toString()}';
    }
  }

  // --- 9. Sign In with OTP (Phone Credential) ---
  Future<UserCredential> signInWithOtp({
    required String verificationId,
    required String smsCode,
}) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw 'Failed to sign in with OTP. Please check the code and try again.';
    }
  }

  // --- 10. NEW: Change Password ---
  Future<void> changePassword(String currentPassword,
      String newPassword) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw 'No user is currently signed in.';
      }

      // Get credentials
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      // Re-authenticate the user
      await user.reauthenticateWithCredential(cred);

      // If re-authentication is successful, update the password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw 'An unknown error occurred: ${e.toString()}';
    }
  }

  // --- Helper Function for Firebase Errors ---
  String _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
    // --- ADDED THIS ---
      case 'wrong-password':
        return 'Incorrect current password provided.';
    // ---
      case 'invalid-phone-number':
        return 'The phone number provided is not valid.';
      case 'session-expired':
        return 'The OTP code has expired. Please send a new one.';
      case 'invalid-verification-code':
        return 'The OTP code is invalid. Please try again.';
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}
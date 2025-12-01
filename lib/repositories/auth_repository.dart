// lib/repositories/auth_repository.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:quiz_panel/utils/app_strings.dart';

/// **Why we used this class (AuthRepository):**
/// This class acts as the "Gatekeeper" or "Bridge" between our app and Firebase Authentication.
/// Instead of writing raw Firebase code (like `FirebaseAuth.instance.signIn...`) inside every screen,
/// we centralize it here.
///
/// **How it helps:**
/// 1. **Cleaner Code:** Screens just say `authRepo.login()`, they don't care how it happens.
/// 2. **Error Handling:** We catch messy Firebase errors here and turn them into user-friendly messages.
/// 3. **Testing:** We can easily swap this out for a "Fake" repository when testing the app.
class AuthRepository {
  // The actual Firebase tool we use to talk to the server.
  final FirebaseAuth _firebaseAuth;

  // Constructor: We ask for the FirebaseAuth instance (Dependency Injection).
  AuthRepository(this._firebaseAuth);

  // --- 1. Get Authentication Status ---

  /// **Logic: Live Auth Stream**
  /// This provides a "Live Feed" of the user's login status.
  ///
  /// **How it works:**
  /// It listens to Firebase.
  /// - If the user logs in, this stream sends a `User` object.
  /// - If they log out, it sends `null`.
  /// Our `AppRouterProvider` watches this to decide whether to show the Login Screen or the Dashboard.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // --- 2. Sign In with Email & Password ---

  /// **Logic: Login**
  /// Attempts to sign in an existing user using their email and password.
  ///
  /// **How it works:**
  /// 1. It sends the credentials to Firebase.
  /// 2. If successful, Firebase updates the `authStateChanges` stream automatically.
  /// 3. If it fails (e.g., wrong password), we catch the specific error code and throw a readable message.
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

  /// **Logic: Logout**
  /// Ends the current user's session.
  ///
  /// **How it works:**
  /// Calling `signOut()` triggers the `authStateChanges` stream to emit `null`.
  /// The app router detects this `null` and immediately redirects the user to the Login screen.
  Future<void> signOut() async {
    try {
      // await _googleSignIn.signOut(); // If using Google Sign In, sign out from there too.
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // --- 4. Register with Email & Password ---

  /// **Logic: Create Account**
  /// Creates a brand new user in Firebase Authentication.
  ///
  /// **Note:**
  /// This only creates the "Auth User" (Email/Password). It does NOT create the user's
  /// profile in the Firestore Database (Name, Role, etc.). That is handled by `UserRepository`.
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

  /// **Logic: Verify Email**
  /// Sends a secure link to the user's email address to prove they own it.
  ///
  /// **Why do we need this?**
  /// To prevent fake accounts and ensure we can recover the account later.
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

  /// **Logic: Forgot Password**
  /// Sends an email with a link allowing the user to set a new password.
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

  /// **Logic: Phone Login (Step 1)**
  /// Initiates the phone number verification process (Mobile Only).
  ///
  /// **How it works:**
  /// 1. We check if the app is running on Web (Phone auth is complicated on web, so we disable it here).
  /// 2. We ask Firebase to send an SMS code to the `phoneNumber`.
  /// 3. Firebase calls the `onCodeSent` callback when the SMS is successfully dispatched.
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(FirebaseAuthException e) onVerificationFailed,
    required void Function(PhoneAuthCredential credential)
    onVerificationCompleted,
  }) async {
    try {
      if (kIsWeb) {
        throw Exception('Phone Auth is not supported on Web');
      }

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        // Android automatic verification (rare but possible)
        verificationCompleted: onVerificationCompleted,
        // Something went wrong (e.g., invalid number)
        verificationFailed: onVerificationFailed,
        // SMS sent successfully! This gives us the 'verificationId' we need for Step 2.
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

  /// **Logic: Phone Login (Step 2)**
  /// Completes the login by verifying the SMS code the user entered.
  ///
  /// **How it works:**
  /// It combines the `verificationId` (received in Step 1) and the `smsCode` (entered by user)
  /// into a credential, then signs in.
  Future<UserCredential> signInWithOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw 'Failed to sign in with OTP. Please check the code and try again.';
    }
  }

  // --- 10. Change Password ---

  /// **Logic: Update Password (Secure)**
  /// Allows a logged-in user to change their password.
  ///
  /// **Why Re-authenticate?**
  /// Changing a password is a sensitive action. Firebase requires the user to prove
  /// they are who they say they are (by entering their *current* password) right before
  /// allowing the change. This prevents hackers from changing your password if you left your phone unlocked.
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw 'No user is currently signed in.';
      }

      // 1. Create a credential with the OLD password.
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      // 2. Re-authenticate: Prove identity to Firebase.
      await user.reauthenticateWithCredential(cred);

      // 3. Update: If step 2 passes, change to the NEW password.
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw 'An unknown error occurred: ${e.toString()}';
    }
  }

  // --- Helper Function for Firebase Errors ---

  /// **Logic: Error Translator**
  /// Converts confusing Firebase error codes (like `auth/user-not-found`) into
  /// plain English messages for the user.
  String _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'wrong-password':
        return 'Incorrect current password provided.';
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

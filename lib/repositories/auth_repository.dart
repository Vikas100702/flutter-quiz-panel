// lib/repositories/auth_repository.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:quiz_panel/utils/app_strings.dart';

// This is the 'Chef' class that talks to Firebase Authentication.
class AuthRepository {
  // We are getting an instance of Firebase Auth
  // so we can call its functions (like signIn, signOut).
  final FirebaseAuth _firebaseAuth;

  // This is the 'Constructor'.
  // Whoever calls AuthRepository must provide the FirebaseAuth instance.
  // This is called "Dependency Injection".
  AuthRepository(this._firebaseAuth);

  // --- 1. Get Authentication Status ---
  // This function returns a Stream. A Stream is like a pipe.
  // Firebase will put a 'User' object in the pipe if someone is logged in,
  // and 'null' if they are logged out.
  // Our 'Manager' (AuthProvider) will listen to this pipe.

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // --- 2. Sign In with Email & Password ---
  // This function will be called by our 'Manager' (AuthProvider)
  // when the user presses the 'Login' button.

  Future<void> signInWithEmailAndPassword({required String email, required String password}) async {
    try {
      // Tell Firebase Auth to try signing in.
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);

      // If successful, the 'authStateChanges' stream (above)
      // will automatically send the new User object.
    } on FirebaseAuthException catch(e) {
      // We catch the specific Firebase error code and
      // throw a clean, readable message for our UI.
      if (e.code == 'user-not-found') {
        throw 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        throw 'Wrong password provided for that user.';
      } else if (e.code == 'network-request-failed') {
        throw 'Network error. Please check your internet connection.';
      } else {
        // General Firebase error
        throw e.message ?? 'An error occurred.';
      }
    } catch (e) {
      // Catch any other network or general error
      throw 'An unknown error occurred. Please try again.';
    }
  }

  // --- 3. Sign Out ---
  Future<void> signOut() async {
    try {
      // Tell Firebase Auth to sign out.
      await _firebaseAuth.signOut();

      // When successful, the 'authStateChanges' stream (above)
      // will automatically send 'null'.
    } on FirebaseAuthException catch(e) {
      // If Firebase sends an error, we 'throw' it so the UI can catch it and show a message.
      throw Exception(e.message);
    }
  }

  // --- 4. Register with Email & Password ---
  // This function creates a new user in Firebase Auth.
  // It returns the 'UserCredential' which contains the new user's 'uid'.
  Future<UserCredential> registerWithEmailAndPassword({required String email, required String password,}) async {
    try {

      // Tell Firebase Auth to create a new user.
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);

      // Return the full credential
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Handle specific registration errors
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

}
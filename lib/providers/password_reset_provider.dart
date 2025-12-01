// lib/providers/password_reset_provider.dart

import 'package:flutter_riverpod/legacy.dart';
import 'package:quiz_panel/providers/auth_provider.dart';
import 'package:quiz_panel/repositories/auth_repository.dart';

/// **Why we used this Provider (passwordResetProvider):**
/// This connects our logic (`PasswordResetNotifier`) to the UI (`ForgotPasswordScreen`).
///
/// **How it works:**
/// 1. It watches the `authRepositoryProvider` to get the tool needed to send emails.
/// 2. It creates an instance of `PasswordResetNotifier` and gives it that tool.
/// 3. The UI watches this provider to know if it's currently "loading" or if the email was "sent successfully".
final passwordResetProvider =
    StateNotifierProvider<PasswordResetNotifier, PasswordResetState>((ref) {
      // Dependency Injection: Get the repository that handles Firebase calls.
      final authRepository = ref.watch(authRepositoryProvider);

      // Create and return the logic controller.
      return PasswordResetNotifier(authRepository);
    });

/// **Why we used this class (PasswordResetState):**
/// This class holds all the variables related to the "Forgot Password" screen in one place.
/// Instead of managing `isLoading`, `isSuccess`, and `error` separately in the UI, we bundle them here.
/// This makes the state predictable and easy to manage.
class PasswordResetState {
  final bool isLoading; // Is the app currently talking to the server?
  final bool isSuccess; // Was the email sent successfully?
  final String? error; // Did something go wrong? (e.g., "User not found").
  final String? email; // The email address the user entered.
  final DateTime?
  lastSent; // The time when the last email was sent (for cooldown).

  // **Constructor:**
  // Sets default values (not loading, not successful yet).
  PasswordResetState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
    this.email,
    this.lastSent,
  });

  /// **What is this method? (copyWith)**
  /// Since this class is immutable (fields cannot be changed), we use `copyWith` to update state.
  /// It creates a *new* object with updated values while keeping the old ones for fields we didn't change.
  PasswordResetState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? error,
    String? email,
    DateTime? lastSent,
  }) {
    return PasswordResetState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error, // Can be set to null to clear errors.
      email: email ?? this.email,
      lastSent: lastSent ?? this.lastSent,
    );
  }

  /// **What is this property? (canResend)**
  /// This logic prevents users from spamming the "Resend Email" button.
  /// It checks if 1 minute has passed since the `lastSent` time.
  bool get canResend {
    if (lastSent == null) return true; // Never sent before? Then yes, can send.
    final now = DateTime.now();
    final difference = now.difference(lastSent!);
    return difference.inMinutes >= 1; // Allow resend only after 1 minute.
  }
}

/// **Why we used this class (PasswordResetNotifier):**
/// This is the "Brain" of the Password Reset feature.
/// It contains the function to actually talk to Firebase and update the state.
class PasswordResetNotifier extends StateNotifier<PasswordResetState> {
  // We need the AuthRepository to perform the actual network request.
  final AuthRepository _authRepository;

  // Constructor receives the repository and sets the initial state.
  PasswordResetNotifier(this._authRepository) : super(PasswordResetState());

  /// **Logic: Send Reset Email**
  /// This function handles the entire process of sending the recovery link.
  Future<void> sendResetEmail(String email) async {
    // 1. Update state to 'Loading'. Clear old errors.
    state = state.copyWith(isLoading: true, error: null, email: email);

    try {
      // 2. Call the repository to send the email via Firebase.
      await _authRepository.sendPasswordResetEmail(email);

      // 3. Success! Stop loading, mark as success, and save the timestamp.
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        lastSent: DateTime.now(),
      );
    } catch (error) {
      // 4. Failure! Stop loading and save the error message to display to the user.
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
        isSuccess: false,
      );
    }
  }

  /// **Helper: Reset State**
  /// Clears everything (useful when leaving the screen).
  void resetState() {
    state = PasswordResetState();
  }

  /// **Helper: Clear Error**
  /// Clears just the error message (useful when the user starts typing again).
  void clearError() {
    state = state.copyWith(error: null);
  }
}

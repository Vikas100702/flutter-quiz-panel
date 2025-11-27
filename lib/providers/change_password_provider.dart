// lib/providers/change_password_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:quiz_panel/providers/auth_provider.dart';

/// **Why we used this class (ChangePasswordState):**
/// This class acts as the "State" or "Snapshot" for the Change Password screen.
/// Instead of having separate variables like `isLoading`, `isSuccess`, and `error` scattered
/// inside a widget, we group them into this single, clean object.
///
/// **How it helps:**
/// It makes the UI predictable. The UI just listens to this one object.
/// If `isLoading` is true, show a spinner. If `error` is not null, show a snackbar.
@immutable
class ChangePasswordState {
  final bool isLoading; // Is the app currently talking to Firebase?
  final bool isSuccess; // Did the password change successfully?
  final String? error;  // Did something go wrong? (e.g., "Wrong current password").

  // **Constructor:**
  // Sets default values (not loading, no success yet, no error).
  const ChangePasswordState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
  });

  /// **What is this method? (copyWith)**
  /// Since this class is immutable (we cannot change fields like `state.isLoading = true`),
  /// we use this helper method to create a *new* copy of the state with updated values.
  ///
  /// **How it works:**
  /// If we call `copyWith(isLoading: true)`, it keeps the old `error` and `isSuccess` values
  /// but replaces `isLoading` with true.
  ChangePasswordState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? error,
    bool clearError = false, // A special flag to manually clear old errors.
  }) {
    return ChangePasswordState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      // If clearError is true, set error to null. Otherwise, use the new error or keep the old one.
      error: clearError ? null : error ?? this.error,
    );
  }
}

/// **Why we used this class (ChangePasswordNotifier):**
/// This is the "Brain" or logic controller for the Change Password feature.
/// It doesn't draw any UI. Its only job is to handle the *action* of changing the password
/// and updating the `ChangePasswordState` accordingly.
class ChangePasswordNotifier extends StateNotifier<ChangePasswordState> {
  final Ref _ref; // Used to read other providers (like authRepository).

  ChangePasswordNotifier(this._ref) : super(const ChangePasswordState());

  /// **What this function does:**
  /// It coordinates the entire password change process.
  ///
  /// **How it works:**
  /// 1. **Start Loading:** It updates the state to `isLoading: true` so the UI shows a spinner.
  /// 2. **Call API:** It asks the `AuthRepository` to perform the actual Firebase operation.
  /// 3. **Handle Success:** If successful, it updates state to `isSuccess: true`.
  /// 4. **Handle Error:** If it fails (e.g., wrong password), it catches the error and saves the message in the state.
  Future<void> submitChangePassword(
      String currentPassword, String newPassword) async {
    // Set loading to true and clear any previous errors.
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Call the repository function to change the password in Firebase.
      await _ref
          .read(authRepositoryProvider)
          .changePassword(currentPassword, newPassword);

      // Success! Stop loading and mark as success.
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      // Failure! Stop loading and save the error message.
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

/// **What is this Provider? (changePasswordProvider)**
/// This connects our logic (`ChangePasswordNotifier`) to the UI.
/// Any widget (like `ChangePasswordScreen`) can watch this provider to:
/// 1. Read the current state (Loading? Error?).
/// 2. Call the `submitChangePassword` function.
final changePasswordProvider =
StateNotifierProvider<ChangePasswordNotifier, ChangePasswordState>((ref) {
  return ChangePasswordNotifier(ref);
});
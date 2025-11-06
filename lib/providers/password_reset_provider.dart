// lib/providers/password_reset_provider.dart
import 'package:flutter_riverpod/legacy.dart';

// Provider for managing password reset state
final passwordResetProvider = StateNotifierProvider<PasswordResetNotifier, PasswordResetState>((ref) {
  return PasswordResetNotifier();
});

class PasswordResetState {
  final bool isLoading;
  final bool isSuccess;
  final String? error;
  final String? email;
  final DateTime? lastSent;

  PasswordResetState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
    this.email,
    this.lastSent,
  });

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
      error: error ?? this.error,
      email: email ?? this.email,
      lastSent: lastSent ?? this.lastSent,
    );
  }

  bool get canResend {
    if (lastSent == null) return true;
    final now = DateTime.now();
    final difference = now.difference(lastSent!);
    return difference.inMinutes >= 1; // Can resend after 1 minute
  }
}

class PasswordResetNotifier extends StateNotifier<PasswordResetState> {
  PasswordResetNotifier() : super(PasswordResetState());

  Future<void> sendResetEmail(String email) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      email: email,
    );

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        lastSent: DateTime.now(),
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
        isSuccess: false,
      );
    }
  }

  void resetState() {
    state = PasswordResetState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
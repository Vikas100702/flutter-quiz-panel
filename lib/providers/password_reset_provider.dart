// lib/providers/password_reset_provider.dart
import 'package:flutter_riverpod/legacy.dart';
import 'package:quiz_panel/providers/auth_provider.dart';
import 'package:quiz_panel/repositories/auth_repository.dart';

// Provider ko update karein taake yeh AuthRepository ko read kar sake
final passwordResetProvider =
StateNotifierProvider<PasswordResetNotifier, PasswordResetState>((ref) {
  // AuthRepository ko watch karein
  final authRepository = ref.watch(authRepositoryProvider);
  // Notifier ko AuthRepository pass karein
  return PasswordResetNotifier(authRepository);
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
      error: error, // Error ko null bhi set kar sakein
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
  // AuthRepository ko hold karne ke liye variable banayein
  final AuthRepository _authRepository;

  // Constructor ko update karein taake yeh AuthRepository le
  PasswordResetNotifier(this._authRepository) : super(PasswordResetState());

  Future<void> sendResetEmail(String email) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      email: email,
    );

    try {
      // --- YEH HAI ASAL FIX ---
      // Simulate API call ko asal call se badlein
      // await Future.delayed(const Duration(seconds: 2)); // Isay hata dein
      await _authRepository.sendPasswordResetEmail(email); // Yeh asal call hai

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        lastSent: DateTime.now(),
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(), // Error message ko state mein save karein
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
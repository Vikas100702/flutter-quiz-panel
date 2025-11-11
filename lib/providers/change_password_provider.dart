// lib/providers/change_password_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:quiz_panel/providers/auth_provider.dart';

// 1. Define the state class
@immutable
class ChangePasswordState {
  final bool isLoading;
  final bool isSuccess;
  final String? error;

  const ChangePasswordState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
  });

  ChangePasswordState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? error,
    bool clearError = false,
  }) {
    return ChangePasswordState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: clearError ? null : error ?? this.error,
    );
  }
}

// 2. Define the Notifier
class ChangePasswordNotifier extends StateNotifier<ChangePasswordState> {
  final Ref _ref;

  ChangePasswordNotifier(this._ref) : super(const ChangePasswordState());

  Future<void> submitChangePassword(
      String currentPassword, String newPassword) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _ref
          .read(authRepositoryProvider)
          .changePassword(currentPassword, newPassword);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// 3. Define the Provider
final changePasswordProvider =
StateNotifierProvider<ChangePasswordNotifier, ChangePasswordState>((ref) {
  return ChangePasswordNotifier(ref);
});
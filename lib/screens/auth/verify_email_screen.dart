// lib/screens/auth/verify_email_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/providers/auth_provider.dart';
import 'package:quiz_panel/providers/user_data_provider.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/widgets/buttons/app_button.dart';
import 'package:quiz_panel/widgets/layout/responsive_layout.dart';

/// **Why we used this Widget (VerifyEmailScreen):**
/// This screen is mandatory for users who registered using Email/Password.
/// Firebase requires users to verify their email address before accessing protected parts of the application.
///
/// **How it helps:**
/// 1. **Security:** Ensures the account owner is legitimate and that the email can be used for password recovery.
/// 2. **Flow Control:** The `AppRouterProvider` detects the unverified email state and forces the user here, blocking access to the dashboard.
class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  // **State Variables:**
  bool _isSending =
      false; // Controls loading spinner for the 'Resend Email' button.
  bool _isChecking =
      false; // Controls loading spinner for the 'Refresh Status' button.

  // **Cooldown Logic:** Prevents user from spamming the verification email send button.
  Timer? _cooldownTimer;
  int _cooldownSeconds =
      0; // Starts countdown from 60 seconds after sending an email.

  @override
  void dispose() {
    // **Cleanup:** Always cancel the timer when the screen closes to prevent memory leaks.
    _cooldownTimer?.cancel();
    super.dispose();
  }

  /// **Logic: Start Resend Cooldown**
  /// Initializes the 60-second timer after an email is sent.
  ///
  /// **How it works:**
  /// It creates a periodic timer that ticks every second, updating `_cooldownSeconds`.
  void _startCooldown() {
    setState(() {
      _cooldownSeconds = 60; // Start at 60 seconds.
    });
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds > 0) {
        setState(() {
          _cooldownSeconds--;
        });
      } else {
        timer.cancel(); // Stop the timer when it hits zero.
      }
    });
  }

  /// **Logic: Resend Verification Email**
  /// Triggers the actual network call to send a new verification email.
  Future<void> _resendEmail() async {
    setState(() {
      _isSending = true;
    });
    try {
      // Get the currently logged-in Firebase User object.
      final authUser = ref.read(authStateProvider).value;
      if (authUser != null) {
        // Call the repository to send the verification email.
        await ref.read(authRepositoryProvider).sendEmailVerification(authUser);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.resendEmailSuccess),
              backgroundColor: AppColors.success,
            ),
          );
        }
        // Start the mandatory 60-second cooldown timer.
        _startCooldown();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  /// **Logic: Check Verification Status**
  /// This is the most crucial step after the user clicks the link in their email.
  ///
  /// **How it works:**
  /// 1. **Reload Firebase User:** It forces Firebase Auth to check its server for the latest verification status (`authUser?.reload()`).
  /// 2. **Invalidate Providers:** It clears the locally cached data (`userDataProvider` and `authStateProvider`).
  ///    - This forces the entire application to re-run the startup checks (AuthWrapper/AppRouter).
  ///    - If the user is now verified, the router will detect the change and navigate them to the dashboard.
  Future<void> _refreshStatus() async {
    setState(() {
      _isChecking = true;
    });

    final authUser = ref.read(authStateProvider).value;

    // Step 1: Tell Firebase to get the fresh status from the server.
    await authUser?.reload();

    // Step 2: Force Riverpod to forget the old, unverified state.
    ref.invalidate(userDataProvider);
    ref.invalidate(authStateProvider);

    // Give a small delay to ensure providers have time to re-fetch/re-calculate state before UI update finishes.
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the current user details for displaying the email address.
    final authUser = ref.watch(authStateProvider).value;
    final bool canResend = _cooldownSeconds == 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.verifyEmailTitle),
        actions: [
          // Logout button to allow switching accounts.
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: AppStrings.logoutButton,
            onPressed: () {
              ref.read(authRepositoryProvider).signOut();
            },
          ),
        ],
      ),
      // **Responsive Wrapper:** Centers the content for desktop/web.
      body: ResponsiveAuthLayout(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Large Email Icon
              Icon(
                Icons.mark_email_read_outlined,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: 24),

              // Verification Message and User Email
              Text(
                AppStrings.verifyEmailMessage,
                style: AppTextStyles.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                authUser?.email ?? 'your email',
                style: AppTextStyles.displaySmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.checkYourInbox,
                style: AppTextStyles.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Button 1: I've Verified, Continue (Calls _refreshStatus)
              AppButton(
                text: AppStrings.refreshStatusButton,
                onPressed: _isChecking ? null : _refreshStatus,
                isLoading: _isChecking,
                type: AppButtonType.primary,
                icon: Icons.refresh,
              ),
              const SizedBox(height: 16),

              // Button 2: Resend Email (Controlled by Cooldown Timer)
              AppButton(
                text: canResend
                    ? AppStrings.resendEmailButton
                    : AppStrings.resendEmailCooldown.replaceFirst(
                        '%s',
                        _cooldownSeconds.toString(),
                      ),
                onPressed: (_isSending || !canResend) ? null : _resendEmail,
                isLoading: _isSending,
                type: AppButtonType.outline,
                icon: Icons.send,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

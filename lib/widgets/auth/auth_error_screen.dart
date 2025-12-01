// lib/widgets/auth/auth_error_screen.dart

/*
/// Why we used this file (AuthErrorScreen):
/// This specialized screen is designed to handle **critical failure states** that occur immediately after a user attempts to log in,
/// but before the system can successfully fetch their full user profile (`UserModel`) from Firestore.
/// It is used by the `AuthWrapper` router gate to prevent users from getting stuck on an infinite loading screen or crashing due to missing data.

/// What it is doing:
/// 1. **User Feedback:** Displays a prominent icon and a clear, non-technical error message derived from the raw technical exception.
/// 2. **Recovery Options:** Provides the user with two explicit actions: 'Try Again' (re-fetch data) and 'Go to Login' (reset the entire session).
/// 3. **Debugging Aid:** Includes a hidden/collapsible section for technical details, which is helpful for developers or support personnel to diagnose the root cause (e.g., network timeout, missing permissions).

/// How it is working:
/// It is a stateless widget that requires two critical pieces of data to function: the `error` string (the exception message)
/// and the `onRetry` callback (the function to trigger a new attempt to load user data, typically invalidating a Riverpod provider).
/// The UI is centered and designed for immediate impact and clarity.

/// How it's helpful:
/// It improves application resilience by gracefully handling unexpected runtime errors (like network loss or Firestore index errors)
/// during the authentication flow, providing a professional safety net instead of just crashing.
*/
import 'package:flutter/material.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/screens/auth/login_screen.dart';
import 'package:quiz_panel/widgets/buttons/app_button.dart';

/// Why we used this class: A StatelessWidget that displays necessary information and handles simple user actions for critical errors.
class AuthErrorScreen extends StatelessWidget {
  final String
  error; // What it is doing: The raw technical error message captured by the provider.
  final VoidCallback
  onRetry; // What it is doing: The function to call when the user wants to re-attempt loading data (e.g., `ref.invalidate`).

  const AuthErrorScreen({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  /// What it is doing: Constructs the fixed UI layout for the error state.
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error Icon
              Icon(
                Icons.error_outline_rounded,
                size: 80,
                color: AppColors.error,
              ),
              const SizedBox(height: 24),

              // Error Title
              Text(
                'Authentication Error',
                style: AppTextStyles.displaySmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Error Message
              Text(
                // How it is working: Uses a helper function to translate the technical error string into a user-friendly message.
                _getUserFriendlyError(error),
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppButton(
                    text: 'Try Again',
                    onPressed:
                        onRetry, // What it is doing: Executes the `onRetry` callback passed from the `AuthWrapper`.
                    type: AppButtonType.primary,
                    icon: Icons.refresh_rounded,
                  ),
                  const SizedBox(width: 16),
                  AppButton(
                    text: 'Go to Login',
                    onPressed: () {
                      // How it is working: Navigates back to the login screen and clears the entire navigation stack (`(route) => false`), essentially resetting the application session.
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    type: AppButtonType.outline,
                    icon: Icons.login_rounded,
                  ),
                ],
              ),

              // Technical details (collapsible for debugging)
              const SizedBox(height: 24),
              _buildTechnicalDetails(error),
            ],
          ),
        ),
      ),
    );
  }

  /// What it is doing: Provides simplified, non-technical messages based on keywords in the raw error.
  String _getUserFriendlyError(String error) {
    if (error.contains('network') || error.contains('internet')) {
      return 'Please check your internet connection and try again.';
    } else if (error.contains('permission') || error.contains('access')) {
      return 'You don\'t have permission to access this resource.';
    } else if (error.contains('timeout')) {
      return 'The request timed out. Please try again.';
    } else {
      // How it's helpful: Catches uncategorized errors with a general prompt.
      return 'An unexpected error occurred. Please try again.';
    }
  }

  /// What it is doing: Creates a collapsible `ExpansionTile` containing the raw error string for debugging purposes.
  Widget _buildTechnicalDetails(String error) {
    return ExpansionTile(
      title: Text(
        'Technical Details',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.outline),
          ),
          child: SelectableText(
            error, // How it is working: Displays the full, raw error.
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
              fontFamily: 'Monospace',
            ),
          ),
        ),
      ],
    );
  }
}

// lib/widgets/auth/auth_error_screen.dart
import 'package:flutter/material.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/screens/auth/login_screen.dart';
import 'package:quiz_panel/widgets/buttons/app_button.dart';

class AuthErrorScreen extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const AuthErrorScreen({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
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
                    onPressed: onRetry,
                    type: AppButtonType.primary,
                    icon: Icons.refresh_rounded,
                  ),
                  const SizedBox(width: 16),
                  AppButton(
                    text: 'Go to Login',
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
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

  String _getUserFriendlyError(String error) {
    if (error.contains('network') || error.contains('internet')) {
      return 'Please check your internet connection and try again.';
    } else if (error.contains('permission') || error.contains('access')) {
      return 'You don\'t have permission to access this resource.';
    } else if (error.contains('timeout')) {
      return 'The request timed out. Please try again.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

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
            error,
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
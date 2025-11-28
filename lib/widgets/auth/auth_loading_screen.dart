// lib/widgets/auth/auth_loading_screen.dart

/*
/// Why we used this file (AuthLoadingScreen):
/// This screen acts as a **visual placeholder** during critical moments of the application startup, specifically when the `AuthWrapper` is fetching
/// asynchronous data streams (Firebase Auth state and user profile data from Firestore).

/// What it is doing:
/// 1. **User Feedback:** Displays a centered, branded loading animation and text message to inform the user that the system is busy.
/// 2. **Flow Control:** Serves as the transient screen between the login attempt and the final role-based dashboard, preventing the UI from crashing or showing half-loaded content.

/// How it is working:
/// It is a simple, stateless widget (`StatelessWidget`) that uses a customized `Stack` (`_buildLoadingLogo`) for visual effect
/// and applies primary brand colors (`AppColors.primary`) to the `CircularProgressIndicator` for consistent theming.

/// How it's helpful:
/// It provides a smooth, professional user experience by replacing a blank screen or technical error with branded, intentional visual feedback while access permissions and profile details are determined.
*/
import 'package:flutter/material.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';

/// Why we used this class: It is a purely presentational, stateless widget responsible only for displaying the loading UI.
class AuthLoadingScreen extends StatelessWidget {
  const AuthLoadingScreen({super.key});

  @override
  /// What it is doing: Builds the vertically centered column containing the logo, text, and spinner.
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Logo
            _buildLoadingLogo(), // What it is doing: Calls the private method to render the multi-layered logo design.
            const SizedBox(height: 32),

            // Loading Text
            Text(
              'Setting up your experience...',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Progress Indicator with custom styling
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                // How it is working: Uses an `AlwaysStoppedAnimation` to ensure the spinner's color matches the primary theme.
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            const SizedBox(height: 16),

            // Subtle hint
            Text(
              'This may take a few moments',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// What it is doing: Creates the visually layered logo using a `Stack`.
  /// How it's helpful: The layered approach adds depth and sophistication compared to a simple icon.
  Widget _buildLoadingLogo() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulsing background circle
        // How it is working: Provides a subtle, expanding/contracting background layer (though animation logic is absent here, the style supports it).
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
        ),

        // Main logo
        // What it is doing: The core application icon with a primary gradient and shadow effect.
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primaryDark,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.quiz_rounded,
            size: 35,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
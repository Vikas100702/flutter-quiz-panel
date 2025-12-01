// lib/widgets/auth/login_form.dart

/*
/// Why we used this file (LoginForm):
/// This widget encapsulates the UI structure and interactivity of the sign-in form.
/// By extracting this into a separate widget, we keep the `LoginScreen` clean and focused on high-level logic (like API calls),
/// while this file handles the layout, spacing, and input field rendering.

/// What it is doing:
/// 1. **Input Collection:** Renders text fields for Email and Password using the custom `AppTextField` widget.
/// 2. **Scroll Handling:** Wraps the entire form in a `SingleChildScrollView` to prevent layout overflow errors when the on-screen keyboard appears.
/// 3. **Navigation Triggers:** Provides clickable elements to navigate to "Forgot Password" or "Register" screens.
/// 4. **Action Trigger:** Provides the primary "Login" button to initiate the authentication process.

/// How it is working:
/// It is a `StatelessWidget` that receives `TextEditingController`s and callback functions (`onLogin`, `onRegister`) from its parent.
/// This makes the form "dumb" (pure UI) and reusable, as it delegates the actual business logic back to the parent screen.

/// How it's helpful:
/// It ensures a consistent look and feel for the login process and solves common UI issues like keyboard occlusion automatically.
*/
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/utils/app_routes.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/widgets/buttons/app_button.dart';
import 'package:quiz_panel/widgets/inputs/app_text_field.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.onLogin,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    // Why we used SingleChildScrollView:
    // When the keyboard pops up on mobile devices, the available vertical space shrinks drastically.
    // Without this scroll view, the bottom content (like the Register link) would be covered or cause a "Bottom Overflowed" error.
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize
            .min, // How it is working: Takes only the minimum height needed, allowing correct centering.
        children: [
          // Header Section (Logo and Title)
          _buildHeader(),
          const SizedBox(height: 30),

          // Form Field: Email
          AppTextField(
            controller: emailController,
            label: AppStrings.emailLabel,
            prefixIcon: Icons.email_rounded,
            keyboardType: TextInputType.emailAddress,
            // What it is doing: Triggers the login logic when the user presses "Enter" or "Done" on the keyboard.
            onSubmitted: (_) => _handleSubmit(context),
            enabled:
                !isLoading, // Disables input while a network request is in progress.
          ),
          const SizedBox(height: 20),

          // Form Field: Password
          AppTextField(
            controller: passwordController,
            label: AppStrings.passwordLabel,
            prefixIcon: Icons.lock_rounded,
            isPassword: true, // Hides the text input.
            onSubmitted: (_) => _handleSubmit(context),
            enabled: !isLoading,
          ),
          const SizedBox(height: 16),

          // Forgot Password Link
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: isLoading
                  ? null
                  : () {
                      // What it is doing: Navigates to the dedicated password reset screen.
                      context.push(AppRoutePaths.forgotPassword);
                    },
              child: Text(
                'Forgot Password?',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Primary Action: Login Button
          AppButton(
            text: AppStrings.loginButton,
            onPressed: isLoading
                ? null
                : onLogin, // Disables button to prevent double-clicks during loading.
            isLoading: isLoading, // Shows a spinner inside the button.
            type: AppButtonType.primary,
          ),
          const SizedBox(height: 24),

          // Visual Divider ("or")
          _buildDivider(),
          const SizedBox(height: 24),

          // Secondary Action: Register Link
          // How it's helpful: Allows new users to easily switch to the sign-up flow.
          const SizedBox(height: 24),
          _buildRegisterSection(context),
        ],
      ),
    );
  }

  /// What it is doing: Builds the branding section containing the app icon and welcome text.
  Widget _buildHeader() {
    return Column(
      children: [
        Icon(Icons.quiz_rounded, size: 64, color: AppColors.primary),
        const SizedBox(height: 16),
        Text(
          'Welcome Back',
          style: AppTextStyles.displaySmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to continue your learning journey',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textTertiary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// What it is doing: Creates a visual separator with the text "or" between the login button and registration link.
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(color: AppColors.outline.withValues(alpha: 0.5)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: AppColors.outline.withValues(alpha: 0.5)),
        ),
      ],
    );
  }

  /// What it is doing: Builds the footer text prompting users to create an account if they don't have one.
  Widget _buildRegisterSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppStrings.noAccount,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: isLoading ? null : onRegister,
          child: Text(
            AppStrings.registerNow,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// Logic: Helper to handle 'Enter' key submission.
  /// How it works: Ensures the login action is only triggered if the form is not currently loading.
  void _handleSubmit(BuildContext context) {
    if (!isLoading) {
      onLogin();
    }
  }
}

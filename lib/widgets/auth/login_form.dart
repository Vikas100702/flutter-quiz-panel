// lib/widgets/auth/login_form.dart
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
  final VoidCallback onGoogleSignIn; // --- NEW ---

  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.onLogin,
    required this.onRegister,
    required this.onGoogleSignIn, // --- NEW ---
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header Section
        _buildHeader(),
        const SizedBox(height: 30),

        // Form Fields
        AppTextField(
          controller: emailController,
          label: AppStrings.emailLabel,
          prefixIcon: Icons.email_rounded,
          keyboardType: TextInputType.emailAddress,
          onSubmitted: (_) => _handleSubmit(context),
          enabled: !isLoading, // --- UPDATED ---
        ),
        const SizedBox(height: 20),
        AppTextField(
          controller: passwordController,
          label: AppStrings.passwordLabel,
          prefixIcon: Icons.lock_rounded,
          isPassword: true,
          onSubmitted: (_) => _handleSubmit(context),
          enabled: !isLoading, // --- UPDATED ---
        ),
        const SizedBox(height: 16),

        // Forgot Password
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: isLoading ? null : () {
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

        // Login Button
        AppButton(
          text: AppStrings.loginButton,
          onPressed: isLoading ? null : onLogin,
          isLoading: isLoading,
          type: AppButtonType.primary,
        ),
        const SizedBox(height: 24),

        // Divider
        _buildDivider(),
        const SizedBox(height: 24),

        // --- NEW: Google Sign-In Button ---
        AppButton(
          text: AppStrings.loginWithGoogleButton,
          onPressed: isLoading ? null : onGoogleSignIn,
          isLoading: false, // Login isLoading se alag manage karein
          type: AppButtonType.outline,
          icon: Icons.g_mobiledata_rounded, // Simple Google icon
        ),
        const SizedBox(height: 24),
        // --- END NEW ---

        // Register Section
        _buildRegisterSection(context),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(
          Icons.quiz_rounded,
          size: 64,
          color: AppColors.primary,
        ),
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

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.outline.withOpacity(0.5),
          ),
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
          child: Divider(
            color: AppColors.outline.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

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

  void _handleSubmit(BuildContext context) {
    if (!isLoading) {
      onLogin();
    }
  }
}
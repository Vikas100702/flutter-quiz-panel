// lib/screens/auth/forgot_password_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/providers/password_reset_provider.dart';
import 'package:quiz_panel/utils/app_routes.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/widgets/buttons/app_button.dart';
import 'package:quiz_panel/widgets/inputs/app_text_field.dart';
import 'package:quiz_panel/widgets/layout/responsive_layout.dart';

/// **Why we used this Widget (ForgotPasswordScreen):**
/// This screen allows a user to recover their account by requesting a password reset link.
/// It integrates with Firebase Authentication's built-in email reset functionality.
///
/// **How it helps:**
/// It provides a standardized, secure way for users to regain access to their account
/// without intervention from a system administrator.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen>
// **Why SingleTickerProviderStateMixin?**
// This mixin is essential for enabling the entrance animations driven by `AnimationController`.
    with SingleTickerProviderStateMixin {

  // **Animation Controllers:**
  late AnimationController _controller;
  late Animation<double> _scaleAnimation; // Controls the icon's size (0.9 -> 1.0).
  late Animation<double> _fadeAnimation;  // Controls the content's visibility (0.0 -> 1.0).

  final TextEditingController _emailController = TextEditingController();

  // **Riverpod Notifier Reference:**
  // We store a reference to the Notifier here so we can call its functions (`resetState`)
  // safely within `dispose()`.
  late final PasswordResetNotifier _passwordResetNotifier;

  @override
  void initState() {
    super.initState();

    // **Animation Setup:**
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0, curve: Curves.easeInOut),
    ));

    // Start the entry animation.
    _controller.forward();

    // Initialize the notifier instance to use in dispose and submit logic.
    _passwordResetNotifier = ref.read(passwordResetProvider.notifier);
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();

    // **Cleanup:**
    // Before the widget is destroyed, ensure the password reset state is cleared.
    // This prevents stale success/error messages if the user returns later.
    _passwordResetNotifier.resetState();

    super.dispose();
  }

  /// **Logic: Request Password Reset**
  /// This function handles button press validation and triggers the Firebase reset process.
  ///
  /// **How it works:**
  /// 1. Validates the input for empty and invalid email format.
  /// 2. Calls `sendResetEmail` on the `PasswordResetNotifier`.
  /// 3. The Notifier manages the asynchronous API call and updates the screen's state (loading/success/error).
  Future<void> _resetPassword() async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(AppStrings.enterEmailPrompt),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(AppStrings.invalidEmailError),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Call the Riverpod Notifier to handle the heavy lifting (API call).
    ref.read(passwordResetProvider.notifier).sendResetEmail(email);
  }

  /// **Helper: Email Validation**
  /// Checks if the input string roughly matches an email pattern.
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    return emailRegex.hasMatch(email);
  }

  /// **Logic: Back Button Handler**
  /// Navigates the user back to the login screen.
  /// It prevents navigation if a network operation is currently running.
  void _handleBack() {
    if (!ref.read(passwordResetProvider).isLoading) {
      context.go(AppRoutePaths.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    // **Watch Riverpod State:**
    // We watch the Notifier's state to rebuild the UI when variables change (loading, success).
    final state = ref.watch(passwordResetProvider);
    final bool isLoading = state.isLoading;
    final bool isSuccess = state.isSuccess;

    // **Listen for Side Effects (Snackbar/Navigation):**
    // `ref.listen` is used for actions that shouldn't cause a UI rebuild, like showing a SnackBar
    // or performing navigation *after* a success/failure event.
    ref.listen(passwordResetProvider, (previous, next) {
      // 1. Error Handling: Show SnackBar if an error message is present.
      if (next.error != null && previous?.error != next.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
        // Clear the error immediately so the SnackBar doesn't re-appear on minor rebuilds.
        ref.read(passwordResetProvider.notifier).clearError();
      }

      // 2. Success Handling: Wait 3 seconds, then navigate to login screen.
      if (next.isSuccess && previous?.isSuccess != next.isSuccess) {
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            //ignore: use_build_context_synchronously
            context.go(AppRoutePaths.login);
          }
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _handleBack, // Back button logic.
        ),
        title: const Text(AppStrings.forgotPasswordTitle),
        centerTitle: true,
      ),
      // **Responsive Wrapper:** Ensures good presentation on web/desktop.
      body: ResponsiveAuthLayout(
        showBackground: true,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Apply the entrance animations.
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          // **Conditional Rendering:**
          // If successful, show the success state; otherwise, show the main form.
          child: isSuccess ? _buildSuccessState() : _buildResetForm(isLoading),
        ),
      ),
    );
  }

  /// **Widget: Password Reset Form**
  /// Displays the email input field and the "Send Reset Link" button.
  Widget _buildResetForm(bool isLoading) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header section with icon and title.
          _buildHeader(),
          const SizedBox(height: 32),

          // Email Input Field.
          AppTextField(
            controller: _emailController,
            label: AppStrings.emailLabel,
            prefixIcon: Icons.email_rounded,
            keyboardType: TextInputType.emailAddress,
            onSubmitted: (_) => _resetPassword(),
            enabled: !isLoading, // Disable during loading.
          ),
          const SizedBox(height: 24),

          // Information box for instructions.
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'We will send a password reset link to your email address',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Action Button.
          AppButton(
            text: AppStrings.resetPasswordButton,
            onPressed: isLoading ? null : _resetPassword,
            isLoading: isLoading,
            type: AppButtonType.primary,
            icon: Icons.send_rounded,
          ),
          const SizedBox(height: 20),

          // Secondary Button: Back to Login.
          AppButton(
            text: 'Back to Login',
            onPressed: isLoading ? null : _handleBack,
            type: AppButtonType.outline,
            icon: Icons.arrow_back_rounded,
          ),
        ],
      ),
    );
  }

  /// **Widget: Success State View**
  /// Shown after the email has been successfully sent.
  Widget _buildSuccessState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Large Success Icon.
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_rounded,
            size: 60,
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: 32),

        // Success Messages.
        Text(
          AppStrings.resetEmailSent,
          style: AppTextStyles.displaySmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        Text(
          AppStrings.checkEmailInstructions,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textTertiary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // Redirecting hint and progress indicator.
        Text(
          'Redirecting to login...',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textTertiary,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 32),

        SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
      ],
    );
  }

  /// **Widget: Form Header**
  /// Builds the top section with the Reset Password icon and descriptive text.
  Widget _buildHeader() {
    return Column(
      children: [
        // Animated Icon stack.
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
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
                Icons.lock_reset_rounded,
                size: 35,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Title and Subtitle text.
        Text(
          AppStrings.forgotPasswordTitle,
          style: AppTextStyles.displaySmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),

        Text(
          'Enter your email address and we\'ll send you a link to reset your password',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textTertiary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
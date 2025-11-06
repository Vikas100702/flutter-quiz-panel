// lib/screens/auth/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// Password reset provider ko import karein
import 'package:quiz_panel/providers/password_reset_provider.dart';
import 'package:quiz_panel/utils/app_routes.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/widgets/buttons/app_button.dart';
import 'package:quiz_panel/widgets/inputs/app_text_field.dart';
import 'package:quiz_panel/widgets/layout/responsive_layout.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final TextEditingController _emailController = TextEditingController();
  // --- Local state (isLoading, isSuccess) hata dein ---
  // bool _isLoading = false;
  // bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
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

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    // Screen dispose hone par provider ko reset karein
    Future.microtask(() => ref.read(passwordResetProvider.notifier).resetState());
    super.dispose();
  }

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

    // --- Local state set karne ke bajaye notifier ko call karein ---
    // setState(() { _isLoading = true; }); // Hata dein
    ref.read(passwordResetProvider.notifier).sendResetEmail(email);
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    return emailRegex.hasMatch(email);
  }

  // --- Is function ki zaroorat nahi, provider error handle karega ---
  // String _getErrorMessage(String error) { ... }

  void _handleBack() {
    // isLoading state ab provider se milegi
    if (!ref.read(passwordResetProvider).isLoading) {
      context.go(AppRoutePaths.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- Provider ki state ko watch karein ---
    final state = ref.watch(passwordResetProvider);
    final bool isLoading = state.isLoading;
    final bool isSuccess = state.isSuccess;

    // --- Error aur Success ko listen karein ---
    ref.listen(passwordResetProvider, (previous, next) {
      // Agar error ho toh SnackBar dikhayein
      if (next.error != null && previous?.error != next.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
        // Error ko clear karein taake dubara na dikhe
        ref.read(passwordResetProvider.notifier).clearError();
      }

      // Agar success ho toh login par navigate karein
      if (next.isSuccess && previous?.isSuccess != next.isSuccess) {
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            context.go(AppRoutePaths.login);
          }
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _handleBack,
        ),
        title: const Text(AppStrings.forgotPasswordTitle),
        centerTitle: true,
      ),
      body: ResponsiveAuthLayout(
        showBackground: true,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          // isSuccess ko provider se read karein
          child: isSuccess ? _buildSuccessState() : _buildResetForm(isLoading),
        ),
      ),
    );
  }

  Widget _buildResetForm(bool isLoading) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Section
          _buildHeader(),
          const SizedBox(height: 32),

          // Email Field
          AppTextField(
            controller: _emailController,
            label: AppStrings.emailLabel,
            prefixIcon: Icons.email_rounded,
            keyboardType: TextInputType.emailAddress,
            onSubmitted: (_) => _resetPassword(),
            enabled: !isLoading, // isLoading provider se
          ),
          const SizedBox(height: 24),

          // Info Text
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.1)),
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

          // Reset Button
          AppButton(
            text: AppStrings.resetPasswordButton,
            onPressed: isLoading ? null : _resetPassword,
            isLoading: isLoading, // isLoading provider se
            type: AppButtonType.primary,
            icon: Icons.send_rounded,
          ),
          const SizedBox(height: 20),

          // Back to Login
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

  Widget _buildSuccessState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Success Icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_rounded,
            size: 60,
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: 32),

        // Success Message
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

        Text(
          'Redirecting to login...',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textTertiary,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 32),

        // Loading indicator for redirect
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

  Widget _buildHeader() {
    return Column(
      children: [
        // Animated Icon
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
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
                    color: AppColors.primary.withOpacity(0.3),
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
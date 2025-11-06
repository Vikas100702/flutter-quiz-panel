// lib/screens/auth/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/providers/auth_provider.dart';
import 'package:quiz_panel/utils/app_routes.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/widgets/buttons/app_button.dart';
import 'package:quiz_panel/widgets/inputs/app_text_field.dart';
import 'package:quiz_panel/widgets/layout/responsive_layout.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isSuccess = false;

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
    super.dispose();
  }

  Future<void> _resetPassword() async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter your email address'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid email address'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      // Temporary simulation until the method is implemented
      // await _simulatePasswordReset(email);
      await ref.read(authRepositoryProvider).sendPasswordResetEmail(email);


      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });

      // Auto navigate back after success
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        context.go(AppRoutePaths.login);
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getErrorMessage(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // Temporary simulation method - replace with actual implementation
  Future<void> _simulatePasswordReset(String email) async {
    await Future.delayed(const Duration(seconds: 2));

    // Simulate different scenarios for testing
    if (email.contains('test@error.com')) {
      throw 'user-not-found';
    } else if (email.contains('invalid')) {
      throw 'invalid-email';
    }

    // Success case - this is where the actual Firebase call will go
    // await ref.read(authRepositoryProvider).sendPasswordResetEmail(email);
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    return emailRegex.hasMatch(email);
  }

  String _getErrorMessage(String error) {
    if (error.contains('user-not-found')) {
      return 'No account found with this email address';
    } else if (error.contains('invalid-email')) {
      return 'Please enter a valid email address';
    } else if (error.contains('network-request-failed')) {
      return AppStrings.networkError;
    } else {
      return 'Failed to send reset email. Please try again.';
    }
  }

  void _handleBack() {
    if (!_isLoading) {
      context.go(AppRoutePaths.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _handleBack,
        ),
        title: const Text('Reset Password'),
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
          child: _isSuccess ? _buildSuccessState() : _buildResetForm(),
        ),
      ),
    );
  }

  Widget _buildResetForm() {
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
            enabled: !_isLoading,
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
            text: 'Send Reset Link',
            onPressed: _isLoading ? null : _resetPassword,
            isLoading: _isLoading,
            type: AppButtonType.primary,
            icon: Icons.send_rounded,
          ),
          const SizedBox(height: 20),

          // Back to Login
          AppButton(
            text: 'Back to Login',
            onPressed: _isLoading ? null : _handleBack,
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
          'Reset Email Sent!',
          style: AppTextStyles.displaySmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        Text(
          'Check your email for password reset instructions',
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
          'Forgot Password?',
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
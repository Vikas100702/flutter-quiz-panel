// lib/widgets/auth/register_form.dart
import 'package:flutter/material.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/widgets/auth/role_selector.dart';
import 'package:quiz_panel/widgets/buttons/app_button.dart';
import 'package:quiz_panel/widgets/inputs/app_text_field.dart';


class RegisterForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController nameController;
  final bool isLoading;
  final String selectedRole;
  final ValueChanged<String> onRoleChanged;
  final VoidCallback onRegister;
  final VoidCallback onLogin;

  const RegisterForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.nameController,
    required this.isLoading,
    required this.selectedRole,
    required this.onRoleChanged,
    required this.onRegister,
    required this.onLogin,
  });

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.passwordRequiredError;
    }
    if (value.length < 6) {
      return AppStrings.passwordMinLength;
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return AppStrings.passwordUppercaseError;
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return AppStrings.passwordLowercaseError;
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return AppStrings.passwordNumberError;
    }
    // Aap special characters ki list ko customize kar sakte hain
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return AppStrings.passwordSpecialCharError;
    }
    return null; // Sab theek hai
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Section
            _buildHeader(),
            const SizedBox(height: 32),

            // Form Fields
            AppTextField(
              controller: nameController,
              label: AppStrings.nameLabel,
              prefixIcon: Icons.person_rounded,
              keyboardType: TextInputType.name,
              validator: (value) => value!.isEmpty ? 'Name is required.' : null,
              onSubmitted: (_) => _handleSubmit(context),
            ),
            const SizedBox(height: 20),

            AppTextField(
              controller: emailController,
              label: AppStrings.emailLabel,
              prefixIcon: Icons.email_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: (value) => value!.isEmpty ? 'Email is required.' : null,
              onSubmitted: (_) => _handleSubmit(context),
            ),
            const SizedBox(height: 20),

            AppTextField(
              controller: passwordController,
              label: AppStrings.passwordLabel,
              prefixIcon: Icons.lock_rounded,
              isPassword: true,
              hint: AppStrings.passwordMinLength,
              onSubmitted: (_) => _handleSubmit(context),
              validator: _passwordValidator,
            ),
            const SizedBox(height: 24),

            // Role Selector
            RoleSelector(
              selectedRole: selectedRole,
              onRoleChanged: onRoleChanged,
            ),
            const SizedBox(height: 32),

            // Register Button
            AppButton(
              text: AppStrings.registerButton,
              onPressed: isLoading ? null : onRegister,
              isLoading: isLoading,
              type: AppButtonType.primary,
            ),
            const SizedBox(height: 24),

            // Login Section
            _buildLoginSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(
          Icons.person_add_rounded,
          size: 64,
          color: AppColors.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'Create Account',
          style: AppTextStyles.displaySmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Join Pro Olympiad and start your learning journey',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textTertiary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppStrings.haveAccount,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: isLoading ? null : onLogin,
          child: Text(
            AppStrings.loginNow,
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
      onRegister();
    }
  }
}

// lib/widgets/auth/register_form.dart

/*
/// **Why we used this file (RegisterForm):**
/// This file separates the **User Interface (UI)** of the registration form from the **Business Logic** (which lives in `RegisterScreen`).
/// Instead of having one giant file with both logic and UI, we split them up. This makes the code cleaner, easier to read, and easier to test.
///
/// **What it is doing:**
/// 1. **Visual Structure:** It builds the layout for the registration page, including the Header, Input Fields, Role Selector, and Buttons.
/// 2. **Input Handling:** It connects the text fields to the controllers passed down from the parent screen so we can capture what the user types.
/// 3. **Validation:** It contains specific logic (like `_passwordValidator`) to ensure the password meets security standards (uppercase, number, special char).
/// 4. **Interaction:** It detects button presses and calls the appropriate functions (`onRegister`, `onLogin`) provided by the parent.
///
/// **How it helps:**
/// - **Reusability:** If we ever needed this form in a modal or another screen, we could just drop this widget in.
/// - **Responsiveness:** It handles scrolling automatically, so the form doesn't break when the keyboard pops up on mobile.
///
/// **How it is working:**
/// It is a `StatelessWidget`. This means it doesn't store data itself (like "is the user typing?").
/// Instead, it relies entirely on the data (Controllers, isLoading, selectedRole) passed to it via its Constructor.
*/

import 'package:flutter/material.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/widgets/auth/role_selector.dart';
import 'package:quiz_panel/widgets/buttons/app_button.dart';
import 'package:quiz_panel/widgets/inputs/app_text_field.dart';

class RegisterForm extends StatelessWidget {
  // **Data Inputs:**
  // These variables are passed from the parent widget (`RegisterScreen`).
  final GlobalKey<FormState> formKey; // Used to validate all fields at once.
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController nameController;

  // **State Inputs:**
  final bool isLoading; // If true, we disable buttons to prevent double-clicking.
  final String selectedRole; // The currently selected role (Student or Teacher).

  // **Callback Functions:**
  // These are functions passed from the parent. We call them when the user does something.
  final ValueChanged<String> onRoleChanged; // Called when user taps a role card.
  final VoidCallback onRegister; // Called when user taps "Register".
  final VoidCallback onLogin; // Called when user taps "Login Now".

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

  /// **Logic: Password Strength Validator**
  /// **What it is doing:** This function checks if the password string meets our security rules.
  /// **How it works:** It uses Regular Expressions (RegExp) to pattern-match the string.
  /// - Returns `null` if the password is good.
  /// - Returns a String (error message) if the password fails a check.
  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.passwordRequiredError;
    }
    // Check Length
    if (value.length < 6) {
      return AppStrings.passwordMinLength;
    }
    // Check for at least one Uppercase letter (A-Z)
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return AppStrings.passwordUppercaseError;
    }
    // Check for at least one Lowercase letter (a-z)
    if (!value.contains(RegExp(r'[a-z]'))) {
      return AppStrings.passwordLowercaseError;
    }
    // Check for at least one Number (0-9)
    if (!value.contains(RegExp(r'[0-9]'))) {
      return AppStrings.passwordNumberError;
    }
    // Check for Special Characters (!@#$...)
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return AppStrings.passwordSpecialCharError;
    }
    return null; // All checks passed!
  }

  @override
  Widget build(BuildContext context) {
    // **Why use Form?**
    // The Form widget groups all the text fields together. This allows us to call
    // `formKey.currentState!.validate()` later to check every field at once.
    return Form(
      key: formKey,
      // **Why use SingleChildScrollView?**
      // On small screens, or when the keyboard opens, the available space shrinks.
      // This widget allows the user to scroll down to reach the bottom fields, avoiding "Overflow" errors.
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          // **Why mainAxisSize.min?**
          // This tells the Column to only take up as much vertical space as its children need,
          // rather than stretching to fill the whole screen height.
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. The Header (Icon + Title)
            _buildHeader(),
            const SizedBox(height: 32),

            // 2. Name Field
            AppTextField(
              controller: nameController,
              label: AppStrings.nameLabel,
              prefixIcon: Icons.person_rounded,
              keyboardType: TextInputType.name,
              // Simple validation: Name cannot be empty.
              validator: (value) => value!.isEmpty ? 'Name is required.' : null,
              // Submit form when user presses "Enter" on keyboard.
              onSubmitted: (_) => _handleSubmit(context),
            ),
            const SizedBox(height: 20),

            // 3. Email Field
            AppTextField(
              controller: emailController,
              label: AppStrings.emailLabel,
              prefixIcon: Icons.email_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: (value) => value!.isEmpty ? 'Email is required.' : null,
              onSubmitted: (_) => _handleSubmit(context),
            ),
            const SizedBox(height: 20),

            // 4. Password Field
            AppTextField(
              controller: passwordController,
              label: AppStrings.passwordLabel,
              prefixIcon: Icons.lock_rounded,
              isPassword: true, // Hides the text input.
              hint: AppStrings.passwordMinLength,
              onSubmitted: (_) => _handleSubmit(context),
              // Uses our custom strong password validator logic defined above.
              validator: _passwordValidator,
            ),
            const SizedBox(height: 24),

            // 5. Role Selector Widget
            // This custom widget lets the user choose between 'Student' and 'Teacher'.
            RoleSelector(
              selectedRole: selectedRole,
              onRoleChanged: onRoleChanged,
            ),
            const SizedBox(height: 32),

            // 6. Register Button
            // The main action button. It is disabled if `isLoading` is true.
            AppButton(
              text: AppStrings.registerButton,
              onPressed: isLoading ? null : onRegister,
              isLoading: isLoading, // Shows a spinner inside the button if true.
              type: AppButtonType.primary,
            ),
            const SizedBox(height: 24),

            // 7. Login Link (Footer)
            _buildLoginSection(context),
          ],
        ),
      ),
    );
  }

  /// **Helper Widget: Header**
  /// Builds the top section with the branding icon and welcome text.
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

  /// **Helper Widget: Login Section**
  /// Builds the "Already have an account? Login Now" row at the bottom.
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
          // Triggers the navigation to the Login Screen.
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

  /// **Logic: Handle Submission**
  /// Called when the user presses "Enter" on a text field.
  /// It prevents form submission if the app is already loading.
  void _handleSubmit(BuildContext context) {
    if (!isLoading) {
      onRegister();
    }
  }
}
// lib/screens/profile/change_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/providers/change_password_provider.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/widgets/buttons/app_button.dart';
import 'package:quiz_panel/widgets/inputs/app_text_field.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref
        .read(changePasswordProvider.notifier)
        .submitChangePassword(
      _currentPasswordController.text,
      _newPasswordController.text,
    );
  }

  String? _newPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.passwordRequiredError;
    }
    if (value.length < 6) {
      return AppStrings.passwordMinLength;
    }
    // You can add more complex validation from register_form.dart if needed
    if (value == _currentPasswordController.text) {
      return 'New password must be different from the current one.';
    }
    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your new password.';
    }
    if (value != _newPasswordController.text) {
      return 'Passwords do not match.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(changePasswordProvider);
    final isLoading = state.isLoading;

    // Listen for success or error
    ref.listen(changePasswordProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
      }
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(
                        controller: _currentPasswordController,
                        label: 'Current Password',
                        prefixIcon: Icons.lock_clock_rounded,
                        isPassword: true,
                        enabled: !isLoading,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter your current password.'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      AppTextField(
                        controller: _newPasswordController,
                        label: 'New Password',
                        prefixIcon: Icons.lock_rounded,
                        isPassword: true,
                        enabled: !isLoading,
                        validator: _newPasswordValidator,
                      ),
                      const SizedBox(height: 20),
                      AppTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirm New Password',
                        prefixIcon: Icons.lock_clock_rounded,
                        isPassword: true,
                        enabled: !isLoading,
                        validator: _confirmPasswordValidator,
                      ),
                      const SizedBox(height: 32),
                      AppButton(
                        text: AppStrings.saveChangesButton,
                        onPressed: isLoading ? null : _submit,
                        isLoading: isLoading,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
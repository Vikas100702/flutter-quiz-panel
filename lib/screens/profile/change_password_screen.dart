// lib/screens/profile/change_password_screen.dart
//
// Why we used this file:
// This screen provides a secure interface for a logged-in user to change their account password.
// It is a critical component for account security, enforcing Firebase Authentication's
// requirement to re-authenticate with the current password before allowing the change.
// This prevents unauthorized password changes if a user's session is active on an unattended device.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/providers/change_password_provider.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/widgets/buttons/app_button.dart';
import 'package:quiz_panel/widgets/inputs/app_text_field.dart';

// Why we used this Widget:
// It is a ConsumerStatefulWidget, allowing it to manage mutable local state (TextEditingControllers, FormKey)
// while easily consuming the application state (ChangePasswordState) from the Riverpod provider.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

// What it is doing:
// This state class holds the input data, manages the form's lifecycle, and triggers the
// password change logic through the associated Riverpod Notifier.
class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  // How it's helpful: GlobalKey uniquely identifies the Form widget, enabling us to
  // trigger validation and save operations across all nested form fields.
  final _formKey = GlobalKey<FormState>();
  // TextEditingControllers manage the current input values for the three password fields.
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  // How it is working:
  // This Flutter lifecycle method is called when the widget is permanently removed from the tree.
  // It is essential to dispose of all TextEditingControllers to free up allocated system memory and prevent leaks.
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // What it is doing: Handles the final button press to attempt the password change.
  Future<void> _submit() async {
    // Hide the keyboard for a cleaner transition before starting the network request.
    FocusScope.of(context).unfocus();
    // How it is working: Triggers validation on all fields associated with _formKey. If any field fails, execution stops here.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // How it is helpful: Reads the Notifier (logic controller) and calls the function responsible for
    // Firebase re-authentication and password update. The Notifier manages the asynchronous loading state and error handling.
    await ref
        .read(changePasswordProvider.notifier)
        .submitChangePassword(
          _currentPasswordController.text,
          _newPasswordController.text,
        );
  }

  // What it is doing: Custom validation logic for the new password field.
  // How it's helpful: Enforces basic security rules (length) and a crucial business rule:
  // the new password cannot be the same as the old password, ensuring a successful update.
  String? _newPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.passwordRequiredError;
    }
    if (value.length < 6) {
      return AppStrings.passwordMinLength;
    }
    // Rule: New password must be genuinely new.
    if (value == _currentPasswordController.text) {
      return 'New password must be different from the current one.';
    }
    return null; // Validation passed.
  }

  // What it is doing: Custom validation logic for the confirmation field.
  // How it's helpful: Provides immediate feedback and prevents user error by guaranteeing
  // the confirmed password exactly matches the value entered in the new password field.
  String? _confirmPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your new password.';
    }
    // Logic: Directly compares the confirm field text with the main new password controller's text.
    if (value != _newPasswordController.text) {
      return 'Passwords do not match.';
    }
    return null; // Validation passed.
  }

  @override
  Widget build(BuildContext context) {
    // How it is working: Watches the current ChangePasswordState. Any state change (e.g., loading, error)
    // will automatically trigger a rebuild of this widget to update the UI accordingly.
    final state = ref.watch(changePasswordProvider);
    final isLoading = state.isLoading;

    // How it is helpful: Uses ref.listen for 'side effects' (notifications/navigation) that should
    // execute once upon a state transition, instead of every time the widget rebuilds.
    ref.listen(changePasswordProvider, (previous, next) {
      // Error Handling: If an error string is present, show a red error SnackBar.
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
      }
      // Success Handling: If the change was successful, show a success SnackBar and navigate away.
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        // Navigate back to the previous screen (MyAccountScreen in this flow).
        context.pop();
      }
    });

    // What it is doing: Renders the primary Change Password form UI, centrally constrained for responsiveness.
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: Center(
        // How it's helpful: Constrains the width for optimal readability on large screens (like web or desktop), ensuring the form is centered.
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                // The main Form widget, linked to _formKey for all validation.
                child: Form(
                  key: _formKey,
                  child: Column(
                    // Uses mainAxisSize.min to ensure the Column only takes the vertical space required by its children.
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Field 1: Requires Current Password (used for Firebase re-authentication).
                      AppTextField(
                        controller: _currentPasswordController,
                        label: 'Current Password',
                        prefixIcon: Icons.lock_clock_rounded,
                        isPassword: true,
                        enabled: !isLoading, // Disabled during form submission.
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter your current password.'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      // Field 2: New Password (uses custom security validator).
                      AppTextField(
                        controller: _newPasswordController,
                        label: 'New Password',
                        prefixIcon: Icons.lock_rounded,
                        isPassword: true,
                        enabled: !isLoading,
                        validator: _newPasswordValidator,
                      ),
                      const SizedBox(height: 20),
                      // Field 3: Confirm New Password (uses custom match validator).
                      AppTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirm New Password',
                        prefixIcon: Icons.lock_clock_rounded,
                        isPassword: true,
                        enabled: !isLoading,
                        validator: _confirmPasswordValidator,
                      ),
                      const SizedBox(height: 32),
                      // Action Button: Triggers form submission, displays loading state, and disables itself when loading.
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

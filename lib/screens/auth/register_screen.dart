// lib/screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/providers/auth_provider.dart';
import 'package:quiz_panel/repositories/user_repository.dart';
import 'package:quiz_panel/utils/app_routes.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/utils/constants.dart';
import 'package:quiz_panel/widgets/auth/register_form.dart';
import 'package:quiz_panel/widgets/layout/responsive_layout.dart';

/// **Why we used this Widget (RegisterScreen):**
/// This is the primary screen for creating a new user account (Student or Teacher)
/// using Email and Password.
///
/// **How it helps:**
/// It serves as the bridge for multi-step registration:
/// 1. Collects user input (Name, Email, Password, Role).
/// 2. Handles the complex two-part registration process (Firebase Auth + Firestore Profile).
/// 3. Initiates the mandatory email verification step.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  // **Form and Input Controllers:**
  final GlobalKey<FormState> _formKey =
      GlobalKey<
        FormState
      >(); // Key used to trigger validation on the whole form.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  // **State Variables:**
  bool _isLoading = false; // Controls the loading spinner on the button.
  String _selectedRole = UserRoles
      .student; // Stores the role chosen by the user (defaults to 'student').

  /// **Logic: User Registration Handler**
  /// This function orchestrates the entire account creation workflow.
  ///
  /// **What it is doing:**
  /// It executes three critical, sequential steps in an atomic manner:
  /// 1. **Firebase Auth:** Creates the user's login credentials.
  /// 2. **Firestore Profile:** Creates the user's document (including Role and Status, e.g., 'pending' for teachers).
  /// 3. **Email Verification:** Sends the verification link.
  ///
  /// **How it works:**
  /// If any step fails, it catches the error and stops the process, ensuring no half-created accounts remain.
  void _registerUser(BuildContext context) async {
    FocusScope.of(context).unfocus();

    // Step 1: Validate all fields using the form key. Stop if validation fails.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Step 2: Create user credentials in Firebase Authentication.
      final userCredential = await ref
          .read(authRepositoryProvider)
          .registerWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      if (userCredential.user != null) {
        // Step 3: Create the user's profile document in the Firestore database.
        // This process sets the user's role and initial status ('approved' or 'pending').
        await ref
            .read(userRepositoryProvider)
            .registerUserInFireStore(
              userCredential: userCredential,
              name: _nameController.text.trim(),
              role: _selectedRole,
            );

        // Step 4: Send the email verification link to the newly registered user.
        await ref
            .read(authRepositoryProvider)
            .sendEmailVerification(userCredential.user!);
      }

      // Step 5: Registration successful! Redirect to the splash screen.
      if (mounted) {
        // We use context.go to clear the navigation stack.
        // The AppRouterProvider (the router's gatekeeper) will then check the user's state
        // and automatically redirect them to the appropriate screen (/verify-email or /pending-approval).
        // ignore: use_build_context_synchronously
        context.go(AppRoutePaths.splash);
      }
    } catch (e) {
      // Handle failure (e.g., email already in use, weak password).
      if (mounted) {
        // Show error message to the user.
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            // ignore: use_build_context_synchronously
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        // Reset loading state.
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // **Cleanup:** Dispose all controllers to prevent memory leaks.
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.registerTitle),
        centerTitle: true,
      ),
      // **Responsive Wrapper:** Centers the registration form nicely for web/desktop.
      body: ResponsiveAuthLayout(
        // The core registration form is managed in the separate `RegisterForm` widget.
        child: RegisterForm(
          formKey: _formKey, // Passes the key for validation.
          emailController: _emailController,
          passwordController: _passwordController,
          nameController: _nameController,
          isLoading: _isLoading,
          selectedRole: _selectedRole,
          // Callback to update the local state when the role selector is tapped.
          onRoleChanged: (role) => setState(() {
            _selectedRole = role;
          }),
          // Callback to trigger the main registration logic.
          onRegister: () => _registerUser(context),
          // Callback to navigate to the login screen.
          onLogin: () => context.go(AppRoutePaths.login),
        ),
      ),
    );
  }
}

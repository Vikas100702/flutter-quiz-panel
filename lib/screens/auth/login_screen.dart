// lib/screens/auth/login_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/providers/auth_provider.dart';
import 'package:quiz_panel/utils/app_routes.dart';
import 'package:quiz_panel/widgets/auth/login_form.dart';
import 'package:quiz_panel/widgets/buttons/app_button.dart';
import 'package:quiz_panel/widgets/layout/responsive_layout.dart';

/// **Why we used this Widget (LoginScreen):**
/// This is the primary entry point for existing users to sign in using their Email and Password.
///
/// **How it helps:**
/// It provides the core UI for credential collection and initiates the
/// authentication process with Firebase via the `AuthRepository`.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // **Data Controllers:** Used to capture the text input by the user.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // **State Variable:** Controls the loading spinner on the button.
  bool _isLoading = false;

  // --- Logic: Email/Password Login ---

  /// **What is this function doing?**
  /// It attempts to sign the user into Firebase and handles the success or failure states.
  ///
  /// **How it works:**
  /// 1. **Loading State:** Hides the keyboard and sets `_isLoading = true` to show a spinner.
  /// 2. **API Call:** Reads the `authRepositoryProvider` and calls `signInWithEmailAndPassword`.
  /// 3. **Success:** If successful, the function exits. The application's `AppRouterProvider`
  ///    automatically detects the new authenticated user and redirects them to their dashboard.
  /// 4. **Failure:** If it catches an error (e.g., wrong password, network issue), it shows a red
  ///    `SnackBar` with the error message and resets the loading state.
  void _loginUser(BuildContext context) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
    });

    try {
      await ref
          .read(authRepositoryProvider)
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
      // The application's GoRouter handles the redirection after successful login.
    } catch (e) {
      if (mounted) {
        // Show error message if login fails (e.g., wrong credentials, network issue).
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            // ignore: use_build_context_synchronously
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      // Reset loading state on failure.
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // **Cleanup:** Always dispose of controllers to prevent memory leaks.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // **Platform Check:** Conditionally shows the "Login with Phone" option on Android only.
    // This is because phone authentication logic is simpler and often preferred on mobile platforms.
    final isAndroid =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

    return Scaffold(
      appBar: AppBar(title: const Text('Pro Olympiad'), centerTitle: true),
      // **Responsive Wrapper (ResponsiveAuthLayout):**
      // This widget centers the content and constrains its maximum width for a good desktop/web view.
      body: ResponsiveAuthLayout(
        // The LoginForm widget itself is now scrollable (SingleChildScrollView is inside LoginForm).
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            // **Why mainAxisSize.min?** Allows the column to shrink to fit its content,
            // which helps the content center correctly within the parent layout.
            mainAxisSize: MainAxisSize.min,
            children: [
              // **Flexible Widget:** Allows the inner LoginForm (which has scrolling content)
              // to correctly occupy the vertical space provided by the parent Column.
              Flexible(
                child: LoginForm(
                  emailController: _emailController,
                  passwordController: _passwordController,
                  isLoading: _isLoading,
                  onLogin: () => _loginUser(context),
                  // Button to navigate to the Registration Screen.
                  onRegister: () => context.push(AppRoutePaths.register),
                ),
              ),

              // **Conditional Phone Login Button:**
              if (isAndroid) ...[
                const SizedBox(height: 16),
                AppButton(
                  text: 'Login with Phone',
                  onPressed: _isLoading
                      ? null
                      : () {
                          context.push(
                            AppRoutePaths.phoneLogin,
                          ); // Navigate to phone login screen.
                        },
                  type: AppButtonType.outline,
                  icon: Icons.phone,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

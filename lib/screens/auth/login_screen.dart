// lib/screens/auth/login_screen.dart
import 'package:flutter/foundation.dart'; // <-- 1. YEH IMPORT ZAROORI HAI
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/providers/auth_provider.dart';
import 'package:quiz_panel/repositories/user_repository.dart';
import 'package:quiz_panel/utils/app_routes.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/widgets/auth/login_form.dart';
import 'package:quiz_panel/widgets/buttons/app_button.dart'; // <-- 2. YEH IMPORT ZAROORI HAI
import 'package:quiz_panel/widgets/layout/responsive_layout.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // --- Email/Password Login ---
  void _loginUser(BuildContext context) async {
    FocusScope.of(context).unfocus();
    setState(() { _isLoading = true; });

    try {
      await ref.read(authRepositoryProvider).signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Router baaki kaam karega
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      setState(() { _isLoading = false; });
    }
  }

  // --- Google Sign-In Logic (Abhi commented hai) ---
  void _signInWithGoogle(BuildContext context) async {
    // ... (logic) ...
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // --- 3. YEH LOGIC PLATFORM CHECK KARTA HAI ---
    final isAndroid = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

    return Scaffold(
      appBar: AppBar(
        title: const Text('QuizMaster Pro'),
        centerTitle: true,
      ),
      body: ResponsiveAuthLayout(
        // --- 4. FORM KO COLUMN MEIN WRAP KAREIN ---
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Purana Login Form
            LoginForm(
              emailController: _emailController,
              passwordController: _passwordController,
              isLoading: _isLoading,
              onLogin: () => _loginUser(context),
              onRegister: () => context.push(AppRoutePaths.register),
              // onGoogleSignIn: () => _signInWithGoogle(context),
            ),

            // --- 5. YEH NAYA ANDROID-ONLY BUTTON HAI ---
            if (isAndroid) ...[
              const SizedBox(height: 16),
              AppButton(
                text: 'Login with Phone',
                onPressed: _isLoading
                    ? null
                    : () {
                  // Phone login route par navigate karein
                  context.push(AppRoutePaths.phoneLogin);
                },
                type: AppButtonType.outline,
                icon: Icons.phone,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
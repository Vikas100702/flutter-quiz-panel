import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/providers/auth_provider.dart';
import 'package:quiz_panel/repositories/user_repository.dart';
import 'package:quiz_panel/utils/app_routes.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/widgets/auth/login_form.dart';
import 'package:quiz_panel/widgets/buttons/app_button.dart';
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
    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authRepositoryProvider).signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Router baaki kaam karega
    } catch (e) {
      if (mounted) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            // ignore: use_build_context_synchronously
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAndroid = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pro Olympiad'),
        centerTitle: true,
      ),
      body: ResponsiveAuthLayout(
        // --- SingleChildScrollView YAHAN SE HATA DIYA GAYA HAI ---
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Yeh line add ki
            children: [
              // LoginForm ab khud scrollable hai
              Flexible( // Flexible add kiya taaki Column expand na ho
                child: LoginForm(
                  emailController: _emailController,
                  passwordController: _passwordController,
                  isLoading: _isLoading,
                  onLogin: () => _loginUser(context),
                  onRegister: () => context.push(AppRoutePaths.register),
                ),
              ),

              if (isAndroid) ...[
                const SizedBox(height: 16),
                AppButton(
                  text: 'Login with Phone',
                  onPressed: _isLoading
                      ? null
                      : () {
                    context.push(AppRoutePaths.phoneLogin);
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
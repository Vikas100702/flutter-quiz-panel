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

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Add form key
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool _isLoading = false;
  String _selectedRole = UserRoles.student;

  void _registerUser(BuildContext context) async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) { // Validate the form
      return;
    }

    setState(() { _isLoading = true; });

    try {
      // 1. Create user in Firebase Auth
      final userCredential = await ref
          .read(authRepositoryProvider)
          .registerWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        // 2. Create user document in Firestore
        await ref
            .read(userRepositoryProvider)
            .registerUserInFireStore(
          userCredential: userCredential,
          name: _nameController.text.trim(),
          role: _selectedRole,
        );

        // --- NEW: Send verification email ---
        await ref
            .read(authRepositoryProvider)
            .sendEmailVerification(userCredential.user!);
        // --- END NEW ---
      }

      if(mounted) {
        // ignore: use_build_context_synchronously
        context.go(AppRoutePaths.splash);
      }
      // राउटर बाकी काम खुद करेगा (यूजर को /verify-email पर रीडायरेक्ट करेगा)
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
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  void dispose() {
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
      body: ResponsiveAuthLayout(
        child: RegisterForm(
          formKey: _formKey, // Pass form key
          emailController: _emailController,
          passwordController: _passwordController,
          nameController: _nameController,
          isLoading: _isLoading,
          selectedRole: _selectedRole,
          onRoleChanged: (role) => setState(() { _selectedRole = role; }),
          onRegister: () => _registerUser(context),
          onLogin: () => context.go(AppRoutePaths.login),
        ),
      ),
    );
  }
}

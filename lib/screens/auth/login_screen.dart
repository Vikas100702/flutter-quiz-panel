// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/providers/auth_provider.dart';
import 'package:quiz_panel/repositories/user_repository.dart'; // --- NEW ---
import 'package:quiz_panel/utils/app_routes.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/widgets/auth/login_form.dart';
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

  // --- UPDATED: Email/Password Login ---
  void _loginUser(BuildContext context) async {
    // किसी भी खुले कीबोर्ड को बंद करें
    FocusScope.of(context).unfocus();

    setState(() { _isLoading = true; });

    try {
      await ref.read(authRepositoryProvider).signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // राऊटर बाकी काम खुद करेगा
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      // केवल एरर होने पर ही isLoading को false पर सेट करें
      setState(() { _isLoading = false; });
    }
    // सफल होने पर, स्क्रीन बदल जाएगी, इसलिए setState() की आवश्यकता नहीं है
  }

  // --- NEW: Google Sign-In Logic ---
  void _signInWithGoogle(BuildContext context) async {
    FocusScope.of(context).unfocus();
    setState(() { _isLoading = true; });

    try {
      // 1. Google से साइन इन करने का प्रयास करें
      /*final userCredential =
      await ref.read(authRepositoryProvider).signInWithGoogle();*/

      // 2. Firestore में उपयोगकर्ता डेटा बनाएँ/अपडेट करें
      /*await ref
          .read(userRepositoryProvider)
          .registerGoogleUserInFirestore(userCredential: userCredential);*/

      // राऊटर बाकी काम खुद करेगा
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
  // --- END NEW ---

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QuizMaster Pro'),
        centerTitle: true,
      ),
      body: ResponsiveAuthLayout(
        child: LoginForm(
          emailController: _emailController,
          passwordController: _passwordController,
          isLoading: _isLoading,
          onLogin: () => _loginUser(context),
          onRegister: () => context.push(AppRoutePaths.register),
          // onGoogleSignIn: () => _signInWithGoogle(context),
        ),
      ),
    );
  }
}
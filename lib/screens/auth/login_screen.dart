/*
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

  // --- 2. Google Sign-In Logic ko implement karein ---
  void _signInWithGoogle(BuildContext context) async {
    setState(() { _isLoading = true; });
    try {
      // 1. AuthRepository se sign in karein
      final userCredential = await ref.read(authRepositoryProvider).signInWithGoogle();

      if (userCredential.user != null) {
        // 2. UserRepository se Firestore mein profile create/update karein
        // Yeh function naye users ko 'student' banata hai
        await ref.read(userRepositoryProvider).registerGoogleUserInFirestore(
          userCredential: userCredential,
        );
      }
      // Sign in safal hone par, router provider aapko dashboard par bhej dega.
      // Humein yahaan `isLoading = false` set karne ki zaroorat nahi hai
      // kyunki screen navigate ho jayegi.

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      setState(() { _isLoading = false; }); // Error par loading state hatayein
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
    // --- 3. YEH LOGIC PLATFORM CHECK KARTA HAI ---
    final isAndroid = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

    return Scaffold(
      appBar: AppBar(
        title: const Text('QuizMaster Pro'),
        centerTitle: true,
      ),
      body: ResponsiveAuthLayout(
        // --- 4. FORM KO COLUMN MEIN WRAP KAREIN ---
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            // mainAxisSize: MainAxisSize.min,
            children: [
              // Purana Login Form
              LoginForm(
                emailController: _emailController,
                passwordController: _passwordController,
                isLoading: _isLoading,
                onLogin: () => _loginUser(context),
                onRegister: () => context.push(AppRoutePaths.register),
                onGoogleSignIn: () => _signInWithGoogle(context),
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
      ),
    );
  }
}*/

/*
// lib/screens/auth/login_screen.dart
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- Google Sign-In Logic ---
  void _signInWithGoogle(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    try {
      // 1. AuthRepository se sign in karein
      final userCredential =
      await ref.read(authRepositoryProvider).signInWithGoogle();

      if (userCredential.user != null) {
        // 2. UserRepository se Firestore mein profile create/update karein
        await ref.read(userRepositoryProvider).registerGoogleUserInFirestore(
          userCredential: userCredential,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
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
        title: const Text('QuizMaster Pro'),
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
                  onGoogleSignIn: () => _signInWithGoogle(context),
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
}*/

// lib/screens/auth/login_screen.dart
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
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
        title: const Text('QuizMaster Pro'),
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
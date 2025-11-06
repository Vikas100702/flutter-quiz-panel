// lib/screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool _isLoading = false;
  String _selectedRole = UserRoles.student;

  // Create a provider for register state
  static final registerStateProvider = StateNotifierProvider<RegisterNotifier, RegisterState>((ref) {
    return RegisterNotifier();
  });

  void _registerUser(BuildContext context) async {
    FocusScope.of(context).unfocus();

    setState(() { _isLoading = true; });

    try {
      final userCredential = await ref
          .read(authRepositoryProvider)
          .registerWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        await ref
            .read(userRepositoryProvider)
            .registerUserInFireStore(
          userCredential: userCredential,
          name: _nameController.text.trim(),
          role: _selectedRole,
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

// State management for register screen
class RegisterState {
  final bool isLoading;
  final String selectedRole;
  final String? error;

  RegisterState({
    this.isLoading = false,
    this.selectedRole = UserRoles.student,
    this.error,
  });

  RegisterState copyWith({
    bool? isLoading,
    String? selectedRole,
    String? error,
  }) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      selectedRole: selectedRole ?? this.selectedRole,
      error: error ?? this.error,
    );
  }
}

class RegisterNotifier extends StateNotifier<RegisterState> {
  RegisterNotifier() : super(RegisterState());

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setRole(String role) {
    state = state.copyWith(selectedRole: role);
  }

  void setError(String error) {
    state = state.copyWith(error: error);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
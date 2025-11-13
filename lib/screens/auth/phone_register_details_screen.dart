// lib/screens/auth/phone_register_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/providers/auth_provider.dart';
import 'package:quiz_panel/repositories/user_repository.dart';
import 'package:quiz_panel/utils/app_routes.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/utils/constants.dart';
import 'package:quiz_panel/widgets/auth/role_selector.dart';
import 'package:quiz_panel/widgets/buttons/app_button.dart';
import 'package:quiz_panel/widgets/inputs/app_text_field.dart';
import 'package:quiz_panel/widgets/layout/responsive_layout.dart';

class PhoneRegisterDetailsScreen extends ConsumerStatefulWidget {
  const PhoneRegisterDetailsScreen({super.key});

  @override
  ConsumerState<PhoneRegisterDetailsScreen> createState() =>
      _PhoneRegisterDetailsScreenState();
}

class _PhoneRegisterDetailsScreenState
    extends ConsumerState<PhoneRegisterDetailsScreen> {
  final _nameController = TextEditingController();
  String _selectedRole = UserRoles.student;
  bool _isLoading = false;

  Future<void> _completeRegistration() async {
    FocusScope.of(context).unfocus();
    final authUser = ref.read(authStateProvider).value;

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name')),
      );
      return;
    }

    if (authUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication error. Please login again.')),
      );
      context.go(AppRoutePaths.login);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Naya method call karein
      await ref.read(userRepositoryProvider).registerPhoneUserInFirestore(
        user: authUser,
        name: _nameController.text.trim(),
        role: _selectedRole,
      );

      // Registration poora hua!
      // Router ab user ko 'pending_approval' screen par bhej dega.
      if (mounted) {
        context.go(AppRoutePaths.splash);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Your Profile')),
      body: ResponsiveAuthLayout(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_add, size: 64, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                'One Last Step',
                style: AppTextStyles.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Please provide your name and select your role',
                style: AppTextStyles.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              AppTextField(
                controller: _nameController,
                label: AppStrings.nameLabel,
                prefixIcon: Icons.person_rounded,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 24),
              RoleSelector(
                selectedRole: _selectedRole,
                onRoleChanged: (role) => setState(() {
                  _selectedRole = role;
                }),
              ),
              const SizedBox(height: 32),
              AppButton(
                text: 'Complete Registration',
                onPressed: _isLoading ? null : _completeRegistration,
                isLoading: _isLoading,
                type: AppButtonType.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
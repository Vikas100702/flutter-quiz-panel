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

/// **Why we used this Widget (PhoneRegisterDetailsScreen):**
/// This screen is necessary for users who signed up using **Phone Authentication**.
/// Unlike Email/Password or Google Sign-in, phone authentication only gives us the phone number and UID.
/// We need this screen as an intermediate step to collect essential profile data: Name and Role (Student/Teacher).
///
/// **How it helps:**
/// It ensures all users, regardless of sign-up method, have a complete profile before being routed
/// to the dashboard or approval queue.
class PhoneRegisterDetailsScreen extends ConsumerStatefulWidget {
  const PhoneRegisterDetailsScreen({super.key});

  @override
  ConsumerState<PhoneRegisterDetailsScreen> createState() =>
      _PhoneRegisterDetailsScreenState();
}

class _PhoneRegisterDetailsScreenState
    extends ConsumerState<PhoneRegisterDetailsScreen> {
  // **State Variables:**
  final _nameController = TextEditingController();
  // Default role is set to Student, but user can switch it.
  String _selectedRole = UserRoles.student;
  bool _isLoading = false;

  // --- Logic: Complete Registration and Save to Firestore ---

  /// **What is this function doing?**
  /// It saves the user's collected Name and selected Role to the Firestore database
  /// and finalizes the registration process.
  ///
  /// **How it works:**
  /// 1. **Validation:** Checks if the name field is filled and if the Firebase Auth user object exists.
  /// 2. **Loading:** Sets `_isLoading = true`.
  /// 3. **API Call:** Calls `userRepositoryProvider.registerPhoneUserInFirestore`. This method creates the
  ///    `UserModel` and the role-specific profile (student or teacher) in separate database collections.
  /// 4. **Redirection:** On success, it navigates to the root path (`/splash`). The `AppRouterProvider`
  ///    then takes over and routes the user based on their newly saved role/status (e.g., to the `pending_approval` screen if they chose 'teacher').
  Future<void> _completeRegistration() async {
    FocusScope.of(context).unfocus();
    // Get the authenticated Firebase User (must be signed in via OTP already).
    final authUser = ref.read(authStateProvider).value;

    // Input Validation: Name is mandatory.
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name')),
      );
      return;
    }

    // Safety Check: If the user somehow signed out, redirect them.
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
      // Save the Name and Role to Firestore for the currently logged-in user.
      await ref.read(userRepositoryProvider).registerPhoneUserInFirestore(
        user: authUser,
        name: _nameController.text.trim(),
        role: _selectedRole,
      );

      // Registration successful! Trigger the router to determine the final screen.
      if (mounted) {
        context.go(AppRoutePaths.splash);
      }
    } catch (e) {
      // Handle database errors (e.g., connection issue).
      setState(() {
        _isLoading = false;
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Your Profile')),
      // **Responsive Layout:** Centers the content nicely on the screen.
      body: ResponsiveAuthLayout(
        // **Why SingleChildScrollView?** Ensures the content remains visible and scrollable
        // when the keyboard pops up on mobile devices.
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Header Icon and Text
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

              // Name Input Field
              AppTextField(
                controller: _nameController,
                label: AppStrings.nameLabel,
                prefixIcon: Icons.person_rounded,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 24),

              // Role Selection Widget
              // Uses `RoleSelector` (a custom widget) to let the user choose Student or Teacher.
              RoleSelector(
                selectedRole: _selectedRole,
                onRoleChanged: (role) => setState(() {
                  _selectedRole = role; // Update local state when role changes.
                }),
              ),
              const SizedBox(height: 32),

              // Final Action Button
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
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/providers/auth_provider.dart';
import 'package:quiz_panel/repositories/user_repository.dart';
import 'package:quiz_panel/utils/app_routes.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/utils/constants.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  // State to manage loading and selected role
  bool _isLoading = false;

  // Default selected role is 'student'
  String _selectedRole = UserRoles.student;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // The logic for handling registration
  void _registerUser(BuildContext context) async {
    // 1. Hide keyboard
    FocusScope.of(context).unfocus();

    // 2. Start loading
    setState(() {
      _isLoading = true;
    });

    // 3. CHECK FOR NETWORK FIRST
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.noInternet),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // If network is OK, proceed with registration
    try {
      // Call the AuthRepository to CREATE the user in Auth
      final userCredential = await ref
          .read(authRepositoryProvider)
          .registerWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      // If successful, call the UserRepository to SAVE the user data in Firestore
      if (userCredential.user != null) {
        await ref
            .read(userRepositoryProvider)
            .registerUserInFireStore(
              userCredential: userCredential,
              name: _nameController.text.trim(),
              role: _selectedRole,
            );
      }
      // Success: Don't stop loading. The redirect (AuthWrapper) will handle it.
      // It will see the new user, fetch their data, and send them
      // to the 'ApprovalPendingScreen' or 'StudentDashboard'.
    } catch (e) {
      // Handle any errors (e.g., email-in-use, weak-password)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );

        setState(() {
          _isLoading = false;
        }); // Stop loading
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.registerTitle),
        centerTitle: true,
      ),
      // Use LayoutBuilder for responsive UI
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isDesktop = constraints.maxWidth > 600;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450, minWidth: 300),
              child: Card(
                elevation: isDesktop ? 8.0 : 0.0,
                margin: isDesktop
                    ? const EdgeInsets.all(24.0)
                    : EdgeInsets.zero,
                shape: isDesktop
                    ? RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      )
                    : null,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 40.0 : 20.0,
                    vertical: isDesktop ? 50.0 : 20.0,
                  ),
                  // We use SingleChildScrollView to prevent overflow
                  // when the keyboard appears on small screens.
                  child: SingleChildScrollView(
                    child: _buildRegisterForm(context),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // This widget builds the actual form
  Widget _buildRegisterForm(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // --- Name Field ---
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: AppStrings.nameLabel,
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
          keyboardType: TextInputType.name,
        ),
        const SizedBox(height: 20),

        // --- Email Field ---
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: AppStrings.emailLabel,
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),

        // --- Password Field ---
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: AppStrings.passwordLabel,
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.lock),
            helperText: AppStrings.passwordMinLength,
          ),
        ),
        const SizedBox(height: 20),

        // --- Role Selector ---
        Text(AppStrings.iAmA, style: Theme.of(context).textTheme.titleMedium),

        // SegmentedButton for a modern role selector
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(
              value: UserRoles.student,
              label: Text(AppStrings.student),
              icon: Icon(Icons.school),
            ),
            ButtonSegment(
              value: UserRoles.teacher,
              label: Text(AppStrings.teacher),
              icon: Icon(Icons.history_edu),
            ),
          ],
          selected: {_selectedRole}, // The currently selected role
          onSelectionChanged: (Set<String> newSelection) {
            setState(() {
              // Set the new role
              _selectedRole = newSelection.first;
            });
          },
        ),
        const SizedBox(height: 30),

        // --- Register Button ---
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: _isLoading ? null : () => _registerUser(context),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(AppStrings.registerButton),
        ),
        const SizedBox(height: 20),

        // --- Navigation to Login ---
        TextButton(
          onPressed: _isLoading
              ? null
              : () {
                  // Use GoRouter to navigate back to login
                  context.go(AppRoutePaths.login);
                },
          child: RichText(
            text: TextSpan(
              text: AppStrings.haveAccount,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 16,
              ),
              children: [
                TextSpan(
                  text: AppStrings.loginNow,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

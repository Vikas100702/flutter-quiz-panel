// lib/screens/profile/manage_profile_screen.dart

// Why we used this file:
// This screen provides a dedicated interface for a logged-in user to view and
// update their non-critical profile details (Name and Phone Number).
//
// How it's helpful:
// It centralizes user profile management, ensuring that profile updates are
// correctly saved to both the main 'users' collection and the role-specific
// profile collections (e.g., 'student_profiles') via the UserRepository.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/providers/user_data_provider.dart';
import 'package:quiz_panel/repositories/user_repository.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/widgets/buttons/app_button.dart';
import 'package:quiz_panel/widgets/inputs/app_text_field.dart';

class ManageProfileScreen extends ConsumerStatefulWidget {
  const ManageProfileScreen({super.key});

  @override
  ConsumerState<ManageProfileScreen> createState() =>
      _ManageProfileScreenState();
}

class _ManageProfileScreenState extends ConsumerState<ManageProfileScreen> {
  // What it is doing: Controllers capture the user's input for Name and Phone Number.
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  // What it is doing: Tracks the asynchronous state of the 'Save Changes' button.
  bool _isLoading = false;

  @override
  // What it is doing: Initializes the input fields with the user's existing data upon screen load.
  void initState() {
    super.initState();
    // How it is working: Reads the synchronously available user data from Riverpod's cache.
    final user = ref.read(userDataProvider).value;
    if (user != null) {
      // How it's helpful: Pre-fills the fields, giving the user a starting point for editing.
      _nameController.text = user.displayName;
      _phoneController.text =
          user.phoneNumber ?? ''; // Handles null phone number safely.
    }
  }

  @override
  // What it is doing: Cleans up the TextEditingController resources.
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // What it is doing: Orchestrates the profile update process with the database.
  Future<void> _updateProfile() async {
    // Step 1: Set loading state to disable the button.
    setState(() {
      _isLoading = true;
    });

    final user = ref.read(userDataProvider).value;
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Step 2: Call the repository to save changes to Firestore.
      // How it is working: The UserRepository handles updating both the main 'users'
      // document and the associated profile document (e.g., 'student_profiles').
      await ref
          .read(userRepositoryProvider)
          .updateUserData(
            user.uid,
            displayName: _nameController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
          );

      // Step 3: Invalidate the provider.
      // How it's helpful: Forces Riverpod to discard the old user data and refetch the
      // new data from the database. This instantly updates the profile photo/name everywhere.
      ref.invalidate(userDataProvider);

      if (mounted) {
        // Step 4: Show success feedback.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Step 4 (Error): Show failure feedback.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      // Step 5: Always reset loading state after the network call is complete.
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  // What it is doing: Builds the responsive UI for profile management.
  Widget build(BuildContext context) {
    // How it is working: Watches the live user data stream from the provider.
    final userData = ref.watch(userDataProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Profile')),
      // How it's helpful: Uses the '.when' pattern for robust asynchronous state handling.
      body: userData.when(
        // Renders the form if data is available.
        data: (user) {
          if (user == null) {
            return const Center(child: Text('User not found.'));
          }
          return Center(
            // Constrains the width for good desktop/web presentation.
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Editable Name Field
                        AppTextField(
                          controller: _nameController,
                          label: AppStrings.nameLabel,
                          prefixIcon: Icons.person,
                        ),
                        const SizedBox(height: 20),
                        // Email (Read-only for security, user must use the Change Password flow to change email).
                        AppTextField(
                          controller: TextEditingController(text: user.email),
                          label: AppStrings.emailLabel,
                          prefixIcon: Icons.email,
                          enabled: false,
                        ),
                        const SizedBox(height: 20),
                        // Editable Phone Number Field
                        AppTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          prefixIcon: Icons.phone,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 32),
                        // Save Button (disabled when loading)
                        AppButton(
                          text: AppStrings.saveChangesButton,
                          onPressed: _isLoading ? null : _updateProfile,
                          isLoading: _isLoading,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        // Renders a loading spinner while data is being fetched.
        loading: () => const Center(child: CircularProgressIndicator()),
        // Renders an error message if data fetching fails.
        error: (e, s) => Center(child: Text('Error: ${e.toString()}')),
      ),
    );
  }
}

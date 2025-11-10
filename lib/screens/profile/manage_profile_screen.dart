// lib/screens/profile/manage_profile_screen.dart
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
  ConsumerState<ManageProfileScreen> createState() => _ManageProfileScreenState();
}

class _ManageProfileScreenState extends ConsumerState<ManageProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Jaise hi screen load ho, user ka current data controllers mein daal dein
    final user = ref.read(userDataProvider).value;
    if (user != null) {
      _nameController.text = user.displayName;
      _phoneController.text = user.phoneNumber ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
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
      // Naya function call karein (yeh hum next step mein banayenge)
      await ref.read(userRepositoryProvider).updateUserData(
        user.uid,
        displayName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );

      // Provider ko refresh karein taaki data update ho
      ref.invalidate(userDataProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(userDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Profile'),
      ),
      body: userData.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('User not found.'));
          }
          return Center(
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
                        AppTextField(
                          controller: _nameController,
                          label: AppStrings.nameLabel,
                          prefixIcon: Icons.person,
                        ),
                        const SizedBox(height: 20),
                        // Email (Read-only)
                        AppTextField(
                          controller: TextEditingController(text: user.email),
                          label: AppStrings.emailLabel,
                          prefixIcon: Icons.email,
                          enabled: false,
                        ),
                        const SizedBox(height: 20),
                        AppTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          prefixIcon: Icons.phone,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 32),
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: ${e.toString()}')),
      ),
    );
  }
}
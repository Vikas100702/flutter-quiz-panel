// lib/screens/super_admin/edit_user_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/models/user_model.dart';
import 'package:quiz_panel/repositories/admin_repository.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/utils/constants.dart';
import 'package:quiz_panel/widgets/buttons/app_button.dart';

class EditUserScreen extends ConsumerStatefulWidget {
  final UserModel user;
  const EditUserScreen({super.key, required this.user});

  @override
  ConsumerState<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends ConsumerState<EditUserScreen> {
  late String _selectedRole;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Shuruaati role ko set karein
    _selectedRole = widget.user.role;
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Repository ko call karein
      await ref.read(adminRepositoryProvider).updateUserRole(
        uid: widget.user.uid,
        newRole: _selectedRole,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.roleUpdatedSuccess),
            backgroundColor: AppColors.success,
          ),
        );
        // Safalta ke baad pichhli screen par waapas jaayein
        context.pop();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.editUserRoleTitle),
        backgroundColor: AppColors.error,
      ),
      body: Center(
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
                    // User ki jaankari
                    Text(
                      widget.user.displayName,
                      style: AppTextStyles.displaySmall,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      widget.user.email,
                      style: AppTextStyles.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const Divider(height: 32),

                    // Role selection
                    Text(
                      'User Role',
                      style: AppTextStyles.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    // Dropdown menu
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      items: const [
                        // Sirf Teacher aur Admin ke beech switch karne ka option
                        DropdownMenuItem(
                          value: UserRoles.teacher,
                          child: Text('Teacher'),
                        ),
                        DropdownMenuItem(
                          value: UserRoles.admin,
                          child: Text('Admin'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedRole = value;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(
                          _selectedRole == UserRoles.admin
                              ? Icons.verified_user
                              : Icons.school,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    AppButton(
                      text: AppStrings.saveChangesButton,
                      onPressed: _isLoading ? null : _saveChanges,
                      isLoading: _isLoading,
                      type: AppButtonType.primary,
                      icon: Icons.save,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
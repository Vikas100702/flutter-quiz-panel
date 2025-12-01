// lib/screens/super_admin/edit_user_screen.dart

/*
/// Why we used this file (EditUserScreen):
/// This screen is an essential part of the **Super Admin's** control panel. It provides the highest level of privilege
/// for modifying user metadata, specifically changing a user's role (e.g., promoting a Teacher to an Admin).

/// What it is doing:
/// 1. **Role Modification:** Allows the Super Admin to select a new role (Admin or Teacher) for a target user.
/// 2. **Authentication:** Displays the target user's basic details (Name, Email) for confirmation.
/// 3. **Database Update:** Triggers a database operation via the `AdminRepository` to persist the role change.

/// How it is working:
/// It is a `ConsumerStatefulWidget` that holds the temporary role selection in its state. On pressing the 'Save' button,
/// it makes an asynchronous call to the `updateUserRole` function. The screen uses a distinct `AppColors.error` theme
/// in the AppBar to visually signal its high-privilege, Super Admin-only status.

/// How it's helpful:
/// It enforces the application's top-level governance structure, ensuring that only users with the `super_admin` role
/// can modify the roles of other key personnel, which is critical for system security and access control.
*/
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/models/user_model.dart';
import 'package:quiz_panel/repositories/admin_repository.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/utils/constants.dart';
import 'package:quiz_panel/widgets/buttons/app_button.dart';

/// Why we used this Widget:
/// This widget requires the full `UserModel` of the user being edited. It is a `ConsumerStatefulWidget`
/// because it needs local mutable state (`_selectedRole`, `_isLoading`) and access to Riverpod providers.
class EditUserScreen extends ConsumerStatefulWidget {
  final UserModel user;
  const EditUserScreen({super.key, required this.user});

  @override
  ConsumerState<EditUserScreen> createState() => _EditUserScreenState();
}

/// What it is doing: Manages the selected role and the loading state of the update process.
class _EditUserScreenState extends ConsumerState<EditUserScreen> {
  late String _selectedRole;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // What it is doing: Initializes the local state variable with the user's current role retrieved from the passed UserModel.
    _selectedRole = widget.user.role;
  }

  // Logic: Save Changes (Update User Role)
  /// What it is doing: Executes the business logic to update the user's role in the database.
  Future<void> _saveChanges() async {
    // What it is doing: Sets the loading state to true to disable the Save button and show a spinner.
    setState(() {
      _isLoading = true;
    });

    try {
      // How it is working: Reads the AdminRepository (the database interface) and calls the function to update the user's role in Firestore.
      await ref
          .read(adminRepositoryProvider)
          .updateUserRole(uid: widget.user.uid, newRole: _selectedRole);

      if (mounted) {
        // How it's helpful: Shows a success notification to the Super Admin.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.roleUpdatedSuccess),
            backgroundColor: AppColors.success,
          ),
        );
        // What it is doing: Navigates back to the previous screen (User Management List) upon successful update.
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        // What it is doing: Displays a red error message if the database operation fails (e.g., network error, permission issue).
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        // How it's helpful: Resets the loading state, re-enabling the button whether the operation succeeded or failed.
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  /// What it is doing: Builds the centered, responsive form for editing the user role.
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.editUserRoleTitle),
        // Why we used AppColors.error: To visually distinguish this screen as a 'Super Admin' exclusive, high-privilege area.
        backgroundColor: AppColors.error,
      ),
      body: Center(
        child: ConstrainedBox(
          // How it's helpful: Limits the width of the form to a maximum of 600 pixels for optimal readability on large screens (e.g., web).
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  // How it's helpful: Ensures the column only takes the necessary vertical space, keeping the content centered.
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // User information header
                    // What it is doing: Displays the user's name being edited.
                    Text(
                      widget.user.displayName,
                      style: AppTextStyles.displaySmall,
                      textAlign: TextAlign.center,
                    ),
                    // What it is doing: Displays the user's email address (read-only context).
                    Text(
                      widget.user.email,
                      style: AppTextStyles.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const Divider(height: 32),

                    // Role selection section
                    Text('User Role', style: AppTextStyles.titleLarge),
                    const SizedBox(height: 16),
                    // Dropdown menu for role change
                    DropdownButtonFormField<String>(
                      // What it is doing: Sets the initial selection to the user's current role.
                      initialValue: _selectedRole,
                      items: const [
                        // Why we only show these two options: Super Admin typically only promotes/demotes between Teacher and Admin.
                        DropdownMenuItem(
                          value: UserRoles.teacher,
                          child: Text('Teacher'),
                        ),
                        DropdownMenuItem(
                          value: UserRoles.admin,
                          child: Text('Admin'),
                        ),
                      ],
                      // How it is working: Updates the local state variable (`_selectedRole`) whenever a new role is selected.
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
                        // How it's helpful: Dynamically changes the icon based on the currently selected role for visual context.
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
                      // What it is doing: Calls the `_saveChanges` function only if not currently loading.
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

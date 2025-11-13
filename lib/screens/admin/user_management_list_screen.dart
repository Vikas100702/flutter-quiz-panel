// lib/screens/admin/user_management_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/models/user_model.dart';
import 'package:quiz_panel/providers/admin_provider.dart';
import 'package:quiz_panel/providers/user_data_provider.dart';
import 'package:quiz_panel/repositories/admin_repository.dart';
import 'package:quiz_panel/utils/app_routes.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/utils/constants.dart';

class UserManagementListScreen extends ConsumerWidget {
  final String filter;
  const UserManagementListScreen({super.key, required this.filter});

  String _getTitle() {
    switch (filter) {
      case 'pending':
        return 'Pending Approvals';
      case 'teachers':
        return 'All Teachers';
      case 'students':
        return 'All Students';
      case 'admins':
        return 'All Admins';
      default:
        return 'User List';
    }
  }

  AsyncValue<List<UserModel>> _getProvider(WidgetRef ref) {
    switch (filter) {
      case 'pending':
        return ref.watch(pendingTeachersProvider);
      case 'teachers':
        return ref.watch(allTeachersProvider);
      case 'students':
        return ref.watch(allStudentsProvider);
      case 'admins':
        return ref.watch(allAdminsProvider);
      default:
      // Fallback to pending, though this shouldn't be reached
        return ref.watch(pendingTeachersProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = _getProvider(ref);
    final title = _getTitle();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: usersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) {
          // Handle Firestore Index error
          if (e.toString().contains('firestore') &&
              e.toString().contains('index')) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '${AppStrings.firestoreIndexError}\n\nError: ${e.toString()}',
                  style: const TextStyle(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return Center(child: Text('Error: ${e.toString()}'));
        },
        data: (users) {
          if (users.isEmpty) {
            return Center(child: Text('No users found for "$title".'));
          }

          // Responsive Grid Layout
          return LayoutBuilder(
            builder: (context, constraints) {
              // Dynamic column count
              int crossAxisCount = 1; // Default for mobile
              if (constraints.maxWidth > 1200) {
                crossAxisCount = 4;
              } else if (constraints.maxWidth > 800) {
                crossAxisCount = 3;
              } else if (constraints.maxWidth > 500) {
                crossAxisCount = 2; // For tablets or large phones
              }

              return GridView.builder(
                padding: const EdgeInsets.all(12.0), // Padding for the grid
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 1.5, // Aspect ratio of cards
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  // Use the extracted card builder
                  return _buildUserCard(context, ref, user);
                },
              );
            },
          );
        },
      ),
    );
  }

  // Helper: User Card (copied from super_admin_dashboard)
  Widget _buildUserCard(BuildContext context, WidgetRef ref, UserModel user) {
    // Get current user's role to determine available actions
    final currentUserRole = ref.watch(userDataProvider).value?.role ?? '';

    return Card(
      margin: const EdgeInsets.all(0), // GridView handles spacing
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween, // Pushes chips to bottom
          children: [
            // Top part: Name, Email, Actions
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Name and Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Expanded(
                      child: Text(
                        user.displayName,
                        style: AppTextStyles.titleLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Action Icons
                    _buildActionIcons(context, ref, user, currentUserRole),
                  ],
                ),
                const SizedBox(height: 4),
                // Row 2: Email
                Text(
                  user.email,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textTertiary),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),

            // Bottom part: Chips
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 16),
                // Row 3: Chips
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: [
                    _buildRoleChip(user.role),
                    _buildStatusChip(user.status, user.isActive),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  // HELPER: Action icons (copied from super_admin_dashboard)
  Widget _buildActionIcons(
      BuildContext context, WidgetRef ref, UserModel user, String currentUserRole) {

    // Super Admin can manage Admins and Teachers
    final bool canBeManaged = (currentUserRole == UserRoles.superAdmin) &&
        (user.role == UserRoles.teacher || user.role == UserRoles.admin);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Approve/Reject (only for 'pending' filter)
        if (filter == 'pending') ...[
          IconButton(
            icon: const Icon(Icons.close),
            color: AppColors.error,
            tooltip: AppStrings.rejectButton,
            onPressed: () => _onRejectPressed(context, ref, user),
          ),
          IconButton(
            icon: const Icon(Icons.check),
            color: AppColors.success,
            tooltip: AppStrings.approveButton,
            onPressed: () => _onApprovePressed(context, ref, user),
          ),
        ]
        // Deactivate/Reactivate (not for 'pending' list, not for super_admins)
        else if (user.role != UserRoles.superAdmin) ...[
          IconButton(
            icon: Icon(
                user.isActive ? Icons.block : Icons.check_circle_outline),
            color: user.isActive ? AppColors.error : AppColors.success,
            tooltip: user.isActive
                ? AppStrings.deactivateUserButton
                : AppStrings.reactivateUserButton,
            onPressed: () =>
                _onDeactivatePressed(context, ref, user, !user.isActive),
          ),
        ],

        // Manage Role (Super Admin only, for teachers/admins)
        if (canBeManaged) ...[
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            color: AppColors.primary,
            tooltip: AppStrings.manageUserButton,
            onPressed: () => _onManagePressed(context, user),
          ),
        ],

        // View Details Button
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios, size: 16),
          color: AppColors.textTertiary,
          tooltip: 'View Details',
          onPressed: () => _onViewPressed(context, user),
        ),
      ],
    );
  }

  // --- Action Handlers (copied from super_admin_dashboard) ---

  void _onViewPressed(BuildContext context, UserModel user) {
    context.pushNamed(
      AppRouteNames.userDetails,
      pathParameters: {'userId': user.uid},
      extra: user,
    );
  }

  void _onApprovePressed(BuildContext context, WidgetRef ref, UserModel user) {
    final currentAdminUid = ref.read(userDataProvider).value?.uid;
    if (currentAdminUid == null) return;
    _showConfirmationDialog(
      context: context,
      title: AppStrings.approveConfirm,
      confirmActionText: AppStrings.approveButton,
      onConfirm: () {
        ref.read(adminRepositoryProvider).approveUser(
          uid: user.uid,
          approvedByUid: currentAdminUid,
        );
      },
    );
  }

  void _onRejectPressed(BuildContext context, WidgetRef ref, UserModel user) {
    _showConfirmationDialog(
      context: context,
      title: AppStrings.rejectConfirm,
      confirmActionText: AppStrings.rejectButton,
      onConfirm: () {
        ref.read(adminRepositoryProvider).rejectUser(uid: user.uid);
      },
    );
  }

  void _onDeactivatePressed(
      BuildContext context, WidgetRef ref, UserModel user, bool newActiveState) {
    final bool isDeactivating = !newActiveState;
    _showConfirmationDialog(
      context: context,
      title: isDeactivating
          ? AppStrings.deactivateConfirm
          : AppStrings.reactivateConfirm,
      confirmActionText: isDeactivating
          ? AppStrings.deactivateUserButton
          : AppStrings.reactivateUserButton,
      onConfirm: () {
        ref
            .read(adminRepositoryProvider)
            .updateUserActiveStatus(uid: user.uid, isActive: newActiveState);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isDeactivating
                ? AppStrings.userDeactivated
                : AppStrings.userReactivated),
            backgroundColor:
            isDeactivating ? AppColors.error : AppColors.success,
          ),
        );
      },
    );
  }

  void _onManagePressed(BuildContext context, UserModel user) {
    context.pushNamed(
      AppRouteNames.editUser,
      pathParameters: {'userId': user.uid},
      extra: user,
    );
  }

  // Helper widget
  Widget _buildRoleChip(String role) {
    Color color;
    IconData icon;
    switch (role) {
      case UserRoles.superAdmin:
        color = AppColors.error;
        icon = Icons.shield;
        break;
      case UserRoles.admin:
        color = AppColors.warning;
        icon = Icons.verified_user;
        break;
      case UserRoles.teacher:
        color = AppColors.primary;
        icon = Icons.school;
        break;
      default:
        color = AppColors.textTertiary;
        icon = Icons.person;
    }
    return Chip(
      avatar: Icon(icon, color: Colors.white, size: 16),
      label: Text(role, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
      labelPadding: const EdgeInsets.symmetric(horizontal: 4.0),
      padding: const EdgeInsets.all(4.0),
    );
  }

  // Helper widget
  Widget _buildStatusChip(String status, bool isActive) {
    if (!isActive) {
      return Chip(
        avatar: const Icon(Icons.block, color: Colors.white, size: 16),
        label: const Text(AppStrings.statusInactive,
            style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.textTertiary,
        labelPadding: const EdgeInsets.symmetric(horizontal: 4.0),
        padding: const EdgeInsets.all(4.0),
      );
    }
    Color color;
    String label;
    IconData icon;
    switch (status) {
      case UserStatus.approved:
        color = AppColors.success;
        label = AppStrings.statusActive;
        icon = Icons.check_circle;
        break;
      case UserStatus.pending:
        color = AppColors.warning;
        label = UserStatus.pending;
        icon = Icons.pending;
        break;
      default:
        color = AppColors.error;
        label = UserStatus.rejected;
        icon = Icons.cancel;
    }
    return Chip(
      avatar: Icon(icon, color: Colors.white, size: 16),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
      labelPadding: const EdgeInsets.symmetric(horizontal: 4.0),
      padding: const EdgeInsets.all(4.0),
    );
  }
}

// Global Helper Dialog
void _showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String confirmActionText,
  required VoidCallback onConfirm,
}) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(title),
        actions: [
          TextButton(
            child: const Text(AppStrings.cancelButton),
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmActionText == AppStrings.rejectButton ||
                  confirmActionText == AppStrings.deactivateUserButton
                  ? AppColors.error
                  : AppColors.success,
            ),
            child: Text(confirmActionText,
                style: const TextStyle(color: Colors.white)),
            onPressed: () {
              onConfirm();
              Navigator.of(dialogContext).pop();
            },
          ),
        ],
      );
    },
  );
}
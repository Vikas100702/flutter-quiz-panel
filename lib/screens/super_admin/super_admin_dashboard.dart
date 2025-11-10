// lib/screens/super_admin/super_admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/models/user_model.dart';
import 'package:quiz_panel/providers/admin_provider.dart';
import 'package:quiz_panel/providers/auth_provider.dart';
import 'package:quiz_panel/providers/user_data_provider.dart';
import 'package:quiz_panel/repositories/admin_repository.dart';
import 'package:quiz_panel/utils/app_routes.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/utils/constants.dart';
// import 'package:quiz_panel/utils/responsive.dart'; // Ab iski zaroorat nahi hai

class SuperAdminDashboard extends ConsumerWidget {
  const SuperAdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.superAdminDashboardTitle),
          backgroundColor: AppColors.error,
          actions: [
            IconButton(
              icon: const Icon(Icons.person_outline),
              tooltip: 'Manage Profile',
              onPressed: () {
                context.push(AppRoutePaths.profile);
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: AppStrings.logoutButton,
              onPressed: () {
                ref.read(authRepositoryProvider).signOut();
              },
            ),
          ],
          bottom: const TabBar(
            tabAlignment: TabAlignment.fill,
            indicatorColor: Colors.white,
            tabs: [
              Tab(
                icon: Icon(Icons.pending_actions),
                text: AppStrings.approvalListTitle,
              ),
              Tab(
                icon: Icon(Icons.people),
                text: AppStrings.allUsersTitle,
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _PendingTeacherList(),
            _AllUsersList(),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------
// WIDGET 1: PENDING TEACHER LIST (Yeh theek hai, isme changes ki zaroorat nahi)
// -----------------------------------------------------------------
class _PendingTeacherList extends ConsumerWidget {
  const _PendingTeacherList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingUsers = ref.watch(pendingTeachersProvider);

    return pendingUsers.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: ${e.toString()}')),
      data: (users) {
        if (users.isEmpty) {
          return const Center(child: Text(AppStrings.noPendingApprovals));
        }
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];

            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(user.displayName),
                subtitle: Text(user.email),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      color: AppColors.error,
                      tooltip: AppStrings.rejectButton,
                      onPressed: () {
                        _showConfirmationDialog(
                          context: context,
                          title: AppStrings.rejectConfirm,
                          confirmActionText: AppStrings.rejectButton,
                          onConfirm: () {
                            ref
                                .read(adminRepositoryProvider)
                                .rejectUser(uid: user.uid);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(AppStrings.userRejected),
                                  backgroundColor: AppColors.error),
                            );
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.check),
                      color: AppColors.success,
                      tooltip: AppStrings.approveButton,
                      onPressed: () {
                        final currentAdminUid =
                            ref.read(userDataProvider).value?.uid;

                        if (currentAdminUid == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                Text('Error: Could not find admin UID.')),
                          );
                          return;
                        }
                        _showConfirmationDialog(
                          context: context,
                          title: AppStrings.approveConfirm,
                          confirmActionText: AppStrings.approveButton,
                          onConfirm: () {
                            ref.read(adminRepositoryProvider).approveUser(
                              uid: user.uid,
                              approvedByUid: currentAdminUid,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(AppStrings.userApproved),
                                  backgroundColor: Colors.green),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// -----------------------------------------------------------------
// WIDGET 2: ALL USERS LIST (MODIFIED FOR MOBILE)
// -----------------------------------------------------------------
class _AllUsersList extends ConsumerWidget {
  const _AllUsersList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allUsers = ref.watch(allUsersProvider);

    return allUsers.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: ${e.toString()}')),
      data: (users) {
        if (users.isEmpty) {
          return const Center(child: Text(AppStrings.noUsersFound));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8.0), // List ke liye padding
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];

            // --- FIX: ListTile ko Custom Card se replace kiya ---
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6.0),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
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
                        _buildActionIcons(context, ref, user),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Row 2: Email
                    Text(
                      user.email,
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textTertiary),
                      overflow: TextOverflow.ellipsis,
                    ),
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
              ),
            );
            // --- END FIX ---
          },
        );
      },
    );
  }

  // --- NEW HELPER: Sirf action icons dikhane ke liye ---
  Widget _buildActionIcons(
      BuildContext context, WidgetRef ref, UserModel user) {
    final bool canBeManaged =
        user.role == UserRoles.teacher || user.role == UserRoles.admin;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Approve/Reject (sirf pending users ke liye)
        if (user.status == UserStatus.pending) ...[
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
        // Deactivate/Reactivate (sirf non-pending aur non-superadmin ke liye)
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

        // Manage Role (sirf teacher/admin ke liye)
        if (canBeManaged) ...[
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            color: AppColors.primary,
            tooltip: AppStrings.manageUserButton,
            onPressed: () => _onManagePressed(context, user),
          ),
        ],

        // View Details Button (Mobile ke liye zaroori)
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios, size: 16),
          color: AppColors.textTertiary,
          tooltip: 'View Details',
          onPressed: () => _onViewPressed(context, user),
        ),
      ],
    );
  }

  // --- Action Handlers (Inhe extract kar liya) ---

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

// -----------------------------------------------------------------
// HELPER DIALOG (Global)
// -----------------------------------------------------------------
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
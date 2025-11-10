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
import 'package:quiz_panel/utils/responsive.dart'; // <-- 1. IMPORT

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
              icon: const Icon(Icons.logout),
              tooltip: AppStrings.logoutButton,
              onPressed: () {
                ref.read(authRepositoryProvider).signOut();
              },
            ),
          ],
          bottom: const TabBar(
            isScrollable: true, // <-- 2. Mobile par scrollable
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
// WIDGET 1: PENDING TEACHER LIST (Unchanged)
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
// WIDGET 2: ALL USERS LIST (MODIFIED)
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
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];

            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(user.displayName),
                subtitle: Text(user.email),
                // --- 3. RESPONSIVE TRAILING ACTIONS ---
                trailing: Responsive.isMobile(context)
                    ? _buildMobileActions(context, ref, user)
                    : _buildDesktopActions(context, ref, user),
              ),
            );
          },
        );
      },
    );
  }

  // --- 4. DESKTOP/TABLET LAYOUT: Buttons in a Row ---
  Widget _buildDesktopActions(
      BuildContext context, WidgetRef ref, UserModel user) {
    final bool canBeManaged =
        user.role == UserRoles.teacher || user.role == UserRoles.admin;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRoleChip(user.role),
        const SizedBox(width: 8),
        _buildStatusChip(user.status, user.isActive),
        const SizedBox(width: 8),

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
          const VerticalDivider(),
          IconButton(
            icon: const Icon(Icons.edit),
            color: AppColors.primary,
            tooltip: AppStrings.manageUserButton,
            onPressed: () => _onManagePressed(context, user),
          ),
        ]
      ],
    );
  }

  // --- 5. MOBILE LAYOUT: PopupMenuButton ---
  Widget _buildMobileActions(
      BuildContext context, WidgetRef ref, UserModel user) {
    final bool canBeManaged =
        user.role == UserRoles.teacher || user.role == UserRoles.admin;

    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'approve') {
          _onApprovePressed(context, ref, user);
        } else if (value == 'reject') {
          _onRejectPressed(context, ref, user);
        } else if (value == 'deactivate') {
          _onDeactivatePressed(context, ref, user, !user.isActive);
        } else if (value == 'manage') {
          _onManagePressed(context, user);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        // Role/Status ko non-clickable display ke liye
        PopupMenuItem(
          enabled: false,
          child: Wrap(
            spacing: 8,
            children: [
              _buildRoleChip(user.role),
              _buildStatusChip(user.status, user.isActive),
            ],
          ),
        ),
        const PopupMenuDivider(),

        // Conditional actions
        if (user.status == UserStatus.pending) ...[
          PopupMenuItem<String>(
            value: 'approve',
            child: const ListTile(
              leading: Icon(Icons.check, color: AppColors.success),
              title: Text(AppStrings.approveButton),
            ),
          ),
          PopupMenuItem<String>(
            value: 'reject',
            child: const ListTile(
              leading: Icon(Icons.close, color: AppColors.error),
              title: Text(AppStrings.rejectButton),
            ),
          ),
        ] else if (user.role != UserRoles.superAdmin) ...[
          PopupMenuItem<String>(
            value: 'deactivate',
            child: ListTile(
              leading: Icon(
                user.isActive ? Icons.block : Icons.check_circle_outline,
                color: user.isActive ? AppColors.error : AppColors.success,
              ),
              title: Text(user.isActive
                  ? AppStrings.deactivateUserButton
                  : AppStrings.reactivateUserButton),
            ),
          ),
        ],
        if (canBeManaged) ...[
          PopupMenuItem<String>(
            value: 'manage',
            child: const ListTile(
              leading: Icon(Icons.edit, color: AppColors.primary),
              title: Text(AppStrings.manageUserButton),
            ),
          ),
        ]
      ],
    );
  }

  // --- 6. Refactored logic ---
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
    );
  }

  // Helper widget
  Widget _buildStatusChip(String status, bool isActive) {
    if (!isActive) {
      return const Chip(
        label: Text(AppStrings.statusInactive,
            style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.textTertiary,
      );
    }
    Color color;
    String label;
    switch (status) {
      case UserStatus.approved:
        color = AppColors.success;
        label = AppStrings.statusActive;
        break;
      case UserStatus.pending:
        color = AppColors.warning;
        label = UserStatus.pending;
        break;
      default:
        color = AppColors.error;
        label = UserStatus.rejected;
    }
    return Chip(
      label: Text(label, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
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
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

/// **Why we used this Widget (UserManagementListScreen):**
/// This is a reusable screen designed to display lists of users based on specific criteria.
/// Instead of creating four separate screens (PendingScreen, TeacherListScreen, StudentListScreen, AdminListScreen),
/// we use this single screen and pass a `filter` argument.
///
/// **How it works:**
/// 1. It receives a `filter` string (e.g., 'pending', 'teachers').
/// 2. Based on the filter, it selects the correct Data Provider (e.g., `pendingTeachersProvider`).
/// 3. It displays the data in a responsive grid layout suitable for both web and mobile.
class UserManagementListScreen extends ConsumerWidget {
  final String filter; // Determines which list of users to fetch.
  const UserManagementListScreen({super.key, required this.filter});

  /// **Logic: dynamic Title**
  /// Sets the App Bar title based on the current filter to give context to the user.
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

  /// **Logic: Dynamic Data Provider**
  /// This is the core switching logic. It tells Riverpod which stream of data to watch.
  ///
  /// **Why use AsyncValue?**
  /// Because these providers return Streams (live data from Firestore), `AsyncValue` automatically
  /// handles the Loading, Error, and Data states for us.
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
        // Fallback safety: default to pending list if an unknown filter is passed.
        return ref.watch(pendingTeachersProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = _getProvider(ref);
    final title = _getTitle();

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      // **State Handling:**
      // We use .when() to cleanly separate the UI for Loading, Error, and Success.
      body: usersAsync.when(
        // 1. Loading State: Show a simple spinner.
        loading: () => const Center(child: CircularProgressIndicator()),

        // 2. Error State: Handle specific Firestore errors.
        error: (e, s) {
          // **Special Handling for Missing Index:**
          // Firestore requires "Composite Indexes" for complex queries (e.g., filtering by Role AND sorting by Name).
          // If the index is missing, the error message contains a URL to create it. We show this helpful message to the dev/admin.
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

        // 3. Data State: The list of users has arrived.
        data: (users) {
          if (users.isEmpty) {
            return Center(child: Text('No users found for "$title".'));
          }

          // **Responsive Design:**
          // We use LayoutBuilder to detect the screen width.
          // - Mobile: 1 column (Vertical list).
          // - Tablet: 2-3 columns.
          // - Desktop: 4 columns.
          return LayoutBuilder(
            builder: (context, constraints) {
              // Dynamic column count calculation
              int crossAxisCount = 1;
              if (constraints.maxWidth > 1200) {
                crossAxisCount = 4;
              } else if (constraints.maxWidth > 800) {
                crossAxisCount = 3;
              } else if (constraints.maxWidth > 500) {
                crossAxisCount = 2;
              }

              return GridView.builder(
                padding: const EdgeInsets.all(12.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio:
                      1.5, // Width is 1.5x Height (Rectangular cards).
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  // Render individual user card
                  return _buildUserCard(context, ref, user);
                },
              );
            },
          );
        },
      ),
    );
  }

  // --- Helper Widget: User Card ---

  /// **What is this?**
  /// Displays a summary of a single user (Name, Email, Role, Status).
  ///
  /// **Why separate it?**
  /// Keeps the main `build` method clean and allows us to reuse this card design elsewhere if needed.
  Widget _buildUserCard(BuildContext context, WidgetRef ref, UserModel user) {
    // We need the logged-in admin's role to decide which buttons they can see.
    // (e.g., Only Super Admin can edit another Admin).
    final currentUserRole = ref.watch(userDataProvider).value?.role ?? '';

    return Card(
      margin: const EdgeInsets.all(0), // Margins handled by GridView spacing.
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment
              .spaceBetween, // Pushes content to top and chips to bottom.
          children: [
            // Top Section: Info & Actions
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Name + Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name (Expanded prevents overflow if name is long)
                    Expanded(
                      child: Text(
                        user.displayName,
                        style: AppTextStyles.titleLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Dynamic Action Buttons (Approve, Ban, Edit, etc.)
                    _buildActionIcons(context, ref, user, currentUserRole),
                  ],
                ),
                const SizedBox(height: 4),
                // Row 2: Email Address
                Text(
                  user.email,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),

            // Bottom Section: Status Chips
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 16),
                // Wrap ensures chips flow to next line if space is tight.
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: [
                    _buildRoleChip(user.role),
                    _buildStatusChip(user.status, user.isActive),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widget: Action Icons ---

  /// **Logic: Context-Aware Actions**
  /// Determines which buttons to show based on:
  /// 1. The list we are viewing (`filter`).
  /// 2. The target user's role.
  /// 3. The logged-in admin's permissions.
  Widget _buildActionIcons(
    BuildContext context,
    WidgetRef ref,
    UserModel user,
    String currentUserRole,
  ) {
    // **Security Rule:**
    // Only a Super Admin can modify (edit role) a Teacher or another Admin.
    final bool canBeManaged =
        (currentUserRole == UserRoles.superAdmin) &&
        (user.role == UserRoles.teacher || user.role == UserRoles.admin);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // **Scenario A: Pending Approvals List**
        // Show Approve (Check) and Reject (Cross) buttons.
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
        // **Scenario B: Active Users List**
        // Show Block/Unblock button (unless the target is a Super Admin).
        else if (user.role != UserRoles.superAdmin) ...[
          IconButton(
            // Toggle icon based on active status.
            icon: Icon(
              user.isActive ? Icons.block : Icons.check_circle_outline,
            ),
            // Toggle color (Red for Ban, Green for Unban).
            color: user.isActive ? AppColors.error : AppColors.success,
            tooltip: user.isActive
                ? AppStrings.deactivateUserButton
                : AppStrings.reactivateUserButton,
            onPressed: () =>
                _onDeactivatePressed(context, ref, user, !user.isActive),
          ),
        ],

        // **Scenario C: Super Admin Editing**
        // Show Edit (Pencil) icon to change user roles.
        if (canBeManaged) ...[
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            color: AppColors.primary,
            tooltip: AppStrings.manageUserButton,
            onPressed: () => _onManagePressed(context, user),
          ),
        ],

        // **Common Action: View Details**
        // Everyone gets an arrow button to see the full profile.
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios, size: 16),
          color: AppColors.textTertiary,
          tooltip: 'View Details',
          onPressed: () => _onViewPressed(context, user),
        ),
      ],
    );
  }

  // --- Action Logic Handlers ---

  /// Navigates to the detailed read-only view of the user.
  void _onViewPressed(BuildContext context, UserModel user) {
    context.pushNamed(
      AppRouteNames.userDetails,
      pathParameters: {'userId': user.uid},
      extra: user, // Pass the user object to avoid re-fetching immediately.
    );
  }

  /// Calls the repository to mark a user as 'approved'.
  void _onApprovePressed(BuildContext context, WidgetRef ref, UserModel user) {
    final currentAdminUid = ref.read(userDataProvider).value?.uid;
    if (currentAdminUid == null) return;

    _showConfirmationDialog(
      context: context,
      title: AppStrings.approveConfirm,
      confirmActionText: AppStrings.approveButton,
      onConfirm: () {
        ref
            .read(adminRepositoryProvider)
            .approveUser(uid: user.uid, approvedByUid: currentAdminUid);
      },
    );
  }

  /// Calls the repository to mark a user as 'rejected'.
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

  /// Toggles the 'isActive' flag in Firestore to temporarily ban/unban a user.
  void _onDeactivatePressed(
    BuildContext context,
    WidgetRef ref,
    UserModel user,
    bool newActiveState,
  ) {
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
            content: Text(
              isDeactivating
                  ? AppStrings.userDeactivated
                  : AppStrings.userReactivated,
            ),
            backgroundColor: isDeactivating
                ? AppColors.error
                : AppColors.success,
          ),
        );
      },
    );
  }

  /// Navigates to the screen where Super Admins can change a user's role.
  void _onManagePressed(BuildContext context, UserModel user) {
    context.pushNamed(
      AppRouteNames.editUser,
      pathParameters: {'userId': user.uid},
      extra: user,
    );
  }

  // --- UI Helper: Role Chip ---
  Widget _buildRoleChip(String role) {
    Color color;
    IconData icon;

    // Assign distinct colors/icons to roles for quick visual identification.
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

  // --- UI Helper: Status Chip ---
  Widget _buildStatusChip(String status, bool isActive) {
    // If account is banned (inactive), override status to show 'Inactive'.
    if (!isActive) {
      return Chip(
        avatar: const Icon(Icons.block, color: Colors.white, size: 16),
        label: const Text(
          AppStrings.statusInactive,
          style: TextStyle(color: Colors.white),
        ),
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

/// **Global Helper: Confirmation Dialog**
/// A generic dialog used for critical actions (Approving, Rejecting, Banning).
/// It asks "Are you sure?" before executing the callback `onConfirm`.
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
              // Use Red for destructive actions, Green for positive ones.
              backgroundColor:
                  confirmActionText == AppStrings.rejectButton ||
                      confirmActionText == AppStrings.deactivateUserButton
                  ? AppColors.error
                  : AppColors.success,
            ),
            child: Text(
              confirmActionText,
              style: const TextStyle(color: Colors.white),
            ),
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

/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_panel/providers/admin_provider.dart';
import 'package:quiz_panel/providers/auth_provider.dart';
import 'package:quiz_panel/providers/user_data_provider.dart';
import 'package:quiz_panel/repositories/admin_repository.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/utils/constants.dart';

class SuperAdminDashboard extends ConsumerWidget {
  const SuperAdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.superAdminDashboardTitle),
        backgroundColor: Colors.red[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: AppStrings.logoutButton,
            onPressed: () {
              ref.read(authRepositoryProvider).signOut();
            },
          ),
        ],
      ),
      // We extracted the list to its own widget
      body: const _PendingTeacherList(),
    );
  }
}

// -----------------------------------------------------------------
// WIDGET 1: PENDING TEACHER LIST
// -----------------------------------------------------------------

// This widget handles fetching and displaying the list
class _PendingTeacherList extends ConsumerWidget {
  const _PendingTeacherList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We watch the "manager" provider
    final pendingUsers = ref.watch(pendingTeachersProvider);

    // Use .when() to handle loading, error, and data states
    return pendingUsers.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: ${e.toString()}')),
      data: (users) {
        // If the list is empty, show a message
        if (users.isEmpty) {
          return const Center(child: Text(AppStrings.noPendingApprovals));
        }

        // If we have data, build the list
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
                    // --- REJECT BUTTON (FIXED) ---
                    IconButton(
                      icon: const Icon(Icons.close),
                      color: Colors.red,
                      tooltip: AppStrings.rejectButton,
                      onPressed: () {
                        // --- THIS IS THE FIX ---
                        // Show confirmation dialog FIRST
                        _showConfirmationDialog(
                          context: context,
                          title: AppStrings.rejectConfirm,
                          confirmActionText: AppStrings.rejectButton,
                          onConfirm: () {
                            // Call the repo function
                            ref.read(adminRepositoryProvider).rejectUser(uid: user.uid);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text(AppStrings.userRejected), backgroundColor: Colors.red),
                            );
                          },
                        );
                        // --- END FIX ---
                      },
                    ),

                    // --- APPROVE BUTTON (FIXED) ---
                    IconButton(
                      icon: const Icon(Icons.check),
                      color: Colors.green,
                      tooltip: AppStrings.approveButton,
                      onPressed: () {
                        // Get the current super_admin's UID
                        final currentAdminUid = ref.read(userDataProvider).value?.uid;

                        if (currentAdminUid == null) {
                          // Failsafe, should not happen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Error: Could not find admin UID.')),
                          );
                          return;
                        }

                        // --- THIS IS THE FIX ---
                        // Show confirmation dialog FIRST
                        _showConfirmationDialog(
                          context: context,
                          title: AppStrings.approveConfirm,
                          confirmActionText: AppStrings.approveButton,
                          onConfirm: () {
                            // Call the repo function
                            ref.read(adminRepositoryProvider).approveUser(
                              uid: user.uid,
                              approvedByUid: currentAdminUid,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text(AppStrings.userApproved), backgroundColor: Colors.green),
                            );
                          },
                        );
                        // --- END FIX ---
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

  // --- HELPER FUNCTION FOR DIALOG ---
  // This function shows the "Are you sure?" pop-up
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
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmActionText == AppStrings.rejectButton
                    ? Colors.red
                    : Colors.green,
              ),
              child: Text(confirmActionText, style: TextStyle(color: Colors.white)),
              onPressed: () {
                onConfirm(); // Run the approve/reject function
                Navigator.of(dialogContext).pop(); // Close dialog
              },
            ),
          ],
        );
      },
    );
  }
}

// -----------------------------------------------------------------
// WIDGET 2: ALL USERS LIST
// -----------------------------------------------------------------
class _AllUsersList extends ConsumerWidget {
  const _AllUsersList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We watch the new "allUsersProvider"
    final allUsers = ref.watch(allUsersProvider);

    return allUsers.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: ${e.toString()}')),
      data: (users) {
        if (users.isEmpty) {
          return const Center(child: Text(AppStrings.noUsersFound)); // Add this string
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
                    // Show Role and Status
                    _buildRoleChip(user.role),
                    const SizedBox(width: 8),
                    _buildStatusChip(user.status),
                    const SizedBox(width: 8),

                    // Show approve/reject buttons ONLY if user is pending
                    if (user.status == UserStatus.pending) ...[
                      // Reject Button
                      IconButton(
                        icon: const Icon(Icons.close),
                        color: Colors.red,
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
                            },
                          );
                        },
                      ),
                      // Approve Button
                      IconButton(
                        icon: const Icon(Icons.check),
                        color: Colors.green,
                        tooltip: AppStrings.approveButton,
                        onPressed: () {
                          final currentAdminUid =
                              ref.read(userDataProvider).value?.uid;
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
                        },
                      ),
                    ]
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Helper widget to show a colored chip for Role
  Widget _buildRoleChip(String role) {
    Color color;
    IconData icon;
    switch (role) {
      case UserRoles.superAdmin:
        color = Colors.red;
        icon = Icons.shield;
        break;
      case UserRoles.admin:
        color = Colors.orange;
        icon = Icons.verified_user;
        break;
      case UserRoles.teacher:
        color = Colors.blue;
        icon = Icons.school;
        break;
      default:
        color = Colors.grey;
        icon = Icons.person;
    }
    return Chip(
      avatar: Icon(icon, color: Colors.white, size: 16),
      label: Text(role, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
    );
  }

  // Helper widget to show a colored chip for Status
  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case UserStatus.approved:
        color = Colors.green;
        break;
      case UserStatus.pending:
        color = Colors.orange;
        break;
      default: // rejected
        color = Colors.red;
    }
    return Chip(
      label: Text(status, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
    );
  }
}

// -----------------------------------------------------------------
// HELPER FUNCTION (Moved here so both widgets can use it)
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
              Navigator.of(dialogContext).pop(); // Close dialog
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmActionText == AppStrings.rejectButton
                  ? Colors.red
                  : Colors.green,
            ),
            child: Text(confirmActionText,
                style: const TextStyle(color: Colors.white)),
            onPressed: () {
              onConfirm(); // Run the approve/reject function
              Navigator.of(dialogContext).pop(); // Close dialog
            },
          ),
        ],
      );
    },
  );
}
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_panel/models/user_model.dart'; // Import UserModel
import 'package:quiz_panel/providers/admin_provider.dart';
import 'package:quiz_panel/providers/auth_provider.dart';
import 'package:quiz_panel/providers/user_data_provider.dart';
import 'package:quiz_panel/repositories/admin_repository.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/utils/constants.dart'; // Import Constants for roles/status

class SuperAdminDashboard extends ConsumerWidget {
  const SuperAdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Wrap the Scaffold in a DefaultTabController
    return DefaultTabController(
      length: 2, // We will have 2 tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.superAdminDashboardTitle),
          backgroundColor: Colors.red[700],
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: AppStrings.logoutButton,
              onPressed: () {
                ref.read(authRepositoryProvider).signOut();
              },
            ),
          ],
          // 2. Add the TabBar to the AppBar
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.pending_actions),
                text: AppStrings.approvalListTitle,
              ),
              Tab(
                icon: Icon(Icons.people),
                text: AppStrings.allUsersTitle, // From app_strings.dart
              ),
            ],
          ),
        ),
        // 3. Use TabBarView to show different content for each tab
        body: const TabBarView(
          children: [
            // Tab 1: Pending Teachers
            _PendingTeacherList(),

            // Tab 2: All Users (New Widget)
            _AllUsersList(),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------
// WIDGET 1: PENDING TEACHER LIST (No changes, this is your existing code)
// -----------------------------------------------------------------
class _PendingTeacherList extends ConsumerWidget {
  const _PendingTeacherList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We watch the "manager" provider
    final pendingUsers = ref.watch(pendingTeachersProvider);

    // Use .when() to handle loading, error, and data states
    return pendingUsers.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: ${e.toString()}')),
      data: (users) {
        // If the list is empty, show a message
        if (users.isEmpty) {
          return const Center(child: Text(AppStrings.noPendingApprovals));
        }

        // If we have data, build the list
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
                    // --- REJECT BUTTON (FIXED) ---
                    IconButton(
                      icon: const Icon(Icons.close),
                      color: Colors.red,
                      tooltip: AppStrings.rejectButton,
                      onPressed: () {
                        // --- THIS IS THE FIX ---
                        // Show confirmation dialog FIRST
                        _showConfirmationDialog(
                          context: context,
                          title: AppStrings.rejectConfirm,
                          confirmActionText: AppStrings.rejectButton,
                          onConfirm: () {
                            // Call the repo function
                            ref
                                .read(adminRepositoryProvider)
                                .rejectUser(uid: user.uid);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(AppStrings.userRejected),
                                  backgroundColor: Colors.red),
                            );
                          },
                        );
                        // --- END FIX ---
                      },
                    ),

                    // --- APPROVE BUTTON (FIXED) ---
                    IconButton(
                      icon: const Icon(Icons.check),
                      color: Colors.green,
                      tooltip: AppStrings.approveButton,
                      onPressed: () {
                        // Get the current super_admin's UID
                        final currentAdminUid =
                            ref.read(userDataProvider).value?.uid;

                        if (currentAdminUid == null) {
                          // Failsafe, should not happen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Error: Could not find admin UID.')),
                          );
                          return;
                        }

                        // --- THIS IS THE FIX ---
                        // Show confirmation dialog FIRST
                        _showConfirmationDialog(
                          context: context,
                          title: AppStrings.approveConfirm,
                          confirmActionText: AppStrings.approveButton,
                          onConfirm: () {
                            // Call the repo function
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
                        // --- END FIX ---
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

// --- HELPER FUNCTION FOR DIALOG ---
// This function shows the "Are you sure?" pop-up
// NOTE: I am moving this function OUTSIDE the class
// so both _PendingTeacherList and _AllUsersList can use it.
}

// -----------------------------------------------------------------
// WIDGET 2: ALL USERS LIST
// -----------------------------------------------------------------
class _AllUsersList extends ConsumerWidget {
  const _AllUsersList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We watch the new "allUsersProvider"
    final allUsers = ref.watch(allUsersProvider);

    return allUsers.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: ${e.toString()}')),
      data: (users) {
        if (users.isEmpty) {
          return const Center(child: Text(AppStrings.noUsersFound)); // From app_strings
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
                    // Show Role and Status
                    _buildRoleChip(user.role),
                    const SizedBox(width: 8),
                    // --- Pass user.isActive to the chip ---
                    _buildStatusChip(user.status, user.isActive),
                    const SizedBox(width: 8),

                    // Show approve/reject buttons ONLY if user is pending
                    if (user.status == UserStatus.pending) ...[
                      // Reject Button
                      IconButton(
                        icon: const Icon(Icons.close),
                        color: Colors.red,
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
                            },
                          );
                        },
                      ),
                      // Approve Button
                      IconButton(
                        icon: const Icon(Icons.check),
                        color: Colors.green,
                        tooltip: AppStrings.approveButton,
                        onPressed: () {
                          final currentAdminUid =
                              ref.read(userDataProvider).value?.uid;
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
                        },
                      ),
                    ]
                    // --- Deactivate/Reactivate Button ---
                    // Show this button ONLY if user is NOT pending
                    // AND is NOT a Super Admin (can't disable self)
                    else if (user.role != UserRoles.superAdmin) ...[
                      IconButton(
                        icon: Icon(user.isActive
                            ? Icons.block // Deactivate icon
                            : Icons.check_circle_outline), // Reactivate icon
                        color: user.isActive ? Colors.red : Colors.green,
                        tooltip: user.isActive
                            ? AppStrings.deactivateUserButton
                            : AppStrings.reactivateUserButton,
                        onPressed: () {
                          _showConfirmationDialog(
                            context: context,
                            title: user.isActive
                                ? AppStrings.deactivateConfirm
                                : AppStrings.reactivateConfirm,
                            confirmActionText: user.isActive
                                ? AppStrings.deactivateUserButton
                                : AppStrings.reactivateUserButton,
                            onConfirm: () {
                              // Call the new repo function
                              ref
                                  .read(adminRepositoryProvider)
                                  .updateUserActiveStatus(
                                uid: user.uid,
                                isActive: !user.isActive, // Toggle the status
                              );
                              // Show snackbar
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(user.isActive
                                      ? AppStrings.userDeactivated
                                      : AppStrings.userReactivated),
                                  backgroundColor:
                                  user.isActive ? Colors.red : Colors.green,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ]
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Helper widget to show a colored chip for Role
  Widget _buildRoleChip(String role) {
    Color color;
    IconData icon;
    switch (role) {
      case UserRoles.superAdmin:
        color = Colors.red;
        icon = Icons.shield;
        break;
      case UserRoles.admin:
        color = Colors.orange;
        icon = Icons.verified_user;
        break;
      case UserRoles.teacher:
        color = Colors.blue;
        icon = Icons.school;
        break;
      default:
        color = Colors.grey;
        icon = Icons.person;
    }
    return Chip(
      avatar: Icon(icon, color: Colors.white, size: 16),
      label: Text(role, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
    );
  }

  // --- Helper widget to show a colored chip for Status ---
  Widget _buildStatusChip(String status, bool isActive) {
    // 1. Check isActive first. This is the most important status.
    if (!isActive) {
      return Chip(
        label: const Text(AppStrings.statusInactive,
            style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[700],
      );
    }

    // 2. If user is active, THEN check their approval status.
    Color color;
    String label;
    switch (status) {
      case UserStatus.approved:
        color = Colors.green;
        label = AppStrings.statusActive; // Use 'Active' string
        break;
      case UserStatus.pending:
        color = Colors.orange;
        label = UserStatus.pending; // Use 'pending_approval' string
        break;
      default: // rejected
        color = Colors.red;
        label = UserStatus.rejected;
    }
    return Chip(
      label: Text(label, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
    );
  }
}

// -----------------------------------------------------------------
// This is the same function from your original _PendingTeacherList
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
              Navigator.of(dialogContext).pop(); // Close dialog
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmActionText == AppStrings.rejectButton
                  ? Colors.red
                  : Colors.green,
            ),
            child: Text(confirmActionText,
                style: const TextStyle(color: Colors.white)),
            onPressed: () {
              onConfirm(); // Run the approve/reject function
              Navigator.of(dialogContext).pop(); // Close dialog
            },
          ),
        ],
      );
    },
  );
}
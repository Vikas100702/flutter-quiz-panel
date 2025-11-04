import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_panel/providers/admin_provider.dart';
import 'package:quiz_panel/providers/auth_provider.dart';
import 'package:quiz_panel/providers/user_data_provider.dart';
import 'package:quiz_panel/repositories/admin_repository.dart';
import 'package:quiz_panel/utils/app_strings.dart';

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


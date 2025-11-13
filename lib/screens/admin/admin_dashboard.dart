// lib/screens/admin/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/models/user_model.dart';
import 'package:quiz_panel/providers/admin_provider.dart';
import 'package:quiz_panel/providers/subject_provider.dart';
import 'package:quiz_panel/providers/user_data_provider.dart';
import 'package:quiz_panel/repositories/admin_repository.dart';
import 'package:quiz_panel/repositories/quiz_repository.dart';
// NEW IMPORT
import 'package:quiz_panel/providers/quiz_provider.dart';
import 'package:quiz_panel/utils/app_routes.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/utils/constants.dart';
import 'package:quiz_panel/widgets/buttons/app_button.dart';
import 'package:quiz_panel/widgets/inputs/app_text_field.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  // --- State for "My Content" Tab (TeacherDashboard se copy kiya gaya) ---
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // --- Logic for "My Content" Tab ---
  Future<void> _createSubject() async {
    final teacherUid = ref.read(userDataProvider).value?.uid;
    if (teacherUid == null || teacherUid.isEmpty) {
      _showError(AppStrings.genericError);
      return;
    }
    if (_nameController.text.isEmpty) {
      _showError('Subject Name cannot be empty.');
      return;
    }
    setState(() {
      _isCreating = true;
    });
    try {
      await ref.read(quizRepositoryProvider).createSubject(
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        teacherUid: teacherUid,
      );
      _showError(AppStrings.subjectCreatedSuccess, isError: false);
      _nameController.clear();
      _descController.clear();
      if (mounted) FocusScope.of(context).unfocus();
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  // Helper to show SnackBar
  void _showError(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // 3 tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.adminDashboardTitle),
          backgroundColor: AppColors.warning, // Admin color
          actions: [
            IconButton(
              icon: const Icon(Icons.person_outline),
              tooltip: 'My Account',
              onPressed: () {
                context.push(AppRoutePaths.myAccount);
              },
            ),
          ],
          bottom: const TabBar(
            tabAlignment: TabAlignment.fill,
            indicatorColor: Colors.white,
            tabs: [
              Tab(
                icon: Icon(Icons.pending_actions),
                text: 'Approvals',
              ),
              Tab(
                icon: Icon(Icons.people_alt),
                text: 'Manage Users',
              ),
              Tab(
                icon: Icon(Icons.school),
                text: 'My Content',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // --- Tab 1: Pending Approvals ---
            const _PendingTeacherList(),

            // --- Tab 2: Manage Users (Teachers & Students) ---
            const _ManagedUserList(),

            // --- Tab 3: My Content (Teacher Dashboard Body) ---
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildCreateSubjectForm(context),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),
                    Text(
                      AppStrings.mySubjectsTitle,
                      style: AppTextStyles.displaySmall,
                    ),
                    const SizedBox(height: 16),
                    _buildSubjectsList(context, ref), // <-- 3. Refactor
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widgets for "My Content" Tab (TeacherDashboard se copy kiye gaye) ---
  Widget _buildCreateSubjectForm(BuildContext context) {
    // --- 4. FORM KO RESPONSIVE BANAYA ---
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.createSubjectTitle,
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: 24),
            // Yeh Wrap widget chote screens par fields ko stack kar dega
            Wrap(
              runSpacing: 16,
              spacing: 16,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 250),
                  child: AppTextField(
                    controller: _nameController,
                    label: AppStrings.subjectNameLabel,
                    prefixIcon: Icons.title,
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 250),
                  child: AppTextField(
                    controller: _descController,
                    label: AppStrings.subjectDescLabel,
                    prefixIcon: Icons.description,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            AppButton(
              text: AppStrings.createSubjectButton,
              onPressed: _isCreating ? null : _createSubject,
              isLoading: _isCreating,
              type: AppButtonType.primary,
            ),
          ],
        ),
      ),
    );
  }

  // --- 5. GRIDVIEW KO RESPONSIVE BANAYA ---
  Widget _buildSubjectsList(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(subjectsProvider);

    return subjectsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${AppStrings.firestoreIndexError}\n\nError: ${error.toString()}',
              style: TextStyle(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
      data: (subjects) {
        if (subjects.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(AppStrings.noSubjectsFound),
            ),
          );
        }
        // Responsive Grid ke liye LayoutBuilder ka istemaal
        return LayoutBuilder(
          builder: (context, constraints) {
            // Dynamic column count
            int crossAxisCount = 1;
            if (constraints.maxWidth > 1200) {
              crossAxisCount = 4;
            } else if (constraints.maxWidth > 800) {
              crossAxisCount = 3;
            } else if (constraints.maxWidth > 500) {
              crossAxisCount = 2;
            }

            return GridView.builder(
              itemCount: subjects.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 2.0, // Card ka aspect ratio
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final subject = subjects[index];
                final bool isPublished =
                    subject.status == ContentStatus.published;

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            context.pushNamed(
                              AppRouteNames.quizManagement,
                              pathParameters: {'subjectId': subject.subjectId},
                              extra: subject,
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subject.name,
                                style: AppTextStyles.titleLarge,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (subject.description != null &&
                                  subject.description!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    subject.description!,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textTertiary,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        const Divider(),
                        // --- MODIFIED SECTION (Same as TeacherDashboard) ---
                        Consumer(
                          builder: (context, ref, child) {
                            final quizzesAsync = ref.watch(quizzesProvider(subject.subjectId));

                            return quizzesAsync.when(
                              loading: () => const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                              error: (e, s) => Tooltip(
                                message: e.toString(),
                                child: const ListTile(
                                  title: Text('Error loading quizzes'),
                                  leading: Icon(Icons.error, color: AppColors.error),
                                ),
                              ),
                              data: (quizzes) {
                                final int quizCount = quizzes.length;
                                final bool canPublish = quizCount > 0;

                                return SwitchListTile(
                                  title: Text(
                                    isPublished
                                        ? AppStrings.statusPublished
                                        : AppStrings.statusDraft,
                                    style: TextStyle(
                                      color: isPublished
                                          ? AppColors.success
                                          : AppColors.warning,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: const Text(AppStrings.publishSubject),
                                  value: isPublished,
                                  activeThumbColor: AppColors.success,
                                  onChanged: (newValue) {
                                    if (newValue == true && !canPublish) {
                                      _showError(
                                        'You must add at least 1 quiz to publish this subject.',
                                      );
                                      return;
                                    }

                                    final newStatus = newValue
                                        ? ContentStatus.published
                                        : ContentStatus.draft;
                                    ref
                                        .read(quizRepositoryProvider)
                                        .updateSubjectStatus(
                                      subjectId: subject.subjectId,
                                      newStatus: newStatus,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          newValue
                                              ? AppStrings.subjectPublished
                                              : AppStrings.subjectUnpublished,
                                        ),
                                        backgroundColor: newValue
                                            ? AppColors.success
                                            : AppColors.warning,
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                        // --- END MODIFIED SECTION ---
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
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
// WIDGET 2: MANAGED USER LIST (MODIFIED FOR MOBILE)
// -----------------------------------------------------------------
class _ManagedUserList extends ConsumerWidget {
  const _ManagedUserList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final managedUsers = ref.watch(adminManagedUsersProvider);

    return managedUsers.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${AppStrings.firestoreIndexError}\n\nError: ${e.toString()}',
              style: TextStyle(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
      data: (users) {
        if (users.isEmpty) {
          return const Center(child: Text(AppStrings.noManagedUsers));
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Deactivate/Reactivate Button
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

  // Helper widget
  Widget _buildRoleChip(String role) {
    Color color;
    IconData icon;
    switch (role) {
      case UserRoles.teacher:
        color = AppColors.primary;
        icon = Icons.school;
        break;
      default: // Student
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
      default: // rejected
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
// lib/screens/admin/user_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/models/subject_model.dart';
import 'package:quiz_panel/models/user_model.dart';
import 'package:quiz_panel/providers/quiz_provider.dart';
import 'package:quiz_panel/providers/subject_provider.dart';
import 'package:quiz_panel/repositories/admin_repository.dart';
import 'package:quiz_panel/utils/constants.dart';

/// **Why we used this Widget (UserDetailsScreen):**
/// This screen provides a complete "360-degree view" of a specific user for the Admin.
/// Whether the user is a Student, Teacher, or another Admin, this screen displays:
/// 1. **Core Identity:** Name, Email, Photo, Account Status.
/// 2. **Extended Profile:** Extra data like 'Qualification' (for teachers) or 'Grade' (for students).
/// 3. **Activity/Content:** What subjects a teacher has created, or (in future) what quizzes a student has attempted.
///
/// **How it helps:**
/// It gives Admins full context before they take actions like Approving, Rejecting, or Banning a user.
class UserDetailsScreen extends ConsumerStatefulWidget {
  final UserModel user; // The user object passed from the previous list screen.
  const UserDetailsScreen({super.key, required this.user});

  @override
  ConsumerState<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends ConsumerState<UserDetailsScreen> {
  // **State Variable:**
  // Holds the result of fetching the "Extra Profile Data" (like qualification or phone number)
  // from the separate `teacher_profiles` or `student_profiles` collections.
  late Future<Map<String, dynamic>> _profileDataFuture;

  @override
  void initState() {
    super.initState();

    // **Logic: Fetch Extended Data**
    // As soon as the screen opens, we ask the repository to find any extra details
    // associated with this user's UID and Role.
    // We do this in initState so it only happens once, not every time the UI rebuilds.
    _profileDataFuture = ref
        .read(adminRepositoryProvider)
        .getRoleProfileData(widget.user.uid, widget.user.role);
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(user.displayName),
        // **Dynamic Styling:**
        // We change the AppBar color based on the user's role to give immediate visual context.
        // Red = Super Admin, Orange = Admin, Blue = Teacher/Student.
        backgroundColor: user.role == UserRoles.superAdmin
            ? AppColors.error
            : (user.role == UserRoles.admin
            ? AppColors.warning
            : AppColors.primary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- SECTION 1: CORE USER DATA ---
                // Displays the fundamental account info stored in the 'users' collection.
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // **Profile Picture:**
                        // Shows the user's photo or a default icon if none exists.
                        Center(
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor:
                            AppColors.primaryLight.withValues(alpha: 0.1),
                            backgroundImage:
                            (user.photoURL != null && user.photoURL!.isNotEmpty)
                                ? NetworkImage(user.photoURL!)
                                : null,
                            child: (user.photoURL == null ||
                                user.photoURL!.isEmpty)
                                ? Icon(
                              Icons.person,
                              size: 50,
                              color: AppColors.primary,
                            )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // **Name & Email:**
                        // Prominently displayed at the top.
                        Text(
                          user.displayName,
                          style: AppTextStyles.displaySmall,
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          user.email,
                          style: AppTextStyles.titleMedium
                              .copyWith(color: AppColors.textTertiary),
                          textAlign: TextAlign.center,
                        ),
                        const Divider(height: 24),

                        // **Technical Details:**
                        // Useful for Admins to debug issues (e.g., checking UID or Auth Provider).
                        Text(
                          'Core User Data',
                          style: AppTextStyles.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow('UID', user.uid),
                        _buildDetailRow('Role', user.role),
                        _buildDetailRow('Status', user.status),
                        _buildDetailRow('Is Active', user.isActive.toString()),
                        _buildDetailRow('Phone', user.phoneNumber ?? 'N/A'),
                        _buildDetailRow('Created At',
                            user.createdAt.toDate().toLocal().toString()),
                        _buildDetailRow(
                            'Approved By', user.approvedBy ?? 'N/A'),
                        _buildDetailRow(
                            'Auth Providers', user.authProviders.join(', ')),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // --- SECTION 2: EXTENDED PROFILE DATA ---
                // Only shown for Teachers and Students (Admins usually don't have extra profiles).
                if (user.role == UserRoles.student ||
                    user.role == UserRoles.teacher)
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${user.role.capitalize()} Profile Data',
                            style: AppTextStyles.titleLarge,
                          ),
                          const Divider(height: 20),
                          // This widget handles the async loading of the profile map.
                          _buildProfileData(),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 20),

                // --- SECTION 3: ROLE-SPECIFIC CONTENT ---
                // This switch case decides what "Activity" to show based on the role.
                // - Teachers: Show their Subjects.
                // - Students: Show their Quiz History (Placeholder).
                switch (user.role) {
                  UserRoles.teacher =>
                      _TeacherContent(teacherUid: user.uid),
                  UserRoles.student =>
                      _StudentContent(studentUid: user.uid),
                  UserRoles.admin => _AdminContent(adminUid: user.uid),
                  _ => const SizedBox.shrink(),
                }
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// **Helper Widget: Build Profile Data**
  /// Uses a `FutureBuilder` to wait for the `getRoleProfileData` call to finish.
  /// - **Loading:** Shows a spinner.
  /// - **Error:** Shows an error message.
  /// - **Data:** Iterates through the Map (Key-Value pairs) and displays them as rows.
  Widget _buildProfileData() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _profileDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
              child: Text('Error loading profile: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
              child: Text('No additional profile data found.'));
        }

        final profileData = snapshot.data!;
        // Loop through every piece of data in the profile and create a display row.
        return Column(
          children: profileData.entries.map((entry) {
            return _buildDetailRow(
              entry.key.capitalize(), // Format key (e.g., 'studentId' -> 'Studentid')
              entry.value?.toString() ?? 'N/A',
            );
          }).toList(),
        );
      },
    );
  }

  /// **Helper Widget: Detail Row**
  /// A simple reusable row to display "Label: Value".
  Widget _buildDetailRow(String title, String value) {
    // Skip displaying fields that are already shown in the main header (Name, Email, Photo).
    if (title == 'Name' || title == 'Email' || title == 'Photo URL') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: ',
            style: AppTextStyles.titleSmall
                .copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          Expanded(
            // Use SelectableText so admins can copy-paste IDs if needed.
            child: SelectableText(
              value,
              style: AppTextStyles.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// ROLE-SPECIFIC CONTENT WIDGETS
// -----------------------------------------------------------------------------

/// **1. Teacher Content View**
/// **Why:** Allows Admins to see what educational content a specific Teacher has created.
/// **How:** It uses `subjectsByTeacherProvider` which filters subjects by the Teacher's UID.
class _TeacherContent extends ConsumerWidget {
  final String teacherUid;
  const _TeacherContent({required this.teacherUid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the specific provider that fetches subjects for THIS teacher.
    final subjectsAsync = ref.watch(subjectsByTeacherProvider(teacherUid));

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Teacher's Content",
              style: AppTextStyles.titleLarge,
            ),
            const Divider(height: 20),
            subjectsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) =>
                  Text('Error loading subjects: ${e.toString()}'),
              data: (subjects) {
                if (subjects.isEmpty) {
                  return const Center(
                    child: Text('This teacher has not created any subjects yet.'),
                  );
                }
                // List all subjects created by this teacher.
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: subjects.length,
                  itemBuilder: (context, index) {
                    final subject = subjects[index];
                    // Show quizzes inside this subject.
                    return _SubjectQuizzes(subject: subject);
                  },
                  separatorBuilder: (context, index) => const Divider(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// **2. Subject Quizzes List**
/// **Why:** A helper widget to show the Quizzes inside a specific Subject.
/// **How:** It watches `quizzesProvider(subjectId)` to fetch the quiz data.
class _SubjectQuizzes extends ConsumerWidget {
  final SubjectModel subject;
  const _SubjectQuizzes({required this.subject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch quizzes for this specific subject.
    final quizzesAsync = ref.watch(quizzesProvider(subject.subjectId));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subject Name and Status
          Text(
            subject.name,
            style:
            AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            "Status: ${subject.status}",
            style: AppTextStyles.bodyMedium.copyWith(
              color: subject.status == ContentStatus.published
                  ? AppColors.success
                  : AppColors.warning,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),

          // List of Quizzes
          quizzesAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (e, s) =>
                Text('  Error loading quizzes: ${e.toString()}'),
            data: (quizzes) {
              if (quizzes.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Text(
                    'No quizzes in this subject.',
                    style: AppTextStyles.bodySmall,
                  ),
                );
              }
              // Display quiz titles and statuses.
              return Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: quizzes.map((quiz) {
                    return Text(
                      '• ${quiz.title} (${quiz.status}, ${quiz.totalQuestions} Qs)',
                      style: AppTextStyles.bodyMedium,
                    );
                  }).toList(),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}

/// **3. Student Content Placeholder**
/// **Why:** In the future, this will show a student's performance history.
/// **Current Status:** Placeholder text until the `attempts` feature is fully connected for Admins.
class _StudentContent extends StatelessWidget {
  final String studentUid;
  const _StudentContent({required this.studentUid});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Student's Content",
              style: AppTextStyles.titleLarge,
            ),
            const Divider(height: 20),
            Text(
              "Student quiz history and attempts data will be shown here.",
              style: AppTextStyles.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              "(This requires a new provider and repository function to fetch 'attempts' by studentId)",
              style: AppTextStyles.bodySmall.copyWith(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}

/// **4. Admin Content Placeholder**
/// **Why:** In the future, this will show an audit log of the Admin's actions.
class _AdminContent extends StatelessWidget {
  final String adminUid;
  const _AdminContent({required this.adminUid});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Admin's Activity",
              style: AppTextStyles.titleLarge,
            ),
            const Divider(height: 20),
            Text(
              "Admin activity logs and approval/rejection history will be shown here.",
              style: AppTextStyles.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              "(This requires a new 'admin_logs' collection in Firestore and a corresponding provider)",
              style: AppTextStyles.bodySmall.copyWith(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}

/// **Utility Extension:**
/// Capitalizes the first letter of a string (e.g., "teacher" -> "Teacher").
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return "";
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
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

class UserDetailsScreen extends ConsumerStatefulWidget {
  final UserModel user;
  const UserDetailsScreen({super.key, required this.user});

  @override
  ConsumerState<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends ConsumerState<UserDetailsScreen> {
  late Future<Map<String, dynamic>> _profileDataFuture;

  @override
  void initState() {
    super.initState();
    // Screen load hote hi extra profile data fetch karein
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
        // AppBar ka color user role ke hisaab se
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
                // --- Card 1: Main User Data (REVISED) ---
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
                        // --- NEW: Profile Picture ---
                        Center(
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor:
                            AppColors.primaryLight.withOpacity(0.1),
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
                        // --- NEW: Name and Email (Centered) ---
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
                        // ---
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
                        _buildDetailRow('Photo URL', user.photoURL ?? 'N/A'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Card 2: Role-Specific Profile Data (Unchanged)
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
                          // FutureBuilder profile data load karega
                          _buildProfileData(),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 20),

                // --- NEW: Card 3: Role-Specific CONTENT ---
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

  // Helper widget: Profile data ke liye FutureBuilder
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
        // Map mein jitni bhi entries hain, un sab ke liye rows banayein
        return Column(
          children: profileData.entries.map((entry) {
            return _buildDetailRow(
              entry.key.capitalize(), // e.g., 'studentId' -> 'Studentid'
              entry.value?.toString() ?? 'N/A',
            );
          }).toList(),
        );
      },
    );
  }

  // Helper widget: Ek detail row banane ke liye (UPDATED)
  Widget _buildDetailRow(String title, String value) {
    // --- UPDATE: Hide fields handled by the new header ---
    if (title == 'Name' || title == 'Email' || title == 'Photo URL') {
      return const SizedBox.shrink();
    }
    // --- END UPDATE ---

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

// --- NEW WIDGETS ---

// --- 1. TEACHER CONTENT VIEW ---
class _TeacherContent extends ConsumerWidget {
  final String teacherUid;
  const _TeacherContent({required this.teacherUid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider from subject_provider.dart
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
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: subjects.length,
                  itemBuilder: (context, index) {
                    final subject = subjects[index];
                    // Pass each subject to the quiz-fetching widget
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

// --- 2. WIDGET TO SHOW QUIZZES FOR A SUBJECT ---
class _SubjectQuizzes extends ConsumerWidget {
  final SubjectModel subject;
  const _SubjectQuizzes({required this.subject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider from quiz_provider.dart
    final quizzesAsync = ref.watch(quizzesProvider(subject.subjectId));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subject Info
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

          // Quiz List
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

// --- 3. STUDENT CONTENT PLACEHOLDER ---
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

// --- 4. ADMIN CONTENT PLACEHOLDER ---
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


// String ko capitalize karne ke liye ek chota helper
extension StringExtension on String {
  String capitalize() {
    if (this.isEmpty) return "";
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
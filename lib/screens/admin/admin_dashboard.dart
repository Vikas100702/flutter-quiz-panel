import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/providers/quiz_provider.dart';
import 'package:quiz_panel/providers/subject_provider.dart';
import 'package:quiz_panel/providers/user_data_provider.dart';
import 'package:quiz_panel/repositories/quiz_repository.dart';
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
    // List of categories for Admin
    final List<Map<String, dynamic>> categories = [
      {
        'title': 'Pending Approvals',
        'icon': Icons.pending_actions,
        'color': AppColors.warning,
        'filter': 'pending'
      },
      {
        'title': 'Manage Teachers',
        'icon': Icons.school,
        'color': AppColors.primary,
        'filter': 'teachers'
      },
      {
        'title': 'Manage Students',
        'icon': Icons.person,
        'color': AppColors.success,
        'filter': 'students'
      },
    ];

    return Scaffold(
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
        // No more TabBar
      ),
      // No more TabBarView
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 1. User Management Section ---
            Text(
              'User Management',
              style: AppTextStyles.displaySmall,
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                // Dynamic column count
                int crossAxisCount = 2; // Default for mobile
                if (constraints.maxWidth > 1000) {
                  crossAxisCount = 3;
                } else if (constraints.maxWidth > 600) {
                  crossAxisCount = 3;
                }

                return GridView.builder(
                  shrinkWrap: true, // Important in SingleChildScrollView
                  physics:
                  const NeverScrollableScrollPhysics(), // Important
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 1.2, // Square-ish cards
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return _buildCategoryCard(
                      context: context,
                      title: category['title'],
                      icon: category['icon'],
                      color: category['color'],
                      onTap: () {
                        // Navigate to the new list screen with the filter
                        context.pushNamed(
                          AppRouteNames.adminUserList,
                          pathParameters: {'filter': category['filter']},
                        );
                      },
                    );
                  },
                );
              },
            ),

            // --- 2. "My Content" Section ---
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            Text(
              AppStrings.myContentTitle,
              style: AppTextStyles.displaySmall,
            ),
            const SizedBox(height: 16),
            _buildCreateSubjectForm(context),
            const SizedBox(height: 24),
            Text(
              AppStrings.mySubjectsTitle,
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildSubjectsList(context, ref),
          ],
        ),
      ),
    );
  }

  // Helper widget to build a category card
  Widget _buildCategoryCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.titleMedium
                  .copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // --- Widgets for "My Content" Tab (TeacherDashboard se copy kiye gaye) ---
  Widget _buildCreateSubjectForm(BuildContext context) {
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
        return LayoutBuilder(
          builder: (context, constraints) {
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
                        Consumer(
                          builder: (context, ref, child) {
                            final quizzesAsync =
                            ref.watch(quizzesProvider(subject.subjectId));

                            return quizzesAsync.when(
                              loading: () => const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child:
                                  CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                              error: (e, s) => Tooltip(
                                message: e.toString(),
                                child: const ListTile(
                                  title: Text('Error loading quizzes'),
                                  leading:
                                  Icon(Icons.error, color: AppColors.error),
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
                                  subtitle:
                                  const Text(AppStrings.publishSubject),
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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/utils/app_routes.dart';
import 'package:quiz_panel/providers/subject_provider.dart';
import 'package:quiz_panel/providers/user_data_provider.dart';
import 'package:quiz_panel/repositories/quiz_repository.dart';
// NEW IMPORT
import 'package:quiz_panel/providers/quiz_provider.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/utils/constants.dart';
import 'package:quiz_panel/widgets/buttons/app_button.dart';
import 'package:quiz_panel/widgets/inputs/app_text_field.dart';

class TeacherDashboard extends ConsumerStatefulWidget {
  const TeacherDashboard({super.key});

  @override
  ConsumerState<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends ConsumerState<TeacherDashboard> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // --- Logic to Create a New Subject ---
  Future<void> _createSubject() async {
    final teacherUid = ref.read(userDataProvider).value?.uid;
    if (teacherUid == null || teacherUid.isEmpty) {
      _showError(AppStrings.genericError); // Show generic error
      return;
    }

    if (_nameController.text.isEmpty) {
      _showError(
        'Subject Name cannot be empty.',
      ); // This should be in AppStrings
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      await ref
          .read(quizRepositoryProvider)
          .createSubject(
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

  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.teacherDashboardTitle),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'My Account',
            onPressed: () {
              context.push(AppRoutePaths.myAccount);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
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
              _buildSubjectsList(context, ref), // Pass ref
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widget: Create Subject Form (FIXED) ---
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
            // --- FIX: Using Wrap for responsiveness ---
            Wrap(
              runSpacing: 16,
              spacing: 16,
              children: [
                ConstrainedBox(
                  // MinWidth rakhein taaki desktop par accha dikhe
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
            // --- END FIX ---
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

  // --- Helper Widget: Subject List ---
  Widget _buildSubjectsList(BuildContext context, WidgetRef ref) {
    // 2. Watch the 'Manager' (subjectsProvider)
    final subjectsAsync = ref.watch(subjectsProvider);

    // 3. Use .when() to handle loading/error/data states
    return subjectsAsync.when(
      // 3a. Loading State
      loading: () => const Center(child: CircularProgressIndicator()),

      // 3b. Error State
      error: (error, stackTrace) {
        // This is where the Firestore Index error will appear
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

      // 3c. Data State
      data: (subjects) {
        // If the list is empty, show a message
        if (subjects.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(AppStrings.noSubjectsFound),
            ),
          );
        }

        // If we have data, build the list
        // We use LayoutBuilder for a responsive grid
        return LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = 1; // Default for mobile
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
                childAspectRatio: 2.0,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final subject = subjects[index];
                // Check if subject is published
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

                        // --- MODIFIED SECTION ---
                        Consumer(
                          builder: (context, ref, child) {
                            // Watch the quizzes for THIS subject
                            final quizzesAsync = ref.watch(quizzesProvider(subject.subjectId));

                            // Use .when to show loader/error/switch
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

                                // Return the SwitchListTile with new logic
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
                                    // Check constraint on publish (newValue == true)
                                    if (newValue == true && !canPublish) {
                                      _showError(
                                        'You must add at least 1 quiz to publish this subject.',
                                      );
                                      return; // Don't allow turning it on
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
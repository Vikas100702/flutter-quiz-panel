// lib/screens/teacher/teacher_dashboard.dart

/*
/// Why we used this file (TeacherDashboard):
/// This is the main control center and entry point for users with the **'teacher' role**.
/// It provides all the necessary tools for a teacher to begin creating and managing educational content (Subjects).

/// What it is doing:
/// 1. **Subject Creation:** Provides a responsive form to create a new Subject (e.g., "Mathematics").
/// 2. **Content Listing:** Displays a live, grid-based list of all Subjects created by the current teacher.
/// 3. **Publishing Control:** Allows teachers to set the status of their Subjects to 'Draft' or 'Published', with a constraint check to ensure the subject contains at least one quiz before becoming visible to students.

/// How it is working:
/// It is a `ConsumerStatefulWidget` managing form inputs and the network loading state. It uses the `subjectsProvider` stream to display
/// the list of authored content and leverages a nested **Riverpod Consumer** to watch the `quizzesProvider.family` for each subject,
/// enabling the live validation logic for the publication toggle.

/// How it's helpful:
/// It provides a streamlined and secure content creation workflow, ensuring teachers can easily manage their courses and prevent incomplete content from reaching the students.
*/
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

/// Why we used this Widget:
/// As a `ConsumerStatefulWidget`, it allows the dashboard to hold and manage temporary state like
/// `TextEditingController` objects for the subject creation form, as well as the `_isCreating` loading flag.
class TeacherDashboard extends ConsumerStatefulWidget {
  const TeacherDashboard({super.key});

  @override
  ConsumerState<TeacherDashboard> createState() => _TeacherDashboardState();
}

/// What it is doing: Manages the state and logic for the Subject creation and listing features.
class _TeacherDashboardState extends ConsumerState<TeacherDashboard> {
  // What it is doing: Controllers to capture the Subject's name and optional description.
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  // What it is doing: Controls the loading state of the submission button.
  bool _isCreating = false;

  @override
  /// How it's helpful: Disposes of controllers to prevent memory leaks when the screen is destroyed.
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // --- Logic to Create a New Subject ---
  /// What it is doing: Orchestrates the creation of a new Subject document in Firestore.
  Future<void> _createSubject() async {
    // How it is working: Reads the logged-in user's UID (Unique Identifier) to mark them as the creator.
    final teacherUid = ref.read(userDataProvider).value?.uid;
    if (teacherUid == null || teacherUid.isEmpty) {
      _showError(AppStrings.genericError); // Show generic error
      return;
    }

    // What it is doing: Basic validation to ensure the Subject Name field is not empty.
    if (_nameController.text.isEmpty) {
      _showError(
        'Subject Name cannot be empty.',
      ); // This should be in AppStrings
      return;
    }

    // What it is doing: Activates the loading state.
    setState(() {
      _isCreating = true;
    });

    try {
      // How it is working: Calls the `QuizRepository` to execute the database write operation.
      await ref
          .read(quizRepositoryProvider)
          .createSubject(
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        teacherUid: teacherUid,
      );

      // How it's helpful: Shows a success notification and clears the form for repeated use.
      _showError(AppStrings.subjectCreatedSuccess, isError: false);
      _nameController.clear();
      _descController.clear();
      // What it is doing: Closes the keyboard after successful submission.
      if (mounted) FocusScope.of(context).unfocus();
    } catch (e) {
      // What it is doing: Displays any exception (e.g., network, database error).
      _showError(e.toString());
    } finally {
      if (mounted) {
        // How it's helpful: Resets the loading state regardless of success or failure.
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  // Helper to show SnackBar
  /// What it is doing: Utility function to display standardized temporary messages.
  void _showError(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        // How it is working: Tints the notification red for errors and green for success.
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }

  // --- Main Build Method ---
  @override
  /// What it is doing: Constructs the main screen layout, including the Subject creation form and the content grid.
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
              // What it is doing: Navigates to the user's profile and account settings hub.
              context.push(AppRoutePaths.myAccount);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        // Why we used SingleChildScrollView: Ensures the content is vertically scrollable on all screen sizes, preventing overflow.
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
              // What it is doing: Calls the widget responsible for displaying the list of created subjects.
              _buildSubjectsList(context, ref), // Pass ref
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widget: Create Subject Form (FIXED) ---
  /// What it is doing: Builds the responsive input form for creating a new Subject.
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
            // Why we used Wrap: To allow the Name and Description fields to fluidly switch between
            // a side-by-side (Row) and stacked (Column) layout based on screen width.
            Wrap(
              runSpacing: 16,
              spacing: 16,
              children: [
                ConstrainedBox(
                  // How it's helpful: Ensures the input field is never too small on wide screens.
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
              onPressed: _isCreating ? null : _createSubject, // Disabled if currently creating.
              isLoading: _isCreating,
              type: AppButtonType.primary,
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widget: Subject List ---
  /// What it is doing: Fetches and displays the teacher's list of Subjects in a responsive grid, including publishing controls.
  Widget _buildSubjectsList(BuildContext context, WidgetRef ref) {
    // 2. Watch the 'Manager' (subjectsProvider)
    // How it is working: Subscribes to the stream of Subjects created by the current teacher.
    final subjectsAsync = ref.watch(subjectsProvider);

    // 3. Use .when() to handle loading/error/data states
    return subjectsAsync.when(
      // 3a. Loading State
      loading: () => const Center(child: CircularProgressIndicator()),

      // 3b. Error State
      error: (error, stackTrace) {
        // How it's helpful: Displays a specific warning about a missing Firestore Index, which is a common setup requirement for ordered queries.
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
        // What it is doing: Shows a placeholder message if the teacher has no content yet.
        if (subjects.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(AppStrings.noSubjectsFound),
            ),
          );
        }

        // How it is working: Uses LayoutBuilder to dynamically determine the grid layout based on screen size.
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
              // How it's helpful: Allows the grid to correctly size itself inside the outer `SingleChildScrollView`.
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 2.0, // What it is doing: Creates rectangular cards (2x wider than tall).
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final subject = subjects[index];
                // What it is doing: Checks the current publication status for the Switch.
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
                            // What it is doing: Navigates to the Quiz Management screen for this subject.
                            context.pushNamed(
                              AppRouteNames.quizManagement,
                              pathParameters: {'subjectId': subject.subjectId},
                              // How it's helpful: Passes the full subject object via `extra` to avoid redundant data fetching on the next screen.
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

                        // --- MODIFIED SECTION: Publish Control ---
                        Consumer(
                          // Why we used a nested Consumer: To access the `quizzesProvider` which requires the `subjectId`
                          // that is only available inside this `ListView.builder` context.
                          builder: (context, ref, child) {
                            // What it is doing: Watches the live count of Quizzes under this specific Subject.
                            final quizzesAsync = ref.watch(quizzesProvider(subject.subjectId));

                            // How it is working: Handles the asynchronous states for fetching the quiz count before displaying the switch.
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
                                // What it is doing: Implements the business rule: must have > 0 quizzes to publish.
                                final bool canPublish = quizCount > 0;

                                // What it is doing: The main UI element for switching between Draft and Published status.
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
                                    // Logic: Enforce constraint.
                                    if (newValue == true && !canPublish) {
                                      _showError(
                                        'You must add at least 1 quiz to publish this subject.',
                                      );
                                      return; // Stop execution if the rule is violated.
                                    }

                                    final newStatus = newValue
                                        ? ContentStatus.published
                                        : ContentStatus.draft;
                                    // How it is working: Calls the repository to update the `status` field in the database.
                                    ref
                                        .read(quizRepositoryProvider)
                                        .updateSubjectStatus(
                                      subjectId: subject.subjectId,
                                      newStatus: newStatus,
                                    );
                                    // How it's helpful: Provides confirmation feedback to the teacher.
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
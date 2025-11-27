// lib/screens/admin/admin_dashboard.dart

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

/// **Why we used this Widget (AdminDashboard):**
/// This is the main control center for the 'Admin' role.
/// Unlike the 'Super Admin' (who manages the entire system), the 'Admin' role has specific duties:
/// 1. **User Approval:** Reviewing and approving new Teacher registrations.
/// 2. **User Management:** Overseeing Student and Teacher accounts.
/// 3. **Content Creation:** Like a Teacher, an Admin can also create educational content (Subjects/Quizzes).
///
/// **How it helps:**
/// It provides a unified interface to switch between administrative tasks (approvals) and
/// creative tasks (making quizzes), saving the user from needing two separate accounts.
class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  // **State Variables:**
  // These controllers capture the text typed by the Admin for a new Subject.
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  // This boolean tracks the "loading" state.
  // When true, we disable buttons and show a spinner to prevent double-clicks.
  bool _isCreating = false;

  @override
  void dispose() {
    // **Cleanup:**
    // We must always dispose of controllers when the screen is closed
    // to prevent memory leaks (computer memory not being freed).
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // --- Logic: Create a New Subject ---

  /// **What is this function doing?**
  /// It handles the entire process of adding a new Subject to the database.
  ///
  /// **How it works:**
  /// 1. **Identify User:** It gets the current Admin's UID (User ID) to mark them as the creator.
  /// 2. **Validate Input:** It checks if the user actually typed a name. If not, it stops.
  /// 3. **Start Loading:** It updates the UI to show a loading spinner.
  /// 4. **Save to Database:** It calls the `QuizRepository` to send the data to Firestore.
  /// 5. **Finish:** It clears the text fields and hides the keyboard on success.
  Future<void> _createSubject() async {
    final teacherUid = ref.read(userDataProvider).value?.uid;

    // Safety Check: Ensure the user is logged in and we have their ID.
    if (teacherUid == null || teacherUid.isEmpty) {
      _showError(AppStrings.genericError);
      return;
    }

    // Validation: We cannot create a subject without a name.
    if (_nameController.text.isEmpty) {
      _showError('Subject Name cannot be empty.');
      return;
    }

    // Step 1: Update state to 'loading'.
    setState(() {
      _isCreating = true;
    });

    try {
      // Step 2: Perform the database operation via the Repository.
      await ref.read(quizRepositoryProvider).createSubject(
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        teacherUid: teacherUid,
      );

      // Step 3: Success! Show feedback and reset form.
      _showError(AppStrings.subjectCreatedSuccess, isError: false);
      _nameController.clear();
      _descController.clear();

      // Hide the keyboard.
      if (mounted) FocusScope.of(context).unfocus();
    } catch (e) {
      // Handle errors (like no internet).
      _showError(e.toString());
    } finally {
      // Step 4: Stop loading (whether successful or failed).
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  // --- Helper Function ---

  /// **Why we used this:**
  /// This is a utility function to show a "SnackBar" (a small pop-up message at the bottom).
  /// It reduces code duplication since we show messages in multiple places.
  void _showError(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        // Red for errors, Green for success.
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // **Dashboard Configuration:**
    // We define the list of administrative actions available on this screen.
    // Each item has a title, an icon, a color, and a 'filter' key used for navigation.
    final List<Map<String, dynamic>> categories = [
      {
        'title': 'Pending Approvals',
        'icon': Icons.pending_actions,
        'color': AppColors.warning,
        'filter': 'pending' // Used by the User List screen to know what to show.
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
        backgroundColor: AppColors.warning, // Use the Admin-specific theme color.
        actions: [
          // Profile Button: Navigates to the account settings screen.
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'My Account',
            onPressed: () {
              context.push(AppRoutePaths.myAccount);
            },
          ),
        ],
      ),
      // **Why SingleChildScrollView?**
      // This ensures that if the screen is small (like on a phone) or in landscape mode,
      // the user can scroll down to see all content instead of getting an overflow error.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Section 1: User Management ---
            Text(
              'User Management',
              style: AppTextStyles.displaySmall,
            ),
            const SizedBox(height: 16),

            // **Why LayoutBuilder?**
            // It gives us the exact width of the screen. We use this to make the grid responsive:
            // - 2 columns on mobile.
            // - 3 columns on tablets/desktops.
            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = 2; // Mobile default.
                if (constraints.maxWidth > 1000) {
                  crossAxisCount = 3; // Wide screens.
                } else if (constraints.maxWidth > 600) {
                  crossAxisCount = 3; // Tablets.
                }

                return GridView.builder(
                  shrinkWrap: true, // Vital: Tells GridView to only take needed space, not infinite height.
                  physics: const NeverScrollableScrollPhysics(), // Disable Grid's own scrolling (parent handles it).
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 1.2, // Makes cards slightly wider than tall.
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
                        // Navigate to the list screen, passing the 'filter' (e.g., 'pending').
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

            // --- Section 2: Content Management ("My Content") ---
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            Text(
              AppStrings.myContentTitle,
              style: AppTextStyles.displaySmall,
            ),
            const SizedBox(height: 16),

            // Input form to create a new subject.
            _buildCreateSubjectForm(context),

            const SizedBox(height: 24),
            Text(
              AppStrings.mySubjectsTitle,
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: 16),

            // List of subjects created by this Admin.
            _buildSubjectsList(context, ref),
          ],
        ),
      ),
    );
  }

  // --- Widget: Category Card ---

  /// **What is this Widget?**
  /// It builds a clickable card for the User Management grid.
  ///
  /// **How it helps:**
  /// It keeps the main `build` method clean by isolating the UI code for a single card.
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
            // A colored circle background for the icon.
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withValues(alpha: 0.1),
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

  // --- Widget: Create Subject Form ---

  /// **What is this Widget?**
  /// It displays the input form (Name & Description fields) for creating a Subject.
  ///
  /// **Key Feature: Responsive Wrap**
  /// We use a `Wrap` widget instead of a `Row` or `Column`.
  /// - On wide screens, the fields sit side-by-side.
  /// - On narrow screens, the second field automatically drops to the next line.
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

            // Responsive layout for inputs.
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

            // The "Create" Button.
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

  // --- Widget: Subjects List ---

  /// **Why we used this Widget:**
  /// It fetches and displays the list of Subjects that *this specific Admin* has created.
  ///
  /// **How it works:**
  /// 1. **Riverpod Provider:** It watches `subjectsProvider`. This establishes a live connection to Firestore.
  /// 2. **Handling States:** It uses `.when()` to gracefully handle:
  ///    - **Loading:** Shows a spinner.
  ///    - **Error:** Shows the error message (e.g., missing permissions).
  ///    - **Data:** Shows the list of cards.
  Widget _buildSubjectsList(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(subjectsProvider);

    return subjectsAsync.when(
      // 1. Show loader while fetching.
      loading: () => const Center(child: CircularProgressIndicator()),

      // 2. Show error if fetch fails.
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

      // 3. Show the data when it arrives.
      data: (subjects) {
        if (subjects.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(AppStrings.noSubjectsFound),
            ),
          );
        }

        // Use LayoutBuilder for a responsive grid similar to the categories.
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
                childAspectRatio: 2.0, // Card shape.
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final subject = subjects[index];
                final bool isPublished = subject.status == ContentStatus.published;

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
                        // Navigate to Quiz Management when tapped.
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

                        // **Nested Provider Call:**
                        // We need to check if the subject has quizzes before we allow publishing.
                        // So we watch the 'quizzesProvider' specifically for this subject ID.
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

                                // The "Publish" Toggle Switch.
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
                                    // Rule: Cannot publish an empty subject.
                                    if (newValue == true && !canPublish) {
                                      _showError(
                                        'You must add at least 1 quiz to publish this subject.',
                                      );
                                      return;
                                    }

                                    // Update the status in Firestore.
                                    final newStatus = newValue
                                        ? ContentStatus.published
                                        : ContentStatus.draft;
                                    ref
                                        .read(quizRepositoryProvider)
                                        .updateSubjectStatus(
                                      subjectId: subject.subjectId,
                                      newStatus: newStatus,
                                    );

                                    // Show feedback.
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
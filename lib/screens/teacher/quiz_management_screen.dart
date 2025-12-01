// lib/screens/teacher/quiz_management_screen.dart

/*
/// Why we used this file (QuizManagementScreen):
/// This screen is the primary content management layer for a specific Subject. It allows the Teacher (or Admin) to
/// create, view, and control the publication status of all Quizzes belonging to the parent Subject.

/// What it is doing:
/// 1. **Quiz Creation:** Provides a form to define a new Quiz (Title, Duration, Target Questions).
/// 2. **Quiz Listing:** Displays a live list of all created Quizzes for the current subject.
/// 3. **Publishing Control:** Allows the teacher to toggle the `status` of a Quiz (Draft/Published) using a Switch.
/// 4. **Validation Check:** Enforces the rule that a Quiz must meet the minimum question count (Min: 25) before it can be published.

/// How it is working:
/// It consumes the parent `SubjectModel` to fetch and link all Quiz data using the `quizzesProvider.family`.
/// The publishing logic involves a nested **Consumer** watching the `questionsProvider` to synchronously check the question count constraint before allowing a state change to the database via `QuizRepository`.

/// How it's helpful:
/// It provides a streamlined interface for teachers to prepare content. The embedded validation mechanism prevents students
/// from seeing incomplete tests, maintaining the quality of the educational content.
*/
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/providers/quiz_provider.dart';
import 'package:quiz_panel/providers/user_data_provider.dart';
import 'package:quiz_panel/repositories/quiz_repository.dart';
// NEW IMPORT
import 'package:quiz_panel/providers/question_provider.dart';
import 'package:quiz_panel/utils/app_routes.dart';
import 'package:quiz_panel/models/subject_model.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/utils/constants.dart';
import 'package:quiz_panel/widgets/buttons/app_button.dart';
import 'package:quiz_panel/widgets/inputs/app_text_field.dart';

/// Why we used this Widget:
/// This `ConsumerStatefulWidget` is necessary to manage mutable local state (input controllers and `_isCreating` flag)
/// while depending on the immutable `SubjectModel` passed from the previous screen.
class QuizManagementScreen extends ConsumerStatefulWidget {
  // Why we require `subject`: The unique `subjectId` is essential to filter the list of quizzes and link the newly created quiz.
  final SubjectModel subject;

  const QuizManagementScreen({super.key, required this.subject});

  @override
  ConsumerState<QuizManagementScreen> createState() =>
      _QuizManagementScreenState();
}

/// What it is doing: Manages the input data for creating a new quiz and the network loading state.
class _QuizManagementScreenState extends ConsumerState<QuizManagementScreen> {
  // What it is doing: Controllers for capturing user input. Default values are set for convenience.
  final _titleController = TextEditingController();
  final _durationController = TextEditingController(text: '25');
  final _questionsController = TextEditingController(text: '25');
  // What it is doing: Controls the spinner and disabling of the 'Create Quiz' button during the database operation.
  bool _isCreating = false;

  @override
  /// How it's helpful: Disposes all text editing controllers to release resources and prevent memory leaks.
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    _questionsController.dispose();
    super.dispose();
  }

  // Logic: Create a New Quiz
  /// What it is doing: Handles input validation, constructs the `QuizModel`, and calls the repository to save it.
  Future<void> _createQuiz() async {
    // How it is working: Fetches the unique ID of the currently logged-in user to mark them as the quiz creator.
    final teacherUid = ref.read(userDataProvider).value?.uid;
    if (teacherUid == null || teacherUid.isEmpty) {
      _showError('Error: Could not find teacher ID. Please re-login.');
      return;
    }
    // What it is doing: Validates that the title is not empty.
    if (_titleController.text.isEmpty) {
      _showError('Quiz Title cannot be empty.');
      return;
    }
    // How it is working: Safely parses text inputs to integers for database storage.
    final duration = int.tryParse(_durationController.text);
    final totalQuestions = int.tryParse(_questionsController.text);

    // What it is doing: Validation checks to ensure numerical fields are valid.
    if (duration == null || duration <= 0) {
      _showError('Please enter a valid duration.');
      return;
    }
    // Why we used `totalQuestions < 25`: This is a business rule/default minimum requirement for a standard quiz template.
    if (totalQuestions == null || totalQuestions < 25) {
      _showError('Please enter a valid number of questions (at least 25).');
      return;
    }

    // What it is doing: Initiates the loading state.
    setState(() {
      _isCreating = true;
    });

    try {
      // How it is working: Calls the core repository function, passing all required data, including the `subjectId` (Foreign Key).
      await ref
          .read(quizRepositoryProvider)
          .createQuiz(
            title: _titleController.text.trim(),
            subjectId: widget.subject.subjectId,
            duration: duration,
            totalQuestions: totalQuestions,
            teacherUid: teacherUid,
            marksPerQuestion: 4, // Sets a default mark value per question.
          );

      if (mounted) {
        // How it's helpful: Shows success feedback and resets the form for quick next entry.
        _showError(AppStrings.quizCreatedSuccess, isError: false);
        _titleController.clear();
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      // What it is doing: Displays any network or database exception that occurred.
      _showError(e.toString());
    } finally {
      if (mounted) {
        // How it's helpful: Ensures the loading state is reset, re-enabling the button.
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  // Helper to show SnackBar
  /// What it is doing: A simple utility to display transient messages (success or error) to the user.
  void _showError(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        // How it is working: Uses thematic colors based on the message type.
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }

  @override
  /// What it is doing: Constructs the vertically scrolling layout of the quiz management screen.
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.subject.name,
        ), // What it is doing: Displays the name of the parent subject in the title bar.
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        // Why we used SingleChildScrollView: Guarantees scrollability for all content, especially the form on mobile with the keyboard open.
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCreateQuizForm(context),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              Text(
                AppStrings.myQuizzesTitle,
                style: AppTextStyles.displaySmall,
              ),
              const SizedBox(height: 16),
              // What it is doing: Renders the dynamically loaded list of quizzes.
              _buildQuizzesList(context),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget: Create Quiz Form
  /// What it is doing: Builds the form card for defining a new quiz.
  Widget _buildCreateQuizForm(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AppStrings.createQuizTitle, style: AppTextStyles.titleLarge),
            const SizedBox(height: 16),
            AppTextField(
              controller: _titleController,
              label: AppStrings.quizTitleLabel,
              prefixIcon: Icons.title,
            ),
            const SizedBox(height: 16),
            // Why we used Wrap: To make the duration and question fields display side-by-side on wide screens
            // but stack vertically on narrow screens (responsive layout).
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.spaceBetween,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 200),
                  child: AppTextField(
                    controller: _durationController,
                    label: AppStrings.quizDurationLabel,
                    prefixIcon: Icons.timer,
                    keyboardType: TextInputType.number,
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 200),
                  child: AppTextField(
                    controller: _questionsController,
                    label: '${AppStrings.totalQuestionsLabel} (Min: 25)',
                    prefixIcon: Icons.question_mark,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            AppButton(
              text: AppStrings.createQuizButton,
              onPressed: _isCreating ? null : _createQuiz,
              isLoading: _isCreating,
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget: Quizzes List
  /// What it is doing: Fetches and renders the live list of all quizzes linked to the current subject.
  Widget _buildQuizzesList(BuildContext context) {
    // How it is working: Watches `quizzesProvider.family`, passing the subject ID. This provides a real-time stream (`Stream<List<QuizModel>>`).
    final quizzesAsync = ref.watch(quizzesProvider(widget.subject.subjectId));

    // How it is working: Uses `AsyncValue.when` to handle the asynchronous stream states (Loading, Error, Data).
    return quizzesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) {
        // How it's helpful: Displays any specific data loading errors for debugging.
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Error loading quizzes.\n\n${error.toString()}',
              style: const TextStyle(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
      data: (quizzes) {
        if (quizzes.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(AppStrings.noQuizzesFound),
            ),
          );
        }

        return ListView.builder(
          itemCount: quizzes.length,
          // Why we used shrinkWrap and NeverScrollableScrollPhysics: Ensures the list fits within the parent `SingleChildScrollView` without vertical overflow errors.
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final quiz = quizzes[index];
            final bool isPublished = quiz.status == ContentStatus.published;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(quiz.title, style: AppTextStyles.titleMedium),
                subtitle: Text(
                  'Target: ${quiz.totalQuestions} ${AppStrings.totalQuestionsLabel} | ${quiz.durationMin} ${AppStrings.minutesLabel}',
                  style: AppTextStyles.bodyMedium,
                ),
                // --- MODIFIED SECTION: Publishing and Navigation ---
                trailing: Consumer(
                  // Why we used a nested Consumer: We need to access a second Riverpod provider (`questionsProvider`)
                  // that depends on the current item (`quiz.quizId`) inside the `ListView.builder`.
                  builder: (context, ref, child) {
                    // What it is doing: Fetches the current list of questions for THIS quiz item in the list.
                    final questionsAsync = ref.watch(
                      questionsProvider(quiz.quizId),
                    );

                    return Wrap(
                      spacing: 4.0,
                      runSpacing: 4.0,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // How it is working: Uses `AsyncValue.when` to map the loading status of the question count to the UI.
                        questionsAsync.when(
                          loading: () => const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          error: (e, s) => Tooltip(
                            message: e.toString(),
                            child: const Icon(
                              Icons.error,
                              color: AppColors.error,
                            ),
                          ),
                          data: (questions) {
                            final int questionCount = questions.length;
                            const int minQuestions =
                                25; // Business rule: minimum question requirement.
                            final bool canPublish =
                                questionCount >= minQuestions;

                            // What it is doing: The main toggle switch for Draft/Published status.
                            return Switch(
                              value: isPublished,
                              activeThumbColor: AppColors.success,
                              onChanged: (newValue) {
                                // Logic: Enforce the minimum question constraint before publishing.
                                if (newValue == true && !canPublish) {
                                  _showError(
                                    'You must add at least $minQuestions questions to publish this quiz. You currently have $questionCount.',
                                  );
                                  return; // Prevents the Switch from toggling on.
                                }

                                final newStatus = newValue
                                    ? ContentStatus.published
                                    : ContentStatus.draft;

                                // How it is working: Calls the repository to update the status field in Firestore.
                                ref
                                    .read(quizRepositoryProvider)
                                    .updateQuizStatus(
                                      quizId: quiz.quizId,
                                      newStatus: newStatus,
                                    );

                                // How it's helpful: Provides success feedback.
                                _showError(
                                  newValue
                                      ? AppStrings.quizPublished
                                      : AppStrings.quizUnpublished,
                                  isError: false,
                                );
                              },
                            );
                          },
                        ),
                        // What it is doing: Button to navigate to the question creation screen for this quiz.
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios),
                          tooltip: AppStrings.addQuestionsButton,
                          color: AppColors.textTertiary,
                          onPressed: () {
                            // How it is working: Uses GoRouter to navigate, passing the full `quiz` object for the next screen to use.
                            context.pushNamed(
                              AppRouteNames.questionManagement,
                              pathParameters: {'quizId': quiz.quizId},
                              extra: quiz,
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
                // --- END MODIFIED SECTION ---
              ),
            );
          },
        );
      },
    );
  }
}

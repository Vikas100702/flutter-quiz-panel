// lib/screens/teacher/question_management_screen.dart

/*
/// Why we used this file (QuestionManagementScreen):
/// This screen is the dedicated interface for Teachers (or Admins acting as teachers) to build and manage
/// the individual questions that belong to a specific quiz. It is essential for content creation workflow.

/// What it is doing:
/// 1. **Question Creation:** Provides a form to input the question text, four options, and select the correct answer.
/// 2. **Live Listing:** Displays a real-time, scrolling list of all questions already created for the quiz.
/// 3. **Validation:** Enforces rules, ensuring all fields are filled and a correct answer is selected before saving.

/// How it is working:
/// It consumes the `QuizModel` passed during navigation to know which quiz's sub-collection to interact with.
/// The question list is managed by a `StreamProvider.family` (`questionsProvider`), which creates a live link to Firestore,
/// updating the UI automatically whenever a new question is added or modified. The saving logic uses the `QuizRepository`.

/// How it's helpful:
/// It centralizes the question creation process, ensuring all content adheres to the required data model (`QuestionModel`)
/// and provides instant visual feedback to the teacher about the content they are building.
*/
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/models/question_model.dart';
import 'package:quiz_panel/models/quiz_model.dart';
import 'package:quiz_panel/providers/question_provider.dart';
import 'package:quiz_panel/repositories/quiz_repository.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/widgets/buttons/app_button.dart';
import 'package:quiz_panel/widgets/inputs/app_text_field.dart';

/// Why we used this Widget:
/// This is a `ConsumerStatefulWidget` to manage the mutable input controllers and the loading state (`_isAdding`),
/// while also needing access to the Riverpod `questionsProvider` stream.
class QuestionManagementScreen extends ConsumerStatefulWidget {
  // Why we require `quiz`: This `QuizModel` object is needed to pass the unique `quizId` to the repository functions and providers.
  final QuizModel quiz;

  const QuestionManagementScreen({super.key, required this.quiz});

  @override
  ConsumerState<QuestionManagementScreen> createState() =>
      _QuestionManagementScreenState();
}

/// What it is doing: Manages input values, validation, and the asynchronous operations of adding questions.
class _QuestionManagementScreenState
    extends ConsumerState<QuestionManagementScreen> {
  // Form controllers
  // What it is doing: These controllers hold the real-time input text for the question and its four options.
  final _questionController = TextEditingController();
  final _option1Controller = TextEditingController();
  final _option2Controller = TextEditingController();
  final _option3Controller = TextEditingController();
  final _option4Controller = TextEditingController();
  // Why we used `int?`: The radio buttons use an integer index (0-3) to select the correct answer. This variable holds the selected index.
  int? _correctAnswerIndex;
  // What it is doing: Tracks the asynchronous state of the 'Add Question' button.
  bool _isAdding = false;

  @override
  /// How it's helpful: Disposes of all `TextEditingController` instances to prevent memory leaks when the screen is closed.
  void dispose() {
    _questionController.dispose();
    _option1Controller.dispose();
    _option2Controller.dispose();
    _option3Controller.dispose();
    _option4Controller.dispose();
    super.dispose();
  }

  // --- Logic to Add a New Question ---
  /// What it is doing: Handles the full workflow for input validation and saving a new question to the database.
  Future<void> _addQuestion() async {
    // 1. Validate input
    // What it is doing: Gathers all option text into a list for validation.
    final options = [
      _option1Controller.text.trim(),
      _option2Controller.text.trim(),
      _option3Controller.text.trim(),
      _option4Controller.text.trim(),
    ];
    // How it is working: Checks if the main question field is empty.
    if (_questionController.text.trim().isEmpty) {
      _showError(AppStrings.questionMissing);
      return;
    }
    // How it is working: Checks if any of the four options fields were left empty.
    if (options.any((opt) => opt.isEmpty)) {
      _showError(AppStrings.optionsMissing);
      return;
    }
    // How it is working: Checks if the user has selected one of the radio buttons for the correct answer.
    if (_correctAnswerIndex == null) {
      _showError('Please select a correct answer.');
      return;
    }

    // What it is doing: Sets the loading state to disable the button and show a progress indicator.
    setState(() {
      _isAdding = true;
    });

    try {
      // 2. Create the QuestionModel
      // How it is working: Constructs the immutable data model required by the repository.
      final newQuestion = QuestionModel(
        questionId:
            '', // Will be set by Firestore (ID is autogenerated at the document level).
        questionText: _questionController.text.trim(),
        options: options,
        correctAnswerIndex:
            _correctAnswerIndex!, // The correct answer index (0, 1, 2, or 3) is saved.
      );

      // 3. Call the 'Chef' (QuizRepository)
      // How it is working: Calls the repository function to save the question to the `questions` sub-collection under the current quiz document.
      await ref
          .read(quizRepositoryProvider)
          .addQuestionToQuiz(quizId: widget.quiz.quizId, question: newQuestion);

      // 4. Show success and clear the form
      if (mounted) {
        _showError(AppStrings.questionAddedSuccess, isError: false);
        _clearForm();
      }
    } catch (e) {
      // What it is doing: Displays any error that occurred during the database transaction.
      _showError(e.toString());
    } finally {
      if (mounted) {
        // How it's helpful: Resets the loading state on success or failure.
        setState(() {
          _isAdding = false;
        });
      }
    }
  }

  // Helper to show SnackBar
  /// What it is doing: A utility function to display a temporary notification at the bottom of the screen.
  void _showError(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        // How it is working: Uses thematic colors (red for error, green for success) for visual clarity.
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }

  // Helper to clear form
  /// What it is doing: Clears all input fields and resets the correct answer selection.
  void _clearForm() {
    _questionController.clear();
    _option1Controller.clear();
    _option2Controller.clear();
    _option3Controller.clear();
    _option4Controller.clear();
    setState(() {
      _correctAnswerIndex = null;
    });
  }

  // --- Main Build Method ---
  @override
  /// What it is doing: Constructs the main screen layout, consisting of the Add Question form and the list of existing questions.
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.quiz.title}: ${AppStrings.manageQuestionsTitle}'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        // Why we used SingleChildScrollView: Ensures the content remains scrollable when the keyboard appears or on small screens.
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- 1. The "Add Question" Form ---
              _buildAddQuestionForm(context),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),

              // --- 2. The "All Questions" List ---
              Text(
                AppStrings.allQuestionsTitle,
                style: AppTextStyles.displaySmall,
              ),
              const SizedBox(height: 16),
              _buildQuestionsList(context),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widget: Add Question Form ---
  /// What it is doing: Builds the card containing the question input fields and the submission button.
  Widget _buildAddQuestionForm(BuildContext context) {
    // Why we used Card: To visually group the form elements and apply elevation/shadow.
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.createQuestionTitle,
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _questionController,
              label: AppStrings.questionLabel,
            ),
            const SizedBox(height: 16),
            // What it is doing: A custom widget wrapper to manage the selection state of the radio buttons.
            RadioGroup<int>(
              groupValue: _correctAnswerIndex,
              // How it is working: Updates the local state when a radio button is toggled.
              onChanged: (int? value) {
                setState(() {
                  _correctAnswerIndex = value;
                });
              },
              child: Column(
                children: [
                  // What it is doing: Calls the helper method to build the combination of a radio button and a text field for each option.
                  _buildOptionField(
                    context,
                    _option1Controller,
                    AppStrings.option1Label,
                    0,
                  ),
                  _buildOptionField(
                    context,
                    _option2Controller,
                    AppStrings.option2Label,
                    1,
                  ),
                  _buildOptionField(
                    context,
                    _option3Controller,
                    AppStrings.option3Label,
                    2,
                  ),
                  _buildOptionField(
                    context,
                    _option4Controller,
                    AppStrings.option4Label,
                    3,
                  ),
                ],
              ),
            ),

            // Options
            const SizedBox(height: 20),
            AppButton(
              text: AppStrings.addQuestionButton,
              onPressed: _isAdding
                  ? null
                  : _addQuestion, // Disables button when loading.
              isLoading: _isAdding,
            ),
          ],
        ),
      ),
    );
  }

  // Helper for text field + radio button
  /// What it is doing: Combines a radio button for correct answer selection with a `TextField` for the option's text.
  Widget _buildOptionField(
    BuildContext context,
    TextEditingController controller,
    String label,
    int index,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Radio<int>(
            value:
                index, // What it is doing: The unique index (0-3) for this option.
            activeColor: AppColors.primary,
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                // How it's helpful: Dynamically adds a tag (Correct Answer) next to the input field of the currently selected answer.
                labelText:
                    '$label ${_correctAnswerIndex == index ? "(${AppStrings.correctAnswerLabel})" : ""}',
                border: const OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widget: Questions List ---
  /// What it is doing: Fetches and displays a real-time list of all questions belonging to the current quiz.
  Widget _buildQuestionsList(BuildContext context) {
    // 1. Watch the 'Manager' (.family provider)
    // How it is working: Watches the `questionsProvider` using the `quizId` to establish a live stream connection to the specific sub-collection in Firestore.
    final questionsAsync = ref.watch(questionsProvider(widget.quiz.quizId));

    // 2. Use .when() to handle loading/error/data states
    return questionsAsync.when(
      // What it is doing: Shows a spinner while the initial data fetch is in progress.
      loading: () => const Center(child: CircularProgressIndicator()),
      // What it is doing: Displays a detailed error message if the stream fails to connect or data loading throws an exception.
      error: (error, stackTrace) => Center(
        child: Text(
          'Error loading questions. \n\n${error.toString()}',
          style: const TextStyle(color: AppColors.error),
        ),
      ),
      data: (questions) {
        // If the list is empty, show a message
        if (questions.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(AppStrings.noQuestionsFound),
            ),
          );
        }

        // If we have data, build the list
        return ListView.builder(
          itemCount: questions.length,
          // Why we used shrinkWrap and NeverScrollableScrollPhysics: To allow the list to size itself correctly within the parent `SingleChildScrollView` without scroll conflicts.
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final question = questions[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 2,
              child: ListTile(
                title: Text(question.questionText),
                // What it is doing: Displays the text of the correct option for quick verification.
                subtitle: Text(
                  'Correct: ${question.options[question.correctAnswerIndex]}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.primary),
                      onPressed: () {
                        // TODO: Implement Edit Question logic
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.error),
                      onPressed: () {
                        // TODO: Implement Delete Question logic
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

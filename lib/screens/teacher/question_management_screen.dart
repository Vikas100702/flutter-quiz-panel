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

class QuestionManagementScreen extends ConsumerStatefulWidget {
  // This screen needs to know which quiz it's managing
  final QuizModel quiz;

  const QuestionManagementScreen({
    super.key,
    required this.quiz,
  });

  @override
  ConsumerState<QuestionManagementScreen> createState() =>
      _QuestionManagementScreenState();
}

class _QuestionManagementScreenState
    extends ConsumerState<QuestionManagementScreen> {
  // Form controllers
  final _questionController = TextEditingController();
  final _option1Controller = TextEditingController();
  final _option2Controller = TextEditingController();
  final _option3Controller = TextEditingController();
  final _option4Controller = TextEditingController();
  // Radio buttons need a "group value" to track the selected option
  int? _correctAnswerIndex;
  bool _isAdding = false;

  @override
  void dispose() {
    _questionController.dispose();
    _option1Controller.dispose();
    _option2Controller.dispose();
    _option3Controller.dispose();
    _option4Controller.dispose();
    super.dispose();
  }

  // --- Logic to Add a New Question ---
  Future<void> _addQuestion() async {
    // 1. Validate input
    final options = [
      _option1Controller.text.trim(),
      _option2Controller.text.trim(),
      _option3Controller.text.trim(),
      _option4Controller.text.trim(),
    ];
    if (_questionController.text.trim().isEmpty) {
      _showError(AppStrings.questionMissing);
      return;
    }
    if (options.any((opt) => opt.isEmpty)) {
      _showError(AppStrings.optionsMissing);
      return;
    }
    if (_correctAnswerIndex == null) {
      _showError('Please select a correct answer.');
      return;
    }

    setState(() { _isAdding = true; });

    try {
      // 2. Create the QuestionModel
      final newQuestion = QuestionModel(
        questionId: '', // Will be set by Firestore
        questionText: _questionController.text.trim(),
        options: options,
        correctAnswerIndex: _correctAnswerIndex!,
      );

      // 3. Call the 'Chef' (QuizRepository)
      await ref.read(quizRepositoryProvider).addQuestionToQuiz(
        quizId: widget.quiz.quizId,
        question: newQuestion,
      );

      // 4. Show success and clear the form
      if (mounted) {
        _showError(AppStrings.questionAddedSuccess, isError: false);
        _clearForm();
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() { _isAdding = false; });
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

  // Helper to clear form
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.quiz.title}: ${AppStrings.manageQuestionsTitle}'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
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
  Widget _buildAddQuestionForm(BuildContext context) {
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
            RadioGroup<int>(
              groupValue: _correctAnswerIndex,
              onChanged: (int? value) {
                setState(() {
                  _correctAnswerIndex = value;
                });
              },
              child: Column(
                children: [
                  _buildOptionField(context, _option1Controller, AppStrings.option1Label, 0),
                  _buildOptionField(context, _option2Controller, AppStrings.option2Label, 1),
                  _buildOptionField(context, _option3Controller, AppStrings.option3Label, 2),
                  _buildOptionField(context, _option4Controller, AppStrings.option4Label, 3),
                ],
              ),
            ),
            // Options

            const SizedBox(height: 20),
            AppButton(
              text: AppStrings.addQuestionButton,
              onPressed: _isAdding ? null : _addQuestion,
              isLoading: _isAdding,
            ),
          ],
        ),
      ),
    );
  }

  // Helper for text field + radio button
  Widget _buildOptionField(BuildContext context, TextEditingController controller,
      String label, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Radio<int>(
            value: index,
            activeColor: AppColors.primary,
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: '$label ${_correctAnswerIndex == index ? "(${AppStrings.correctAnswerLabel})" : ""}',
                border: const OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }


  // --- Helper Widget: Questions List ---
  Widget _buildQuestionsList(BuildContext context) {
    // 1. Watch the 'Manager' (.family provider)
    //    We pass in the quizId from the widget.
    final questionsAsync = ref.watch(questionsProvider(widget.quiz.quizId));

    // 2. Use .when() to handle loading/error/data states
    return questionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
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
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final question = questions[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 2,
              child: ListTile(
                title: Text(question.questionText),
                subtitle: Text('Correct: ${question.options[question.correctAnswerIndex]}'),
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
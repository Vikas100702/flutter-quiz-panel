// lib/screens/teacher/quiz_management_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/models/quiz_model.dart'; // QuizModel import
import 'package:quiz_panel/utils/app_routes.dart';
import 'package:quiz_panel/models/subject_model.dart';
import 'package:quiz_panel/providers/quiz_provider.dart';
import 'package:quiz_panel/providers/user_data_provider.dart';
import 'package:quiz_panel/repositories/quiz_repository.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/utils/constants.dart';
import 'package:quiz_panel/widgets/buttons/app_button.dart';
import 'package:quiz_panel/widgets/inputs/app_text_field.dart';

class QuizManagementScreen extends ConsumerStatefulWidget {
  final SubjectModel subject;

  const QuizManagementScreen({super.key, required this.subject});

  @override
  ConsumerState<QuizManagementScreen> createState() =>
      _QuizManagementScreenState();
}

class _QuizManagementScreenState extends ConsumerState<QuizManagementScreen> {
  final _titleController = TextEditingController();
  final _durationController = TextEditingController(text: '25');
  final _questionsController = TextEditingController(text: '25');
  bool _isCreating = false;

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    _questionsController.dispose();
    super.dispose();
  }

  Future<void> _createQuiz() async {
    final teacherUid = ref.read(userDataProvider).value?.uid;
    if (teacherUid == null || teacherUid.isEmpty) {
      _showError('Error: Could not find teacher ID. Please re-login.');
      return;
    }
    if (_titleController.text.isEmpty) {
      _showError('Quiz Title cannot be empty.');
      return;
    }
    final duration = int.tryParse(_durationController.text);
    final totalQuestions = int.tryParse(_questionsController.text);

    if (duration == null || duration <= 0) {
      _showError('Please enter a valid duration.');
      return;
    }
    if (totalQuestions == null || totalQuestions <= 0) {
      _showError('Please enter a valid number of questions.');
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      await ref
          .read(quizRepositoryProvider)
          .createQuiz(
        title: _titleController.text.trim(),
        subjectId: widget.subject.subjectId,
        duration: duration,
        totalQuestions: totalQuestions,
        teacherUid: teacherUid,
        marksPerQuestion: 4,
      );

      if (mounted) {
        _showError(AppStrings.quizCreatedSuccess, isError: false);
        _titleController.clear();
        FocusScope.of(context).unfocus();
      }
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject.name),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
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
              _buildQuizzesList(context),
            ],
          ),
        ),
      ),
    );
  }

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
            // --- 1. YEH ROW AB WRAP HAI ---
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
                    label: AppStrings.totalQuestionsLabel,
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

  Widget _buildQuizzesList(BuildContext context) {
    final quizzesAsync = ref.watch(quizzesProvider(widget.subject.subjectId));

    return quizzesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) {
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
                  '${quiz.totalQuestions} ${AppStrings.totalQuestionsLabel} | ${quiz.durationMin} ${AppStrings.minutesLabel}',
                  style: AppTextStyles.bodyMedium,
                ),
                // --- FIX: Using Wrap instead of Row ---
                trailing: Wrap(
                  spacing: 4.0, // horizontal space
                  runSpacing: 4.0, // vertical space if it wraps
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Switch(
                      value: isPublished,
                      activeThumbColor: AppColors.success,
                      onChanged: (newValue) {
                        final newStatus = newValue
                            ? ContentStatus.published
                            : ContentStatus.draft;

                        ref
                            .read(quizRepositoryProvider)
                            .updateQuizStatus(
                          quizId: quiz.quizId,
                          newStatus: newStatus,
                        );

                        _showError(
                          newValue
                              ? AppStrings.quizPublished
                              : AppStrings.quizUnpublished,
                          isError: false,
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios),
                      tooltip: AppStrings.addQuestionsButton,
                      color: AppColors.textTertiary,
                      onPressed: () {
                        context.pushNamed(
                          AppRouteNames.questionManagement,
                          pathParameters: {'quizId': quiz.quizId},
                          extra: quiz,
                        );
                      },
                    ),
                  ],
                ),
                // --- END FIX ---
              ),
            );
          },
        );
      },
    );
  }
}
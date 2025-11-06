/*import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_panel/models/quiz_model.dart';
import 'package:quiz_panel/utils/app_strings.dart';

class QuizStartScreen extends ConsumerWidget {
  final QuizModel quiz;

  const QuizStartScreen({
    super.key,
    required this.quiz,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(quiz.title),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- 1. Instructions Title ---
                  Text(
                    AppStrings.quizInstructions,
                    style: textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // --- 2. Details (Total Questions) ---
                  _buildInstructionRow(
                    context,
                    icon: Icons.question_mark_rounded,
                    title: AppStrings.totalQuestionsLabel,
                    value: quiz.totalQuestions.toString(),
                  ),

                  // --- 3. Details (Time Limit) ---
                  _buildInstructionRow(
                    context,
                    icon: Icons.timer_rounded,
                    title: AppStrings.quizDurationLabel,
                    value: '${quiz.durationMin} ${AppStrings.minutesLabel}',
                  ),

                  // --- 4. Details (Marks) ---
                  _buildInstructionRow(
                    context,
                    icon: Icons.check_circle_rounded,
                    title: AppStrings.marksPerQuestionLabel,
                    value: quiz.marksPerQuestion.toString(),
                  ),

                  const SizedBox(height: 32),

                  // --- 5. Start Quiz Button ---
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    onPressed: () {
                      // TODO: (Step 7)
                      // Yahaan hum 'Quiz Attempt Screen' par navigate karenge
                      // context.pushReplacementNamed(
                      //   AppRouteNames.studentQuizAttempt,
                      //   pathParameters: {'quizId': quiz.quizId},
                      //   extra: quiz,
                      // );
                    },
                    child: Text(
                      AppStrings.startQuizButton,
                      style: textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionRow(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String value,
      }) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Text(title, style: textTheme.titleMedium),
          const Spacer(),
          Text(value, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- ZAROORI IMPORTS ---
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/utils/app_routes.dart';

// -----------------------
import 'package:quiz_panel/models/quiz_model.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/widgets/buttons/app_button.dart';

class QuizStartScreen extends ConsumerWidget {
  final QuizModel quiz;

  const QuizStartScreen({super.key, required this.quiz});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(quiz.title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- 1. Instructions Title ---
                  Text(
                    AppStrings.quizInstructions,
                    style: AppTextStyles.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // --- 2. Details (Total Questions) ---
                  _buildInstructionRow(
                    context,
                    icon: Icons.question_mark_rounded,
                    title: AppStrings.totalQuestionsLabel,
                    value: quiz.totalQuestions.toString(),
                  ),

                  // --- 3. Details (Time Limit) ---
                  _buildInstructionRow(
                    context,
                    icon: Icons.timer_rounded,
                    title: AppStrings.quizDurationLabel,
                    value: '${quiz.durationMin} ${AppStrings.minutesLabel}',
                  ),

                  // --- 4. Details (Marks) ---
                  _buildInstructionRow(
                    context,
                    icon: Icons.check_circle_rounded,
                    title: AppStrings.marksPerQuestionLabel,
                    value: quiz.marksPerQuestion.toString(),
                  ),

                  const SizedBox(height: 32),

                  // --- 5. Start Quiz Button ---
                  AppButton(
                    text: AppStrings.startQuizButton,
                    type: AppButtonType.primary,
                    onPressed: () {
                      context.pushReplacementNamed(
                        AppRouteNames.studentQuizAttempt,
                        pathParameters: {'quizId': quiz.quizId},
                        extra: quiz,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 16),
          Text(title, style: AppTextStyles.titleMedium),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

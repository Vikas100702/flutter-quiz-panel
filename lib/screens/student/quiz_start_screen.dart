// lib/screens/student/quiz_start_screen.dart

/*
Why we used this file:
This screen acts as the mandatory pre-quiz lobby, ensuring the student is
aware of the quiz rules and instructions before starting the timer.

How it's helpful:
It separates the instructional phase from the timed attempt phase, providing a
clear 'Start' button to prevent accidental quiz initiation and unauthorized access.
*/
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/utils/app_routes.dart';
import 'package:quiz_panel/models/quiz_model.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/widgets/buttons/app_button.dart';

/// Why we used this Widget:
/// This is a stateless widget that displays the core metadata of a quiz and manages the start navigation.
class QuizStartScreen extends ConsumerWidget {
  /// What it is doing: The QuizModel object, passed from the subject quiz list,
  /// contains all the necessary instructions (duration, question count, marks).
  final QuizModel quiz;

  const QuizStartScreen({super.key, required this.quiz});

  @override
  /// What it is doing: Builds the instruction card centered on the screen.
  /// How it is working: Consumes no application state directly but uses `WidgetRef` for navigation.
  Widget build(BuildContext context, WidgetRef ref) {
    // final textTheme = Theme.of(context).textTheme; // Unused variable from original code

    return Scaffold(
      appBar: AppBar(title: Text(quiz.title)),
      body: Center(
        /// How it's helpful: Constrains the width of the instruction card for optimal
        /// readability on both mobile and web/desktop interfaces.
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                // How it is working: Uses mainAxisSize.min to wrap content vertically.
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
                  // What it is doing: Displays the total number of questions in the quiz.
                  _buildInstructionRow(
                    context,
                    icon: Icons.question_mark_rounded,
                    title: AppStrings.totalQuestionsLabel,
                    value: quiz.totalQuestions.toString(),
                  ),

                  // --- 3. Details (Time Limit) ---
                  // What it is doing: Displays the time limit in minutes.
                  _buildInstructionRow(
                    context,
                    icon: Icons.timer_rounded,
                    title: AppStrings.quizDurationLabel,
                    value: '${quiz.durationMin} ${AppStrings.minutesLabel}',
                  ),

                  // --- 4. Details (Marks) ---
                  // What it is doing: Displays the marks awarded for each correct answer.
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
                      // How it is working: Navigates to the live attempt screen.
                      // pushReplacementNamed ensures the user cannot press the 'back' button
                      // from the QuizAttemptScreen to return to the Start Screen.
                      context.pushReplacementNamed(
                        AppRouteNames.studentQuizAttempt,
                        pathParameters: {'quizId': quiz.quizId},
                        extra: quiz, // Pass the quiz model to the attempt screen.
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

  /// What it is doing: A reusable helper widget to display a single instruction detail line.
  /// How it's helpful: Ensures consistent styling for icon, title, and value across all instructions.
  Widget _buildInstructionRow(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String value,
      }) {
    // final textTheme = Theme.of(context).textTheme; // Unused variable from original code
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // Left side: Icon (styled with primary color)
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 16),
          // Middle: Instruction Title
          Text(title, style: AppTextStyles.titleMedium),
          // Spacer pushes the value to the far right.
          const Spacer(),
          // Right side: Instruction Value (styled boldly)
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
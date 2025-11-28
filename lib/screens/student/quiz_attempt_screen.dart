// lib/screens/student/quiz_attempt_screen.dart

// Why we used this file:
// This is the core screen where a student actively participates in a quiz.
// It serves as the live interface for:
// 1. Displaying questions and options.
// 2. Starting and managing the countdown timer.
// 3. Capturing the student's chosen answers.
// 4. Handling navigation between questions and the final submission.
//
// How it's helpful:
// It orchestrates the entire quiz attempt lifecycle, ensuring state is consistent
// and that the quiz automatically ends upon timer expiration.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/utils/app_routes.dart';
import 'package:quiz_panel/models/quiz_attempt_state.dart';
import 'package:quiz_panel/models/quiz_model.dart';
import 'package:quiz_panel/providers/quiz_attempt_provider.dart';
import 'package:quiz_panel/utils/app_strings.dart';

// What it is doing: Manages the dynamic UI state and interactions for an active quiz.
class QuizAttemptScreen extends ConsumerStatefulWidget {
  // How it is working: Requires the specific QuizModel as an argument, which is
  // then passed to the Riverpod family provider to create a unique game state.
  final QuizModel quiz;
  const QuizAttemptScreen({super.key, required this.quiz});

  @override
  ConsumerState<QuizAttemptScreen> createState() => _QuizAttemptScreenState();
}

class _QuizAttemptScreenState extends ConsumerState<QuizAttemptScreen> {
  @override
  // What it is doing: Initializes the quiz state immediately after the screen is rendered.
  void initState() {
    super.initState();
    // How it is working: Uses addPostFrameCallback to ensure the widget tree is fully built
    // before attempting to start the quiz logic, preventing potential errors.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Calls the QuizAttemptNotifier's startQuiz function to fetch questions and begin the timer.
      ref.read(quizAttemptProvider(widget.quiz).notifier).startQuiz();
    });
  }

  // What it is doing: Converts the total number of seconds into a user-friendly "MM:SS" time format.
  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    // Uses padLeft to ensure minutes and seconds are always two digits (e.g., 05:03).
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  // What it is doing: Displays a modal dialog asking the user to confirm their quiz submission.
  Future<void> _showSubmitDialog(BuildContext context, WidgetRef ref) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(AppStrings.submitQuizTitle),
          content: const Text(AppStrings.submitQuizMessage),
          actions: <Widget>[
            TextButton(
              child: const Text(AppStrings.cancelButton),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Closes the dialog.
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(AppStrings.submitButton),
              onPressed: () {
                // Step 1: Close the dialog.
                Navigator.of(dialogContext).pop();

                // Step 2: Trigger the submission logic.
                // How it is working: The Notifier calculates the score and changes the QuizStatus to 'finished'.
                ref.read(quizAttemptProvider(widget.quiz).notifier).submitQuiz();

                // Step 3: Navigate to the result screen.
                // How it is helpful: pushReplacementNamed is used to replace the current screen in the navigation stack,
                // preventing the user from accidentally pressing 'back' and returning to the completed quiz.
                context.pushReplacementNamed(
                  AppRouteNames.studentQuizResult,
                  pathParameters: {'quizId': widget.quiz.quizId},
                  extra: widget.quiz, // Passes the QuizModel object for the result screen to use.
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  // What it is doing: The primary build method for the entire screen structure.
  Widget build(BuildContext context) {
    // How it is working: Watches the live quiz attempt state. Any change in the timer,
    // question index, or status triggers a UI update.
    final state = ref.watch(quizAttemptProvider(widget.quiz));
    // What it is doing: Reads the Notifier (logic controller) to call functions like nextQuestion/submitQuiz.
    final notifier = ref.read(quizAttemptProvider(widget.quiz).notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(state.quiz.title),
        actions: [
          // Displays the live countdown timer only when the quiz is active.
          if (state.status == QuizStatus.active)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined),
                    const SizedBox(width: 4),
                    // Shows the time formatted as MM:SS.
                    Text(
                      _formatDuration(state.secondsRemaining),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      // The body content changes based on the current quiz status (loading, active, error).
      body: _buildBody(state, notifier),
      // The bottom navigation bar (Next/Previous/Submit buttons) is only visible when the quiz is running.
      bottomNavigationBar:
      state.status == QuizStatus.active ? _buildBottomNavBar(state, notifier) : null,
    );
  }

  // What it is doing: Selects the appropriate screen content based on the QuizStatus.
  Widget _buildBody(QuizAttemptState state, QuizAttemptNotifier notifier) {
    switch (state.status) {
      case QuizStatus.initial:
      case QuizStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case QuizStatus.error:
        return Center(child: Text('Error: ${state.error}'));
      case QuizStatus.active:
      // How it is helpful: Uses LayoutBuilder to implement responsive design, allowing
      // for a two-panel layout on wide (desktop) screens.
        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 800) {
              // Desktop Layout: Question Panel (70%) + Navigation Grid (30%).
              return Row(
                children: [
                  Expanded(
                    flex: 7,
                    child: _buildQuestionPanel(state, notifier),
                  ),
                  Expanded(
                    flex: 3,
                    child: _buildQuestionGrid(state, notifier),
                  ),
                ],
              );
            } else {
              // Mobile Layout: Only the Question Panel.
              return _buildQuestionPanel(state, notifier);
            }
          },
        );
      case QuizStatus.finished:
      // This state is immediately followed by navigation in _showSubmitDialog, so this is just a transient message.
        return const Center(child: Text('Navigating to results...'));
    }
  }

  // What it is doing: Builds the main content area showing the current question and clickable options.
  Widget _buildQuestionPanel(QuizAttemptState state, QuizAttemptNotifier notifier) {
    // Fetches the current question object based on the currentQuestionIndex.
    final question = state.questions[state.currentQuestionIndex];
    // Retrieves the index of the option the user previously selected for this question.
    final selectedAnswer = state.userAnswers[question.questionId];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Number Indicator
          Text(
            'Question ${state.currentQuestionIndex + 1} of ${state.questions.length}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          // Actual Question Text
          Text(
            question.questionText,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          // List of Options (A, B, C, D)
          ListView.builder(
            itemCount: question.options.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final option = question.options[index];
              final isSelected = (selectedAnswer == index); // Checks if this option is the selected one.

              return Card(
                elevation: isSelected ? 4 : 1,
                // Visually highlights the selected option.
                color: isSelected
                    ? Colors.blue.withValues(alpha: 0.1) // Fix: Changed withValues(alpha: 0.1) to withValues(alpha: )(0.1) for correct Flutter syntax.
                    : Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected ? Colors.blue : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    // Shows the option letter (A, B, C, D).
                    backgroundColor:
                    isSelected ? Colors.blue : Colors.grey.shade200,
                    child: Text(
                      String.fromCharCode(65 + index), // ASCII for 'A' is 65.
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  title: Text(option),
                  onTap: () {
                    // How it is working: Calls the notifier to record the user's choice.
                    notifier.selectAnswer(question.questionId, index);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // What it is doing: Builds a navigation grid (1, 2, 3...) for quickly jumping between questions (Desktop Only).
  Widget _buildQuestionGrid(QuizAttemptState state, QuizAttemptNotifier notifier) {
    return Container(
      // Fix: Changed withValues(alpha: 0.5) to withValues(alpha: )(0.5) for correct Flutter syntax.
      color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.5),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Questions',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              itemCount: state.questions.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final questionId = state.questions[index].questionId;
                final isAnswered = state.userAnswers.containsKey(questionId);
                final isCurrent = (state.currentQuestionIndex == index);

                return ActionChip(
                  label: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: isCurrent ? Colors.white : Colors.black87,
                    ),
                  ),
                  // Color coding: Blue=Current, Green=Answered, Grey=Skipped.
                  backgroundColor: isCurrent
                      ? Colors.blue
                      : isAnswered
                      ? Colors.green.shade100
                      : Colors.grey.shade200,
                  onPressed: () {
                    // TODO: Implement Jump to Question logic
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // What it is doing: Builds the bottom bar containing navigation and submission controls.
  Widget _buildBottomNavBar(QuizAttemptState state, QuizAttemptNotifier notifier) {
    final bool isFirstQuestion = state.currentQuestionIndex == 0;
    final bool isLastQuestion = state.currentQuestionIndex == state.questions.length - 1;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      // How it is helpful: Uses a Wrap widget instead of a simple Row. This ensures
      // buttons stack vertically on very small mobile screens (like landscape view),
      // preventing overflow errors.
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        runAlignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8.0,
        runSpacing: 12.0,
        children: [
          // Previous Button (disabled on the first question).
          ElevatedButton.icon(
            icon: const Icon(Icons.arrow_back),
            label: const Text(AppStrings.previousButton),
            onPressed: isFirstQuestion ? null : () => notifier.previousQuestion(),
          ),

          // Submit Button (triggers the confirmation dialog).
          ElevatedButton.icon(
            icon: const Icon(Icons.check_circle, color: Colors.white),
            label: const Text(AppStrings.submitButton, style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => _showSubmitDialog(context, ref),
          ),

          // Next Button (disabled on the last question).
          ElevatedButton.icon(
            icon: const Icon(Icons.arrow_forward),
            label: const Text(AppStrings.nextButton),
            onPressed: isLastQuestion ? null : () => notifier.nextQuestion(),
          ),
        ],
      ),
    );
  }
}
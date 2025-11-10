/*
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_panel/models/quiz_attempt_state.dart';
import 'package:quiz_panel/models/quiz_model.dart';
import 'package:quiz_panel/providers/quiz_attempt_provider.dart';
import 'package:quiz_panel/utils/app_strings.dart';

// Yeh main screen hai jahaan student quiz dega
class QuizAttemptScreen extends ConsumerStatefulWidget {
  final QuizModel quiz;
  const QuizAttemptScreen({super.key, required this.quiz});

  @override
  ConsumerState<QuizAttemptScreen> createState() => _QuizAttemptScreenState();
}

class _QuizAttemptScreenState extends ConsumerState<QuizAttemptScreen> {
  @override
  void initState() {
    super.initState();
    // Screen load hote hi, quiz start karne ka signal bhejein
    // Hum 'addPostFrameCallback' ka istemaal karte hain taaki build complete hone ke baad call ho
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quizAttemptProvider(widget.quiz).notifier).startQuiz();
    });
  }

  // Helper function: Seconds ko "MM:SS" format mein dikhana
  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  // Submit confirmation dialog
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
                Navigator.of(dialogContext).pop(); // Dialog band karein
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(AppStrings.submitButton),
              onPressed: () {
                // Notifier ko call karke quiz submit karein
                ref.read(quizAttemptProvider(widget.quiz).notifier).submitQuiz();
                Navigator.of(dialogContext).pop(); // Dialog band karein
                // TODO: Result screen par navigate karein
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Hum 'quizAttemptProvider' ko watch karenge
    final state = ref.watch(quizAttemptProvider(widget.quiz));
    // Hum 'notifier' ko bhi get karenge taaki functions call kar sakein
    final notifier = ref.read(quizAttemptProvider(widget.quiz).notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(state.quiz.title),
        actions: [
          // --- Timer ---
          if (state.status == QuizStatus.active)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined),
                    const SizedBox(width: 4),
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
      body: _buildBody(state, notifier),
      bottomNavigationBar:
      state.status == QuizStatus.active ? _buildBottomNavBar(state, notifier) : null,
    );
  }

  // Body ka content state ke hisaab se dikhayein
  Widget _buildBody(QuizAttemptState state, QuizAttemptNotifier notifier) {
    switch (state.status) {
      case QuizStatus.initial:
      case QuizStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case QuizStatus.error:
        return Center(child: Text('Error: ${state.error}'));
      case QuizStatus.active:
      // Responsive layout ka istemaal karein
        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 800) {
              // --- Desktop Layout ---
              return Row(
                children: [
                  // Main Question Area (70% width)
                  Expanded(
                    flex: 7,
                    child: _buildQuestionPanel(state, notifier),
                  ),
                  // Question Grid (30% width)
                  Expanded(
                    flex: 3,
                    child: _buildQuestionGrid(state, notifier),
                  ),
                ],
              );
            } else {
              // --- Mobile Layout ---
              return _buildQuestionPanel(state, notifier);
            }
          },
        );
      case QuizStatus.finished:
      // TODO: Yahaan se Result Screen par navigate karein
        return const Center(child: Text('Quiz Submitted!'));
    }
  }

  // Widget: Question + Options
  Widget _buildQuestionPanel(QuizAttemptState state, QuizAttemptNotifier notifier) {
    final question = state.questions[state.currentQuestionIndex];
    final selectedAnswer = state.userAnswers[question.questionId];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Number
          Text(
            'Question ${state.currentQuestionIndex + 1} of ${state.questions.length}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          // Question Text
          Text(
            question.questionText,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          // Options
          ListView.builder(
            itemCount: question.options.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final option = question.options[index];
              final isSelected = (selectedAnswer == index);

              return Card(
                elevation: isSelected ? 4 : 1,
                color: isSelected
                    ? Colors.blue.withOpacity(0.1)
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
                    backgroundColor:
                    isSelected ? Colors.blue : Colors.grey.shade200,
                    child: Text(
                      String.fromCharCode(65 + index), // A, B, C, D
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  title: Text(option),
                  onTap: () {
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

  // Widget: Question Navigation Grid (Sirf Desktop)
  Widget _buildQuestionGrid(QuizAttemptState state, QuizAttemptNotifier notifier) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
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
                  backgroundColor: isCurrent
                      ? Colors.blue
                      : isAnswered
                      ? Colors.green.shade100
                      : Colors.grey.shade200,
                  onPressed: () {
                    // TODO: Jump to question logic
                    // notifier.jumpToQuestion(index);
                    // Abhi ke liye, hum sirf next/prev support kar rahe hain
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget: Bottom Navigation Bar (Prev, Next, Submit)
  Widget _buildBottomNavBar(QuizAttemptState state, QuizAttemptNotifier notifier) {
    final bool isFirstQuestion = state.currentQuestionIndex == 0;
    final bool isLastQuestion = state.currentQuestionIndex == state.questions.length - 1;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // --- Previous Button ---
          ElevatedButton.icon(
            icon: const Icon(Icons.arrow_back),
            label: const Text(AppStrings.previousButton),
            onPressed: isFirstQuestion ? null : () => notifier.previousQuestion(),
          ),

          // --- Submit Button ---
          ElevatedButton.icon(
            icon: const Icon(Icons.check_circle, color: Colors.white),
            label: const Text(AppStrings.submitButton, style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => _showSubmitDialog(context, ref),
          ),

          // --- Next Button ---
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
*/


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// --- ZAROORI IMPORTS ---
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/utils/app_routes.dart';
// -----------------------
import 'package:quiz_panel/models/quiz_attempt_state.dart';
import 'package:quiz_panel/models/quiz_model.dart';
import 'package:quiz_panel/providers/quiz_attempt_provider.dart';
import 'package:quiz_panel/utils/app_strings.dart';

// Yeh main screen hai jahaan student quiz dega
class QuizAttemptScreen extends ConsumerStatefulWidget {
  final QuizModel quiz;
  const QuizAttemptScreen({super.key, required this.quiz});

  @override
  ConsumerState<QuizAttemptScreen> createState() => _QuizAttemptScreenState();
}

class _QuizAttemptScreenState extends ConsumerState<QuizAttemptScreen> {
  @override
  void initState() {
    super.initState();
    // Screen load hote hi, quiz start karne ka signal bhejein
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quizAttemptProvider(widget.quiz).notifier).startQuiz();
    });
  }

  // Helper function: Seconds ko "MM:SS" format mein dikhana
  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  // Submit confirmation dialog (Updated)
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
                Navigator.of(dialogContext).pop(); // Dialog band karein
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(AppStrings.submitButton),
              onPressed: () {
                // 1. Dialog band karein
                Navigator.of(dialogContext).pop();

                // 2. Notifier ko call karke score calculate aur state update karein
                ref.read(quizAttemptProvider(widget.quiz).notifier).submitQuiz();

                // 3. Result screen par navigate karein
                // pushReplacementNamed ka istemaal karein taaki user 'back' na kar sake
                context.pushReplacementNamed(
                  AppRouteNames.studentQuizResult,
                  pathParameters: {'quizId': widget.quiz.quizId},
                  extra: widget.quiz,
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quizAttemptProvider(widget.quiz));
    final notifier = ref.read(quizAttemptProvider(widget.quiz).notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(state.quiz.title),
        actions: [
          if (state.status == QuizStatus.active)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined),
                    const SizedBox(width: 4),
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
      body: _buildBody(state, notifier),
      bottomNavigationBar:
      state.status == QuizStatus.active ? _buildBottomNavBar(state, notifier) : null,
    );
  }

  // Body ka content state ke hisaab se dikhayein
  Widget _buildBody(QuizAttemptState state, QuizAttemptNotifier notifier) {
    switch (state.status) {
      case QuizStatus.initial:
      case QuizStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case QuizStatus.error:
        return Center(child: Text('Error: ${state.error}'));
      case QuizStatus.active:
        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 800) {
              // --- Desktop Layout ---
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
              // --- Mobile Layout ---
              return _buildQuestionPanel(state, notifier);
            }
          },
        );
      case QuizStatus.finished:
      // Score calculation logic ab submitQuiz mein hai.
      // Yahaan hum Result Screen par navigate karne ke liye wait karenge.
      // Kyunki humne Result Screen ko connect kar diya hai, yeh screen visible nahi honi chahiye.
        return const Center(child: Text('Navigating to results...'));
    }
  }

  // (Baaki helper functions _buildQuestionPanel, _buildQuestionGrid, _buildBottomNavBar yahaan continue honge)
  // --- Widget: Question + Options (No change) ---
  Widget _buildQuestionPanel(QuizAttemptState state, QuizAttemptNotifier notifier) {
    final question = state.questions[state.currentQuestionIndex];
    final selectedAnswer = state.userAnswers[question.questionId];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Number
          Text(
            'Question ${state.currentQuestionIndex + 1} of ${state.questions.length}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          // Question Text
          Text(
            question.questionText,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          // Options
          ListView.builder(
            itemCount: question.options.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final option = question.options[index];
              final isSelected = (selectedAnswer == index);

              return Card(
                elevation: isSelected ? 4 : 1,
                color: isSelected
                    ? Colors.blue.withOpacity(0.1)
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
                    backgroundColor:
                    isSelected ? Colors.blue : Colors.grey.shade200,
                    child: Text(
                      String.fromCharCode(65 + index), // A, B, C, D
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  title: Text(option),
                  onTap: () {
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

  // --- Widget: Question Navigation Grid (No change) ---
  Widget _buildQuestionGrid(QuizAttemptState state, QuizAttemptNotifier notifier) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
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
                  backgroundColor: isCurrent
                      ? Colors.blue
                      : isAnswered
                      ? Colors.green.shade100
                      : Colors.grey.shade200,
                  onPressed: () {
                    // TODO: Jump to question logic
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget: Bottom Navigation Bar (No change) ---
  Widget _buildBottomNavBar(QuizAttemptState state, QuizAttemptNotifier notifier) {
    final bool isFirstQuestion = state.currentQuestionIndex == 0;
    final bool isLastQuestion = state.currentQuestionIndex == state.questions.length - 1;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      // --- FIX: Using Wrap instead of Row ---
      child: Wrap(
        alignment: WrapAlignment.spaceBetween, // Horizontal jaisa behave karega jab tak space hai
        runAlignment: WrapAlignment.center, // Center mein align karega jab wrap hoga
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8.0, // Buttons ke beech horizontal space
        runSpacing: 12.0, // Buttons ke beech vertical space (jab wrap ho)
        children: [
          // --- Previous Button ---
          ElevatedButton.icon(
            icon: const Icon(Icons.arrow_back),
            label: const Text(AppStrings.previousButton),
            onPressed: isFirstQuestion ? null : () => notifier.previousQuestion(),
          ),

          // --- Submit Button ---
          ElevatedButton.icon(
            icon: const Icon(Icons.check_circle, color: Colors.white),
            label: const Text(AppStrings.submitButton, style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => _showSubmitDialog(context, ref),
          ),

          // --- Next Button ---
          ElevatedButton.icon(
            icon: const Icon(Icons.arrow_forward),
            label: const Text(AppStrings.nextButton),
            onPressed: isLastQuestion ? null : () => notifier.nextQuestion(),
          ),
        ],
      ),
      // --- END FIX ---
    );
  }
}
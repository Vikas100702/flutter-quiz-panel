import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/models/quiz_attempt_state.dart';
import 'package:quiz_panel/models/quiz_model.dart';
import 'package:quiz_panel/providers/quiz_attempt_provider.dart';
import 'package:quiz_panel/utils/app_routes.dart';
import 'package:quiz_panel/utils/app_strings.dart';

class QuizResultScreen extends ConsumerWidget {
  final QuizModel quiz;
  const QuizResultScreen({super.key, required this.quiz});

  // Helper widget to display a single metric card
  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required int value,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.5), width: 1),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 200, // Fixed width for desktop layout
        child: Column(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch the QuizAttemptProvider
    final resultState = ref.watch(quizAttemptProvider(quiz));

    // Agar state 'finished' nahi hai, toh kuch galat hai
    if (resultState.status != QuizStatus.finished) {
      // Safety check: Agar user seedhe URL se yahaan aaye
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Quiz abhi khatam nahi hua hai ya koi error hai.'),
              TextButton(
                onPressed: () => context.go(AppRoutePaths.studentDashboard),
                child: const Text('Go to Dashboard'),
              ),
            ],
          ),
        ),
      );
    }

    // 2. Score aur Max Score calculate karein
    final totalQuestions = resultState.questions.length;
    final maxScore = resultState.quiz.totalQuestions * resultState.quiz.marksPerQuestion;
    final percentage = (resultState.score / maxScore) * 100;
    final bool passed = percentage >= 40; // Example passing criteria: 40%

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Back button nahi dikhana
        title: Text('${quiz.title}: ${AppStrings.resultsTitle}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: AppStrings.backToDashboardButton,
            onPressed: () => context.go(AppRoutePaths.studentDashboard),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- 3. Pass/Fail Status and Main Score ---
                Text(
                  passed ? AppStrings.congratulations : AppStrings.betterLuckNextTime,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: passed ? Colors.green.shade800 : Colors.red.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Main Score Card
                Card(
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Text(
                          AppStrings.finalScore,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${resultState.score} / $maxScore',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: passed ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // --- 4. Metrics Breakdown (Correct/Incorrect/Unanswered) ---
                Text(
                  AppStrings.scoreBreakdown,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Divider(height: 20),

                // Responsive view for score metrics
                Center(
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildMetricCard(
                        context: context,
                        title: AppStrings.totalQuestions,
                        value: totalQuestions,
                        color: Colors.blueGrey,
                      ),
                      _buildMetricCard(
                        context: context,
                        title: AppStrings.correctAnswers,
                        value: resultState.totalCorrect,
                        color: Colors.green,
                      ),
                      _buildMetricCard(
                        context: context,
                        title: AppStrings.incorrectAnswers,
                        value: resultState.totalIncorrect,
                        color: Colors.red,
                      ),
                      _buildMetricCard(
                        context: context,
                        title: AppStrings.unansweredQuestions,
                        value: resultState.totalUnanswered,
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // --- 5. Review Button (Future scope) ---
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement Review/Detailed Analysis Screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Detailed analysis is coming soon!')),
                    );
                  },
                  icon: const Icon(Icons.analytics),
                  label: Text(AppStrings.reviewYourAnswers),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// --- ZAROORI IMPORTS ---
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/utils/app_routes.dart';
import 'package:quiz_panel/models/quiz_model.dart'; // QuizModel import kiya
// -----------------------

import 'package:quiz_panel/models/subject_model.dart';
import 'package:quiz_panel/providers/quiz_provider.dart';
import 'package:quiz_panel/utils/app_strings.dart';

class StudentQuizListScreen extends ConsumerWidget {
  final SubjectModel subject;

  const StudentQuizListScreen({
    super.key,
    required this.subject,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // publishedQuizzesProvider ko watch kar rahe hain
    final quizzesAsync = ref.watch(publishedQuizzesProvider(subject.subjectId));

    return Scaffold(
      appBar: AppBar(
        title: Text(subject.name),
      ),
      body: quizzesAsync.when(
        // 2. Loading State
        loading: () => const Center(child: CircularProgressIndicator()),

        // 3. Error State (Index missing error handling)
        error: (error, stackTrace) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '${AppStrings.firestoreIndexError}\n\nError: ${error.toString()}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },

        // 4. Data State
        data: (quizzes) {
          // Agar koi quiz published nahi hai
          if (quizzes.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(AppStrings.noQuizzesAvailable),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(quiz.title,
                      style: Theme.of(context).textTheme.titleMedium),
                  subtitle: Text(
                    // AppStrings se minutes label ka istemaal karein
                    '${quiz.totalQuestions} Questions | ${quiz.durationMin} ${AppStrings.minutesLabel}',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // --- FINAL NAVIGATION LOGIC ---
                    context.pushNamed(
                      AppRouteNames.studentQuizStart, // QuizStartScreen ka route name
                      pathParameters: {'quizId': quiz.quizId},
                      extra: quiz, // Poora quiz object pass karein
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

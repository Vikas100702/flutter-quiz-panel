// lib/screens/student/student_quiz_list_screen.dart

/*
Why we used this file:
This screen is used by the student role to view all available quizzes
that belong to a specific subject.

How it's helpful:
It dynamically fetches the list of quizzes using the subject's ID and only
displays those that have been marked as 'published' by a teacher, ensuring
students do not access incomplete or draft content. It provides the navigation
link to start the quiz attempt process.
*/
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/utils/app_routes.dart';
import 'package:quiz_panel/models/subject_model.dart';
import 'package:quiz_panel/providers/quiz_provider.dart';
import 'package:quiz_panel/utils/app_strings.dart';

/// Why we used this Widget:
/// This widget displays a list of published quizzes for a given subject.
/// It uses a ConsumerWidget as it only needs to read (watch) the quiz data stream.
class StudentQuizListScreen extends ConsumerWidget {
  /// What it is doing: Requires the subject data object to fetch quizzes linked to this ID.
  final SubjectModel subject;

  const StudentQuizListScreen({super.key, required this.subject});

  @override
  /// What it is doing: Builds the screen interface, displaying quiz cards fetched from the provider.
  /// How it is working: Uses the Riverpod `AsyncValue.when` pattern to manage the display state.
  Widget build(BuildContext context, WidgetRef ref) {
    // What it is doing: Watches the publishedQuizzesProvider, passing the subject ID.
    // How it is working: This creates a live stream of only the published QuizModel list, automatically updating the UI.
    final quizzesAsync = ref.watch(publishedQuizzesProvider(subject.subjectId));

    return Scaffold(
      appBar: AppBar(title: Text(subject.name)),
      body: quizzesAsync.when(
        // 1. Loading State: Display a central progress indicator.
        loading: () => const Center(child: CircularProgressIndicator()),

        // 2. Error State: Handle data fetching errors, particularly missing Firestore indexes.
        error: (error, stackTrace) {
          // What it is doing: Shows a user-friendly message for a common Firestore error (missing index).
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

        // 3. Data State: Display the list of quizzes.
        data: (quizzes) {
          // What it is doing: Checks if the published list is empty.
          if (quizzes.isEmpty) {
            // How it's helpful: Shows a clear message if no content is available for the subject.
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
                  title: Text(
                    quiz.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    // What it is doing: Displays quiz metadata (question count and duration).
                    '${quiz.totalQuestions} Questions | ${quiz.durationMin} ${AppStrings.minutesLabel}',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // --- FINAL NAVIGATION LOGIC ---
                    // How it is working: Navigates to the QuizStartScreen to show instructions before starting.
                    context.pushNamed(
                      AppRouteNames
                          .studentQuizStart, // QuizStartScreen route name
                      pathParameters: {'quizId': quiz.quizId},
                      extra:
                          quiz, // Passes the full quiz object to the next screen.
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

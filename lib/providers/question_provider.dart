// lib/providers/question_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_panel/models/question_model.dart';
import 'package:quiz_panel/repositories/quiz_repository.dart';

/// **Why we used this Provider (questionsProvider):**
/// This provider acts as the "Question Loader" for a specific quiz.
/// When a Teacher clicks on a quiz to "Manage Questions", this provider fetches the list of
/// questions inside that quiz from the database.
///
/// **How it helps:**
/// It creates a "Live Connection" (Stream). If the teacher adds a new question,
/// the list updates automatically without needing to refresh the page.
///
/// **Key Features:**
/// 1. **.family:** This allows us to pass the `quizId` (String) as an input.
///    We need this because we are not fetching *all* questions, just the ones for *this* quiz.
/// 2. **.autoDispose:** As soon as the teacher goes back to the dashboard, this provider
///    stops listening to the database. This saves internet data and memory.
final questionsProvider = StreamProvider.autoDispose
    .family<List<QuestionModel>, String>((ref, quizId) {
      // 1. Get the tool (Repository) that knows how to talk to the database.
      //    'ref.watch' ensures we always use the latest version of the repository.
      final quizRepo = ref.watch(quizRepositoryProvider);

      // 2. Ask the repository to fetch the questions for the specific 'quizId'.
      //    This returns a Stream<List<QuestionModel>>.
      return quizRepo.getQuestionsForQuiz(quizId);
    });

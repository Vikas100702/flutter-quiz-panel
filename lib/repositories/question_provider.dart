import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_panel/models/question_model.dart';
import 'package:quiz_panel/repositories/quiz_repository.dart';

// This is our new 'Manager'.
// It is a 'StreamProvider.autoDispose.family'
// .autoDispose: Cleans up when the UI is not watching it.
// .family: Allows us to pass one parameter (the 'quizId' as a String)
//
// It provides a List of QuestionModels...
// for a specific 'quizId' (String).
final questionsProvider =
StreamProvider.autoDispose.family<List<QuestionModel>, String>((ref, quizId) {

  // 2. Watch the 'Chef' (QuizRepository)
  final quizRepo = ref.watch(quizRepositoryProvider);

  // 3. Call the 'getQuestionsForQuiz' function,
  //    passing in the 'quizId' we received from the .family
  return quizRepo.getQuestionsForQuiz(quizId);
});


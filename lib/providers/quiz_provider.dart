import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_panel/models/quiz_model.dart';
import 'package:quiz_panel/repositories/quiz_repository.dart';

// --- 1. Provider for TEACHER Quiz Management Screen ---
final quizzesProvider =
StreamProvider.autoDispose.family<List<QuizModel>, String>((ref, subjectId) {
  if (subjectId.isEmpty) {
    return Stream.value([]);
  }

  // 2. Watch the (QuizRepository)
  final quizRepo = ref.watch(quizRepositoryProvider);

  // 3. Call the 'getQuizzesForSubject' function *with the subjectId*
  return quizRepo.getQuizzesForSubject(subjectId);
});


// --- 2. NEW Provider for STUDENT Quiz List Screen ---
final publishedQuizzesProvider =
StreamProvider.autoDispose.family<List<QuizModel>, String>((ref, subjectId) {
  if (subjectId.isEmpty) {
    return Stream.value([]);
  }

  return ref
      .watch(quizRepositoryProvider)
      .getPublishedQuizzesForSubject(subjectId);
});


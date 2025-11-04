import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_panel/models/quiz_model.dart';
import 'package:quiz_panel/repositories/quiz_repository.dart';

// --- 1. Stream Provider for Quizzes (using .family) ---

// This is our new 'Manager'.
// It's a StreamProvider that needs a parameter (the subjectId).
// So we use '.family'
final quizzesProvider =
StreamProvider.autoDispose.family<List<QuizModel>, String>((ref, subjectId) {

  // 1. If the subjectId is empty, don't fetch anything.
  if (subjectId.isEmpty) {
    return Stream.value([]);
  }

  // 2. Watch the (QuizRepository)
  final quizRepo = ref.watch(quizRepositoryProvider);

  // 3. Call the 'getQuizzesForSubject' function *with the subjectId*
  //    This returns a live stream of quizzes for *only* that subject.
  return quizRepo.getQuizzesForSubject(subjectId);
});


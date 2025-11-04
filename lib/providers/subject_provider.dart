import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_panel/models/subject_model.dart';
import 'package:quiz_panel/providers/user_data_provider.dart';
import 'package:quiz_panel/repositories/quiz_repository.dart';
import 'package:quiz_panel/utils/constants.dart';

// --- 1. Stream Provider for *current* Teacher's Subjects ---
// (This is the original provider, no changes here)
final subjectsProvider = StreamProvider.autoDispose<List<SubjectModel>>((ref) {

  final currentUserData = ref.watch(userDataProvider);

  return currentUserData.when(
    data: (user) {
      if (user != null && user.role == UserRoles.teacher) {
        final quizRepo = ref.watch(quizRepositoryProvider);
        return quizRepo.getSubjectsForTeacher(user.uid);
      } else {
        return Stream.value([]);
      }
    },
    loading: () => Stream.value([]),
    error: (e, s) => Stream.value([]),
  );
});


// --- 2. NEW PROVIDER (FOR STUDENTS) ---
// This provider gets ALL subjects that are 'published'
final allPublishedSubjectsProvider = StreamProvider.autoDispose<List<SubjectModel>>((ref) {

  // 1. Watch the 'Chef' (QuizRepository)
  final quizRepo = ref.watch(quizRepositoryProvider);

  // 2. Call the new 'getAllPublishedSubjects' function.
  //    This will return a live stream of all published subjects.
  return quizRepo.getAllPublishedSubjects();
});
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_panel/models/subject_model.dart';
import 'package:quiz_panel/providers/user_data_provider.dart';
import 'package:quiz_panel/repositories/quiz_repository.dart';
import 'package:quiz_panel/utils/constants.dart';

// --- 1. Stream Provider for *current* Teacher's Subjects ---
// (This is for the Teacher's or Admin's own dashboard)
final subjectsProvider = StreamProvider.autoDispose<List<SubjectModel>>((ref) {
  final currentUserData = ref.watch(userDataProvider);

  return currentUserData.when(
    data: (user) {
      if (user != null && user.role == UserRoles.teacher) {
        final quizRepo = ref.watch(quizRepositoryProvider);
        return quizRepo.getSubjectsForTeacher(user.uid);
      } else {
        // --- FIX for Admin 'My Content' Tab ---
        // If the user is an Admin, also get their subjects
        if (user != null && user.role == UserRoles.admin) {
          final quizRepo = ref.watch(quizRepositoryProvider);
          return quizRepo.getSubjectsForTeacher(user.uid);
        }
        // --- END FIX ---

        return Stream.value([]);
      }
    },
    loading: () => Stream.value([]),
    error: (e, s) => Stream.value([]),
  );
});

// --- 2. NEW PROVIDER (FOR STUDENTS) ---
// This provider gets ALL subjects that are 'published'
final allPublishedSubjectsProvider =
StreamProvider.autoDispose<List<SubjectModel>>((ref) {
  // 1. Watch the 'Chef' (QuizRepository)
  final quizRepo = ref.watch(quizRepositoryProvider);

  // 2. Call the new 'getAllPublishedSubjects' function.
  //    This will return a live stream of all published subjects.
  return quizRepo.getAllPublishedSubjects();
});

// --- 3. NEW PROVIDER (FOR ADMINS viewing a Teacher) ---
// This provider gets subjects for a *specific* teacher UID
final subjectsByTeacherProvider =
StreamProvider.autoDispose.family<List<SubjectModel>, String>((ref, teacherUid) {
  if (teacherUid.isEmpty) {
    return Stream.value([]);
  }

  // 1. Watch the 'Chef' (QuizRepository)
  final quizRepo = ref.watch(quizRepositoryProvider);

  // 2. Call 'getSubjectsForTeacher' with the provided UID
  return quizRepo.getSubjectsForTeacher(teacherUid);
});
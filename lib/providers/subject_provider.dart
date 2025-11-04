import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_panel/models/subject_model.dart';
import 'package:quiz_panel/providers/user_data_provider.dart';
import 'package:quiz_panel/repositories/quiz_repository.dart';

// --- 1. Stream Provider for *current* Teacher's Subjects ---

// This is our new 'Manager'.
// It's a StreamProvider that provides a List of SubjectModels.
final subjectsProvider = StreamProvider.autoDispose<List<SubjectModel>>((ref) {
  // 2. Watch the current user's data
  final currentUserData = ref.watch(userDataProvider);

  // Use .when() to check the current user's role
  return currentUserData.when(
    data: (user) {
      // 3. Check if a user is logged in AND is a teacher
      if (user != null && user.role == 'teacher') {
        // 4. ONLY if they are a teacher, watch the repo
        //    This will fetch subjects only for this teacher's UID
        final quizRepo = ref.watch(quizRepositoryProvider);
        return quizRepo.getSubjects(user.uid);
      } else {
        // 5. If user is null, or not a teacher,
        //    do NOT run the query. Just return an empty list.
        return Stream.value([]);
      }
    },
    // If user data is loading or has an error, also return an empty list
    loading: () => Stream.value([]),
    error: (e, s) => Stream.value([]),
  );
});

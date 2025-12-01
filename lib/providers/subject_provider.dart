// lib/providers/subject_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_panel/models/subject_model.dart';
import 'package:quiz_panel/providers/user_data_provider.dart';
import 'package:quiz_panel/repositories/quiz_repository.dart';
import 'package:quiz_panel/utils/constants.dart';

/// **What is this file for?**
/// This file acts as the "Content Manager" for Subjects (e.g., Math, Science).
/// Since different users need to see different lists of subjects (e.g., a student sees everything,
/// but a teacher only sees what *they* created), we have separate providers for each use case.

// --- 1. Provider: Current User's Subjects (subjectsProvider) ---

/// **Why we used this Provider:**
/// This allows a logged-in **Teacher** or **Admin** to see the subjects *they* have created.
/// It is used on their personal dashboard to manage content (edit, delete, add quizzes).
///
/// **How it works:**
/// 1. It watches `userDataProvider` to identify who is currently logged in.
/// 2. If the user is a Teacher or Admin, it asks the repository to fetch subjects created by *their* specific UID.
/// 3. If the user is a Student (or logged out), it returns an empty list for security.
final subjectsProvider = StreamProvider.autoDispose<List<SubjectModel>>((ref) {
  final currentUserData = ref.watch(userDataProvider);

  return currentUserData.when(
    data: (user) {
      // Check if user exists and has the right role
      if (user != null && user.role == UserRoles.teacher) {
        final quizRepo = ref.watch(quizRepositoryProvider);
        // Fetch subjects where 'createdBy' == current user's UID
        return quizRepo.getSubjectsForTeacher(user.uid);
      } else {
        // **Special Case for Admins:**
        // Admins can also create content, so we show them their own subjects too.
        if (user != null && user.role == UserRoles.admin) {
          final quizRepo = ref.watch(quizRepositoryProvider);
          return quizRepo.getSubjectsForTeacher(user.uid);
        }

        // Everyone else gets an empty list.
        return Stream.value([]);
      }
    },
    // If loading or error, return safe defaults.
    loading: () => Stream.value([]),
    error: (e, s) => Stream.value([]),
  );
});

// --- 2. Provider: All Published Subjects (allPublishedSubjectsProvider) ---

/// **Why we used this Provider:**
/// This is for **Students**. A student doesn't care *who* created the subject; they just want to see
/// everything that is available to learn.
///
/// **How it works:**
/// It calls a special repository function that ignores the "Creator ID" and instead looks for
/// subjects where `status == 'published'`. This ensures students don't see unfinished drafts.
final allPublishedSubjectsProvider =
    StreamProvider.autoDispose<List<SubjectModel>>((ref) {
      // 1. Get the repository tool.
      final quizRepo = ref.watch(quizRepositoryProvider);

      // 2. Ask for the public stream of data.
      return quizRepo.getAllPublishedSubjects();
    });

// --- 3. Provider: Specific Teacher's Subjects (subjectsByTeacherProvider) ---

/// **Why we used this Provider:**
/// This is for **Admins** who are viewing a specific Teacher's profile.
/// An admin might want to see, "What subjects has Teacher John created?".
///
/// **How it works:**
/// Unlike the first provider (which uses the *logged-in* user's ID), this provider
/// accepts a `teacherUid` as an **argument** (using `.family`).
/// It fetches subjects created specifically by that target teacher.
final subjectsByTeacherProvider = StreamProvider.autoDispose
    .family<List<SubjectModel>, String>((ref, teacherUid) {
      // Safety check: don't query if ID is missing.
      if (teacherUid.isEmpty) {
        return Stream.value([]);
      }

      // 1. Get the repository.
      final quizRepo = ref.watch(quizRepositoryProvider);

      // 2. Fetch subjects for the requested teacher UID.
      return quizRepo.getSubjectsForTeacher(teacherUid);
    });

// lib/providers/quiz_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_panel/models/quiz_model.dart';
import 'package:quiz_panel/repositories/quiz_repository.dart';

/// **What is this file for?**
/// This file acts as the bridge between the Database (Repository) and the UI (Screens) for Quizzes.
/// It defines "Providers" that listen to the database and automatically update the UI
/// whenever quiz data changes (e.g., a new quiz is added).

// --- 1. Provider: Teacher's Quiz List (quizzesProvider) ---

/// **Why we used this Provider:**
/// Teachers need to see ALL quizzes for a specific subject, including "Drafts" that are
/// not yet ready for students. This provider fetches everything.
///
/// **How it works:**
/// 1. **.family:** This keyword allows us to pass a `subjectId` (String) as an argument.
///    We need this because we only want quizzes for *one specific subject*, not all quizzes ever created.
/// 2. **.autoDispose:** When the teacher leaves the screen, this provider stops listening to Firebase
///    to save battery and data.
final quizzesProvider =
StreamProvider.autoDispose.family<List<QuizModel>, String>((ref, subjectId) {

  // Safety Check: If no subject ID is provided, return an empty list immediately.
  if (subjectId.isEmpty) {
    return Stream.value([]);
  }

  // 1. Get the tool (Repository) that knows how to talk to Firebase.
  final quizRepo = ref.watch(quizRepositoryProvider);

  // 2. Ask the repository to watch all quizzes (Draft + Published) for this subject.
  //    This returns a 'Stream', so the UI updates live.
  return quizRepo.getQuizzesForSubject(subjectId);
});


// --- 2. Provider: Student's Quiz List (publishedQuizzesProvider) ---

/// **Why we used this Provider:**
/// Students should ONLY see quizzes that are "Published". They should never see "Drafts".
/// This provider ensures students only access content that is ready.
///
/// **How it works:**
/// It is similar to the teacher's provider but calls a different repository function
/// (`getPublishedQuizzesForSubject`) which applies a filter: `where('status', isEqualTo: 'published')`.
final publishedQuizzesProvider =
StreamProvider.autoDispose.family<List<QuizModel>, String>((ref, subjectId) {

  if (subjectId.isEmpty) {
    return Stream.value([]);
  }

  // Watch the repository and get only the published quizzes for this subject.
  return ref
      .watch(quizRepositoryProvider)
      .getPublishedQuizzesForSubject(subjectId);
});
// lib/repositories/quiz_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// 1. Import the new QuestionModel
import 'package:quiz_panel/models/question_model.dart';
import 'package:quiz_panel/models/quiz_model.dart';
import 'package:quiz_panel/models/subject_model.dart';
import 'package:quiz_panel/utils/app_strings.dart';
// 2. 'constants.dart' import removed (it was unused)

// --- 1. Provider for the Repository ---
final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  return QuizRepository(FirebaseFirestore.instance);
});

// --- 2. The Repository Class ---
class QuizRepository {
  final FirebaseFirestore _db;
  QuizRepository(this._db);

  // --- 3. Subject Functions ---
  Future<void> createSubject({
    required String name,
    String? description,
    required String teacherUid,
  }) async {
    try {
      final newSubject = SubjectModel(
        subjectId: '', // Will be set by Firestore
        name: name,
        description: description,
        createdBy: teacherUid,
        createdAt: Timestamp.now(),
      );
      // 'add' creates a new document with an auto-generated ID
      await _db.collection('subjects').add(newSubject.toMap());
    } on FirebaseException catch (e) {
      throw e.message ?? AppStrings.genericError;
    } catch (e) {
      throw AppStrings.genericError;
    }
  }

  Stream<List<SubjectModel>> getSubjects(String teacherUid) {
    // This query requires the composite index we created
    return _db
        .collection('subjects')
        .where('createdBy', isEqualTo: teacherUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SubjectModel.fromFirestore(doc))
          .toList();
    });
  }

  // --- 4. Quiz Functions (FIXED) ---
  Future<void> createQuiz({
    required String title,
    required String subjectId,
    required int duration,
    required int totalQuestions,
    // 3. --- FIX: Add missing parameters ---
    required String teacherUid,
    required int marksPerQuestion,
  }) async {
    try {
      final newQuiz = QuizModel(
        quizId: '', // Will be set by Firestore
        subjectId: subjectId,
        title: title,
        durationMin: duration,
        totalQuestions: totalQuestions,
        createdAt: Timestamp.now(),
        // 4. --- FIX: Pass the missing parameters ---
        createdBy: teacherUid,
        marksPerQuestion: marksPerQuestion,
        status: 'draft', // New quizzes are always 'draft' by default
      );
      await _db.collection('quizzes').add(newQuiz.toMap());
    } on FirebaseException catch (e) {
      throw e.message ?? AppStrings.genericError;
    } catch (e) {
      throw AppStrings.genericError;
    }
  }

  Stream<List<QuizModel>> getQuizzesForSubject(String subjectId) {
    // This query requires the composite index we created
    return _db
        .collection('quizzes')
        .where('subjectId', isEqualTo: subjectId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => QuizModel.fromFirestore(doc))
          .toList();
    });
  }

  // --- 5. NEW QUESTION FUNCTIONS ---

  // Gets a live stream of all questions for a specific quiz
  Stream<List<QuestionModel>> getQuestionsForQuiz(String quizId) {
    // This is a simple query on a sub-collection.
    // It does *not* require a custom index.
    return _db
        .collection('quizzes')
        .doc(quizId)
        .collection('questions')
        .snapshots() // Get live updates
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => QuestionModel.fromFirestore(doc))
          .toList();
    });
  }

  // Adds a new question to a quiz
  Future<void> addQuestionToQuiz({
    required String quizId,
    required QuestionModel question,
  }) async {
    try {
      // Go into the 'questions' sub-collection of the specific quiz
      // and add a new document
      await _db
          .collection('quizzes')
          .doc(quizId)
          .collection('questions')
          .add(question.toMap()); // Use the toMap() method
    } on FirebaseException catch (e) {
      throw e.message ?? AppStrings.genericError;
    } catch (e) {
      throw AppStrings.genericError;
    }
  }
}


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_panel/models/quiz_model.dart';
import 'package:quiz_panel/models/subject_model.dart';
import 'package:quiz_panel/utils/app_strings.dart';

// --- 1. Provider for the Repository ---
final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  return QuizRepository(FirebaseFirestore.instance);
});

// --- 2. The Repository Class ---

// This class handles all logic for 'subjects' and 'quizzes'
class QuizRepository {
  final FirebaseFirestore _db;
  QuizRepository(this._db);

  // --- 3. Create a new Subject ---
  Future<void> createSubject({
    required String name,
    required String description,
    required String teacherUid,
  }) async {
    try {
      // Create a new model
      final newSubject = SubjectModel(
        subjectId: '', // Will be set by Firestore
        name: name,
        description: description,
        createdBy: teacherUid,
        createdAt: Timestamp.now(),
      );

      // Add to Firestore (converts to Map)
      await _db.collection('subjects').add(newSubject.toMap());

    } on FirebaseException catch (e) {
      throw e.message ?? AppStrings.genericError;
    } catch (e) {
      throw AppStrings.genericError;
    }
  }

  // --- 4. Get all Subjects for a Teacher ---
  Stream<List<SubjectModel>> getSubjects(String teacherUid) {
    try {
      // This is the compound query that required an index
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
    } catch (e) {
      return Stream.value([]);
    }
  }

  // --- 5. Create a new Quiz ---
  Future<void> createQuiz({
    required String title,
    required String subjectId,
    required String teacherUid,
    required int duration,
  }) async {
    try {
      // Create a new quiz model
      final newQuiz = QuizModel(
        quizId: '', // Will be set by Firestore
        subjectId: subjectId,
        title: title,
        createdBy: teacherUid,
        createdAt: Timestamp.now(),
        durationMin: duration,
        totalQuestions: 25, // From our plan
        marksPerQuestion: 1, // Default
        status: 'draft', // Always start as draft
      );

      // Add to Firestore 'quizzes' collection
      await _db.collection('quizzes').add(newQuiz.toMap());

    } on FirebaseException catch (e) {
      throw e.message ?? AppStrings.genericError;
    } catch (e) {
      throw AppStrings.genericError;
    }
  }

  // --- 6. Get all Quizzes for a Subject ---
  Stream<List<QuizModel>> getQuizzesForSubject(String subjectId) {
    try {
      // This is ANOTHER compound query
      // It will ALSO require a new index
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
    } catch (e) {
      return Stream.value([]);
    }
  }
}


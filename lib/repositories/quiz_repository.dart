import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_panel/models/question_model.dart';
import 'package:quiz_panel/models/quiz_model.dart';
import 'package:quiz_panel/models/subject_model.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/utils/constants.dart';

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
        subjectId: '',
        // Will be set by Firestore
        name: name,
        description: description,
        createdBy: teacherUid,
        createdAt: Timestamp.now(),
        status: ContentStatus.draft, // Default status 'draft'
      );
      // 'add' creates a new document with an auto-generated ID
      await _db.collection('subjects').add(newSubject.toMap());
    } on FirebaseException catch (e) {
      throw e.message ?? AppStrings.genericError;
    } catch (e) {
      throw AppStrings.genericError;
    }
  }

  // Function for TEACHER dashboard
  Stream<List<SubjectModel>> getSubjectsForTeacher(String teacherUid) {
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

  // Function for STUDENT dashboard
  Stream<List<SubjectModel>> getAllPublishedSubjects() {
    try {
      return _db
          .collection('subjects')
          .where('status', isEqualTo: ContentStatus.published)
          .orderBy('name', descending: false) // Alphabetical
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

  // Function for TEACHER to publish a subject
  Future<void> updateSubjectStatus({
    required String subjectId,
    required String newStatus,
  }) async {
    try {
      final docRef = _db.collection('subjects').doc(subjectId);
      await docRef.update({'status': newStatus});
    } on FirebaseException catch (e) {
      throw e.message ?? AppStrings.genericError;
    } catch (e) {
      throw AppStrings.genericError;
    }
  }

  // --- 4. Quiz Functions ---
  Future<void> createQuiz({
    required String title,
    required String subjectId,
    required int duration,
    required int totalQuestions,
    required String teacherUid,
    required int marksPerQuestion,
  }) async {
    try {
      final newQuiz = QuizModel(
        quizId: '',
        // Will be set by Firestore
        subjectId: subjectId,
        title: title,
        durationMin: duration,
        totalQuestions: totalQuestions,
        createdAt: Timestamp.now(),
        createdBy: teacherUid,
        marksPerQuestion: marksPerQuestion,
        status: ContentStatus.draft, // Default status 'draft'
      );
      await _db.collection('quizzes').add(newQuiz.toMap());
    } on FirebaseException catch (e) {
      throw e.message ?? AppStrings.genericError;
    } catch (e) {
      throw AppStrings.genericError;
    }
  }

  // Function for TEACHER quiz management screen
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

  // Function for STUDENT quiz list screen
  Stream<List<QuizModel>> getPublishedQuizzesForSubject(String subjectId) {
    return _db
        .collection('quizzes')
        .where('subjectId', isEqualTo: subjectId)
        .where('status', isEqualTo: ContentStatus.published)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => QuizModel.fromFirestore(doc))
          .toList();
    });
  }

  // --- 5. Question Functions ---

  Stream<List<QuestionModel>> getQuestionsForQuiz(String quizId) {
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

  Future<void> addQuestionToQuiz({
    required String quizId,
    required QuestionModel question,
  }) async {
    try {
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

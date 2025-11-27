// lib/repositories/quiz_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_panel/models/question_model.dart';
import 'package:quiz_panel/models/quiz_model.dart';
import 'package:quiz_panel/models/subject_model.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/utils/constants.dart';

/// **What is this Provider? (quizRepositoryProvider)**
/// This provider gives our app access to the `QuizRepository`.
///
/// **Why do we need it?**
/// Instead of creating a new connection to the database in every single screen (which is slow and messy),
/// we create it once here. Any screen that needs to load quizzes or subjects just asks this provider.
final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  // We inject the Firestore instance so the repository can talk to the database.
  return QuizRepository(FirebaseFirestore.instance);
});

/// **Why we used this class (QuizRepository):**
/// This class handles all the "Heavy Lifting" related to the educational content.
/// It is responsible for talking to the Firestore database to:
/// 1. Create and Fetch Subjects (e.g., Math, Science).
/// 2. Create and Fetch Quizzes (e.g., Algebra Quiz 1).
/// 3. Add and Fetch Questions inside those quizzes.
///
/// **How it helps:**
/// It keeps our UI code clean. The screens don't need to know *how* to save data to Firestore;
/// they just call `repository.createQuiz(...)`.
class QuizRepository {
  final FirebaseFirestore _db;

  QuizRepository(this._db);

  // ---------------------------------------------------------------------------
  // SECTION 1: SUBJECT FUNCTIONS
  // ---------------------------------------------------------------------------

  /// **Logic: Create a New Subject**
  /// Used by Teachers to start a new course/subject folder.
  ///
  /// **How it works:**
  /// 1. Takes the details (Name, Description).
  /// 2. Sets the status to 'draft' by default (so students can't see it yet).
  /// 3. Adds a new document to the `subjects` collection in Firestore.
  Future<void> createSubject({
    required String name,
    String? description,
    required String teacherUid,
  }) async {
    try {
      final newSubject = SubjectModel(
        subjectId: '', // Firestore will generate a unique ID for us.
        name: name,
        description: description,
        createdBy: teacherUid,
        createdAt: Timestamp.now(),
        status: ContentStatus.draft,
      );

      // Save to database.
      await _db.collection('subjects').add(newSubject.toMap());
    } on FirebaseException catch (e) {
      throw e.message ?? AppStrings.genericError;
    } catch (e) {
      throw AppStrings.genericError;
    }
  }

  /// **Logic: Get Teacher's Subjects**
  /// Fetches only the subjects created by the currently logged-in teacher.
  ///
  /// **Why use a Stream?**
  /// A Stream keeps the connection open. If the teacher adds a new subject,
  /// the list on their screen updates automatically without refreshing.
  Stream<List<SubjectModel>> getSubjectsForTeacher(String teacherUid) {
    // Query: "Give me subjects where 'createdBy' equals this teacher's ID."
    return _db
        .collection('subjects')
        .where('createdBy', isEqualTo: teacherUid)
        .orderBy('createdAt', descending: true) // Show newest first.
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SubjectModel.fromFirestore(doc))
          .toList();
    });
  }

  /// **Logic: Get Student's Subjects**
  /// Fetches ALL subjects that are ready for students.
  ///
  /// **How it works:**
  /// It filters the database for subjects where `status == 'published'`.
  /// It ignores who created them; students see everything available.
  Stream<List<SubjectModel>> getAllPublishedSubjects() {
    try {
      return _db
          .collection('subjects')
          .where('status', isEqualTo: ContentStatus.published)
          .orderBy('name', descending: false) // Sort A-Z.
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

  /// **Logic: Publish/Unpublish Subject**
  /// Allows a teacher to make a subject visible (Published) or hidden (Draft).
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

  // ---------------------------------------------------------------------------
  // SECTION 2: QUIZ FUNCTIONS
  // ---------------------------------------------------------------------------

  /// **Logic: Create a New Quiz**
  /// Adds a quiz inside a specific subject.
  ///
  /// **How it works:**
  /// It saves the `subjectId` inside the quiz document. This acts as a "Foreign Key",
  /// linking the quiz to its parent subject.
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
        subjectId: subjectId, // Links this quiz to the subject.
        title: title,
        durationMin: duration,
        totalQuestions: totalQuestions,
        createdAt: Timestamp.now(),
        createdBy: teacherUid,
        marksPerQuestion: marksPerQuestion,
        status: ContentStatus.draft,
      );
      await _db.collection('quizzes').add(newQuiz.toMap());
    } on FirebaseException catch (e) {
      throw e.message ?? AppStrings.genericError;
    } catch (e) {
      throw AppStrings.genericError;
    }
  }

  /// **Logic: Get Quizzes for a Subject (Teacher View)**
  /// Fetches ALL quizzes (Draft + Published) for a specific subject ID.
  /// Used in the Teacher Dashboard so they can edit drafts.
  Stream<List<QuizModel>> getQuizzesForSubject(String subjectId) {
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

  /// **Logic: Publish/Unpublish Quiz**
  /// Controls visibility of a specific quiz.
  Future<void> updateQuizStatus({
    required String quizId,
    required String newStatus,
  }) async {
    try {
      final docRef = _db.collection('quizzes').doc(quizId);
      await docRef.update({'status': newStatus});
    } on FirebaseException catch (e) {
      throw e.message ?? AppStrings.genericError;
    } catch (e) {
      throw AppStrings.genericError;
    }
  }

  /// **Logic: Get Quizzes for a Subject (Student View)**
  /// Fetches ONLY 'Published' quizzes for a specific subject ID.
  /// Ensures students cannot see tests that are still being written.
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

  // ---------------------------------------------------------------------------
  // SECTION 3: QUESTION FUNCTIONS
  // ---------------------------------------------------------------------------

  /// **Logic: Get Questions**
  /// Fetches the list of questions for a specific quiz.
  ///
  /// **Data Structure Note:**
  /// Questions are stored in a **Sub-collection**.
  /// Path: `quizzes/{quizId}/questions/{questionId}`.
  /// This keeps the main quiz document light and fast to load.
  Stream<List<QuestionModel>> getQuestionsForQuiz(String quizId) {
    return _db
        .collection('quizzes')
        .doc(quizId)
        .collection('questions') // Go into the sub-collection.
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => QuestionModel.fromFirestore(doc))
          .toList();
    });
  }

  /// **Logic: Add Question**
  /// Adds a new question document to the `questions` sub-collection of a quiz.
  Future<void> addQuestionToQuiz({
    required String quizId,
    required QuestionModel question,
  }) async {
    try {
      await _db
          .collection('quizzes')
          .doc(quizId)
          .collection('questions')
          .add(question.toMap());
    } on FirebaseException catch (e) {
      throw e.message ?? AppStrings.genericError;
    } catch (e) {
      throw AppStrings.genericError;
    }
  }
}
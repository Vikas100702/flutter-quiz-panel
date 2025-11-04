
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_panel/models/question_model.dart';
import 'package:quiz_panel/models/quiz_model.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/utils/constants.dart';

// This class represents our 'subjects' document in Firestore.
class SubjectModel {
  final String subjectId;
  final String name;
  final String? description;
  final String? imageUrl;
  final String createdBy;
  final Timestamp createdAt;
  final String status;

  // Constructor
  SubjectModel({
    required this.subjectId,
    required this.name,
    this.description,
    this.imageUrl,
    required this.createdBy,
    required this.createdAt,
    required this.status,
  });

  // Factory constructor to create a SubjectModel from a Firestore document.
  factory SubjectModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

    return SubjectModel(
      subjectId: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      imageUrl: data['imageUrl'],
      createdBy: data['createdBy'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      status: data['status'] ?? ContentStatus.draft, // <-- NEW (Default to 'draft')
    );
  }

  // Method to convert a SubjectModel instance to a Map for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'status': status,
    };
  }
}

/*final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  return QuizRepository(FirebaseFirestore.instance);
});*/

/*class QuizRepository {
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
        name: name,
        description: description,
        createdBy: teacherUid,
        createdAt: Timestamp.now(),
        status: 'draft', // <-- FIX: Set default status on creation
      );
      await _db.collection('subjects').add(newSubject.toMap());
    } on FirebaseException catch (e) {
      throw e.message ?? AppStrings.genericError;
    } catch (e) {
      throw AppStrings.genericError;
    }
  }

  // Gets subjects for a specific teacher
  Stream<List<SubjectModel>> getSubjectsForTeacher(String teacherUid) {
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

  // Gets all subjects that are 'published'
  Stream<List<SubjectModel>> getAllPublishedSubjects() {
    try {
      // This is ANOTHER compound query
      // It will ALSO require a new index
      return _db
          .collection('subjects')
          .where('status', isEqualTo: 'published')
          .orderBy('name', descending: false) // Order alphabetically
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
        subjectId: subjectId,
        title: title,
        durationMin: duration,
        totalQuestions: totalQuestions,
        createdAt: Timestamp.now(),
        createdBy: teacherUid,
        marksPerQuestion: marksPerQuestion,
        status: 'draft',
      );
      await _db.collection('quizzes').add(newQuiz.toMap());
    } on FirebaseException catch (e) {
      throw e.message ?? AppStrings.genericError;
    } catch (e) {
      throw AppStrings.genericError;
    }
  }

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

  Stream<List<QuestionModel>> getQuestionsForQuiz(String quizId) {
    return _db
        .collection('quizzes')
        .doc(quizId)
        .collection('questions')
        .snapshots()
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
          .add(question.toMap());
    } on FirebaseException catch (e) {
      throw e.message ?? AppStrings.genericError;
    } catch (e) {
      throw AppStrings.genericError;
    }
  }
}*/

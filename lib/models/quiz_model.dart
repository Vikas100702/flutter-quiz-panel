    import 'package:cloud_firestore/cloud_firestore.dart';

class QuizModel {
  final String quizId;
  final String subjectId; // Foreign key to 'subjects' collection
  final String title;
  final String createdBy; // UID of the teacher
  final Timestamp createdAt;
  final int durationMin;
  final int totalQuestions;
  final int marksPerQuestion;
  final String status; // 'draft', 'published'

  QuizModel({
    required this.quizId,
    required this.subjectId,
    required this.title,
    required this.createdBy,
    required this.createdAt,
    required this.durationMin,
    required this.totalQuestions,
    required this.marksPerQuestion,
    required this.status,
  });

  // Helper function to create an empty/default model
  // (We might use this later in our providers)
  factory QuizModel.empty() {
    return QuizModel(
      quizId: '',
      subjectId: '',
      title: '',
      createdBy: '',
      createdAt: Timestamp.now(),
      durationMin: 25, // Default from our plan
      totalQuestions: 25, // Default from our plan
      marksPerQuestion: 1,
      status: 'draft', // Always start as a draft
    );
  }

  // Convert a Firestore DocumentSnapshot into a QuizModel
  factory QuizModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

    return QuizModel(
      quizId: doc.id,
      subjectId: data['subjectId'] ?? '',
      title: data['title'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      durationMin: data['durationMin'] ?? 25,
      totalQuestions: data['totalQuestions'] ?? 25,
      marksPerQuestion: data['marksPerQuestion'] ?? 1,
      status: data['status'] ?? 'draft',
    );
  }

  // Convert a QuizModel into a Map to save to Firestore
  Map<String, dynamic> toMap() {
    return {
      'subjectId': subjectId,
      'title': title,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'durationMin': durationMin,
      'totalQuestions': totalQuestions,
      'marksPerQuestion': marksPerQuestion,
      'status': status,
    };
  }
}


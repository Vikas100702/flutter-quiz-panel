import 'package:cloud_firestore/cloud_firestore.dart';

// This class is the blueprint for a document in the 'questions' sub-collection.
class QuestionModel {
  final String questionId;
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;

  QuestionModel({
    required this.questionId,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
  });

  // Helper method to convert a Firestore Document (Map)
  // into a QuestionModel object.
  factory QuestionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

    return QuestionModel(
      questionId: doc.id,
      questionText: data['questionText'] ?? '',
      options: List<String>.from(data['options'] ?? []), // Ensure 'options' is a List<String>, provide empty list as fallback
      correctAnswerIndex: data['correctAnswerIndex'] ?? 0,
    );
  }

  // Helper method to convert a QuestionModel object
  // into a Map for saving to Firestore.
  Map<String, dynamic> toMap() {
    return {
      // We don't save the ID in the map, it's the document name
      'questionText': questionText,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
    };
  }
}

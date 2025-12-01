import 'package:cloud_firestore/cloud_firestore.dart';

/// **Why we used this class:**
/// This class acts as a "blueprint" or a data model for a single question in our quiz.
/// Instead of dealing with raw data (like Maps or JSON) throughout our app, we use this class.
///
/// **How it helps:**
/// It ensures that every question has a specific structure (ID, text, options, correct answer).
/// It prevents errors like spelling mistakes in keys (e.g., typing 'queston' instead of 'question').
class QuestionModel {
  // **What these variables do:**
  // They hold the specific data for one question.
  final String
  questionId; // The unique ID given by Firebase to identify this specific question.
  final String
  questionText; // The actual question (e.g., "What is the capital of India?").
  final List<String>
  options; // A list of choices (e.g., ["Delhi", "Mumbai", "Kolkata", "Chennai"]).
  final int
  correctAnswerIndex; // The index (0, 1, 2, or 3) of the correct answer in the options list.

  // **Constructor:**
  // This is used to create a new 'QuestionModel' object.
  // We use 'required' to make sure no question is created without this essential data.
  QuestionModel({
    required this.questionId,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
  });

  /// **What is this Factory Constructor? (fromFirestore)**
  /// This is a special helper method that takes raw data coming from the Firestore database
  /// and converts it into a clean 'QuestionModel' Dart object that our app can use easily.
  ///
  /// **How it works:**
  /// 1. It takes a 'DocumentSnapshot' (which is how Firestore delivers a single document).
  /// 2. It safely extracts the data map from that snapshot.
  /// 3. It maps the database fields (like 'questionText') to our class properties.
  ///
  /// **Why we use checks like '??':**
  /// The '??' (null check operator) provides a backup value (like an empty string '' or 0)
  /// if the data is missing in the database. This prevents the app from crashing.
  factory QuestionModel.fromFirestore(DocumentSnapshot doc) {
    // Safely cast the document data to a Map. If data is null, use an empty map {}.
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

    return QuestionModel(
      // We use the document's ID directly from Firestore, it is not stored inside the data map.
      questionId: doc.id,

      // Fetch the question text. If missing, default to empty string.
      questionText: data['questionText'] ?? '',

      // Fetch the options list.
      // We use 'List<String>.from' to ensure the data is strictly a list of strings.
      // If 'options' is null, we provide an empty list [] to avoid errors.
      options: List<String>.from(data['options'] ?? []),

      // Fetch the correct answer index. If missing, default to 0 (the first option).
      correctAnswerIndex: data['correctAnswerIndex'] ?? 0,
    );
  }

  /// **What is this method? (toMap)**
  /// This is the reverse of the above. It converts our Dart object back into a Map (JSON format).
  ///
  /// **Why do we need it?**
  /// Firestore can only save data in Map format. So, before we upload or update a question
  /// in the database, we must convert our fancy 'QuestionModel' object into a simple Map.
  ///
  /// **Note on 'questionId':**
  /// We do NOT include 'questionId' in this map because the ID is the name of the document itself
  /// in Firestore, not a field inside the document.
  Map<String, dynamic> toMap() {
    return {
      'questionText': questionText,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
    };
  }
}

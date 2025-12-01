// lib/models/quiz_attempt_state.dart

import 'package:quiz_panel/models/question_model.dart';
import 'package:quiz_panel/models/quiz_model.dart';

/// **Why we used this Enum (QuizStatus):**
/// Enums allow us to define a fixed set of "stages" or "states" that our quiz can be in.
/// instead of using strings like "loading" or "active" which can have typos, we use strict values.
///
/// **What these values mean:**
/// - `initial`: The screen has just opened, nothing has happened yet.
/// - `loading`: We are fetching questions from the database.
/// - `active`: The student is currently taking the quiz (timer is running).
/// - `finished`: The quiz is submitted, and we are showing results.
/// - `error`: Something went wrong (e.g., no internet).
enum QuizStatus { initial, loading, active, finished, error }

/// **Why we used this class (QuizAttemptState):**
/// This class acts as the "Memory" or "Snapshot" of a student's ongoing quiz attempt.
/// In modern app development (using Riverpod/Bloc), we don't just change variables loosely.
/// Instead, we group all related data (current question, selected answers, timer) into one single object.
///
/// **How it helps:**
/// Whenever any small thing changes (like a second ticks on the timer, or a user selects an answer),
/// we create a *new* version of this object. The UI listens to this object and updates automatically.
class QuizAttemptState {
  // **Core Data:**
  final QuizModel
  quiz; // The details of the quiz being attempted (Title, Duration, etc.).
  final List<QuestionModel>
  questions; // The actual list of questions fetched from the database.

  // **Progress Tracking:**
  final QuizStatus
  status; // The current stage of the quiz (e.g., active, finished).
  final int
  currentQuestionIndex; // Tracks which question number the user is currently viewing (0, 1, 2...).

  // **User Actions:**
  // We use a Map where:
  // - Key (String) = The Question ID.
  // - Value (int) = The index of the option selected by the user (0, 1, 2, or 3).
  // This lets us quickly look up "Did the user answer Question X?" without looping through lists.
  final Map<String, int> userAnswers;

  final int secondsRemaining; // The countdown timer value in seconds.
  final String?
  error; // Stores an error message if something goes wrong, otherwise null.

  // **Result Data (Calculated at the end):**
  // These fields store the final performance summary once the quiz is submitted.
  final int totalCorrect;
  final int totalIncorrect;
  final int totalUnanswered;
  final int score;

  // **Constructor:**
  // Standard constructor to create a state object with specific values.
  // All fields are 'final' because this class is Immutable (cannot be changed once created).
  const QuizAttemptState({
    required this.quiz,
    required this.questions,
    required this.status,
    required this.currentQuestionIndex,
    required this.userAnswers,
    required this.secondsRemaining,
    this.error,
    required this.totalCorrect,
    required this.totalIncorrect,
    required this.totalUnanswered,
    required this.score,
  });

  /// **What is this Factory Constructor? (initial)**
  /// This helps us set up the "Starting Line" for the quiz.
  /// When the user first clicks "Start Quiz", we don't have questions or answers yet.
  ///
  /// **How it works:**
  /// It returns a `QuizAttemptState` with sensible defaults:
  /// - Status is `initial`.
  /// - Score is 0.
  /// - Timer is set to the quiz duration (converted from minutes to seconds).
  factory QuizAttemptState.initial(QuizModel quiz) {
    return QuizAttemptState(
      quiz: quiz,
      questions: [], // No questions loaded yet.
      status: QuizStatus.initial,
      currentQuestionIndex: 0, // Start at the first question.
      userAnswers: {}, // No answers selected yet.
      secondsRemaining: quiz.durationMin * 60, // Calculate total seconds.
      error: null,
      // Initialize results to zero.
      totalCorrect: 0,
      totalIncorrect: 0,
      totalUnanswered: 0,
      score: 0,
    );
  }

  /// **What is this method? (copyWith)**
  /// Since our class is immutable (fields cannot be changed), we cannot simply say `state.score = 10`.
  /// Instead, we use `copyWith`.
  ///
  /// **How it works:**
  /// It takes the *current* state object, copies all its existing values, and allows us to
  /// replace *only* the specific fields we want to update.
  ///
  /// **Example:**
  /// If the timer ticks, we call `copyWith(secondsRemaining: newTime)`.
  /// It returns a new object with the new time, but keeps the old questions, answers, and score exactly as they were.
  QuizAttemptState copyWith({
    List<QuestionModel>? questions,
    QuizStatus? status,
    int? currentQuestionIndex,
    Map<String, int>? userAnswers,
    int? secondsRemaining,
    String? error,
    int? totalCorrect,
    int? totalIncorrect,
    int? totalUnanswered,
    int? score,
  }) {
    return QuizAttemptState(
      quiz: quiz, // The quiz metadata never changes during an attempt.
      // For all other fields: Use the new value if provided (??), otherwise keep the old value (this.field).
      questions: questions ?? this.questions,
      status: status ?? this.status,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      userAnswers: userAnswers ?? this.userAnswers,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      error: error ?? this.error,
      totalCorrect: totalCorrect ?? this.totalCorrect,
      totalIncorrect: totalIncorrect ?? this.totalIncorrect,
      totalUnanswered: totalUnanswered ?? this.totalUnanswered,
      score: score ?? this.score,
    );
  }
}

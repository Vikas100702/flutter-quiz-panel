import 'package:quiz_panel/models/question_model.dart';
import 'package:quiz_panel/models/quiz_model.dart';

// State ko define karne ke liye ek enum
enum QuizStatus { initial, loading, active, finished, error }

// Yeh class quiz ke dauraan poori state ko hold karegi
class QuizAttemptState {
  final QuizModel quiz; // Kaun sa quiz attempt kar rahe hain
  final List<QuestionModel> questions; // Quiz ke saare questions
  final QuizStatus status; // Quiz ka current status (loading, active, etc.)
  final int currentQuestionIndex; // Student abhi kaun se question par hai
  final Map<String, int> userAnswers; // Student ke answers (QuestionID -> SelectedOptionIndex)
  final int secondsRemaining; // Timer
  final String? error; // Agar koi error aaye

  // --- NEW PROPERTIES FOR RESULT (Added in this step) ---
  final int totalCorrect;
  final int totalIncorrect;
  final int totalUnanswered;
  final int score;

  const QuizAttemptState({
    required this.quiz,
    required this.questions,
    required this.status,
    required this.currentQuestionIndex,
    required this.userAnswers,
    required this.secondsRemaining,
    this.error,
    // --- NEW (Added in this step) ---
    required this.totalCorrect,
    required this.totalIncorrect,
    required this.totalUnanswered,
    required this.score,
  });

  // Jab provider pehli baar load hoga, tab default state kya hogi
  factory QuizAttemptState.initial(QuizModel quiz) {
    return QuizAttemptState(
      quiz: quiz,
      questions: [],
      status: QuizStatus.initial,
      currentQuestionIndex: 0,
      userAnswers: {},
      secondsRemaining: quiz.durationMin * 60, // Minutes ko seconds mein convert karein
      error: null,
      // --- NEW (Added in this step) ---
      totalCorrect: 0,
      totalIncorrect: 0,
      totalUnanswered: 0,
      score: 0,
    );
  }

  // State ko update karne ke liye ek helper function
  QuizAttemptState copyWith({
    List<QuestionModel>? questions,
    QuizStatus? status,
    int? currentQuestionIndex,
    Map<String, int>? userAnswers,
    int? secondsRemaining,
    String? error,
    // --- NEW (Added in this step) ---
    int? totalCorrect,
    int? totalIncorrect,
    int? totalUnanswered,
    int? score,
  }) {
    return QuizAttemptState(
      quiz: quiz, // Quiz model wahi rahega
      questions: questions ?? this.questions,
      status: status ?? this.status,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      userAnswers: userAnswers ?? this.userAnswers,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      error: error ?? this.error,
      // --- NEW (Added in this step) ---
      totalCorrect: totalCorrect ?? this.totalCorrect,
      totalIncorrect: totalIncorrect ?? this.totalIncorrect,
      totalUnanswered: totalUnanswered ?? this.totalUnanswered,
      score: score ?? this.score,
    );
  }
}
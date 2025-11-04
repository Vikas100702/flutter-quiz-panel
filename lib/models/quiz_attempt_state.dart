import 'package:quiz_panel/models/question_model.dart';
import 'package:quiz_panel/models/quiz_model.dart';

enum QuizStatus { initial, loading, active, finished, error }

class QuizAttemptState {
  final QuizModel quiz;
  final List<QuestionModel> questions;
  final QuizStatus status;
  final int currentQuestionIndex;
  final Map<String, int> userAnswers;
  final int secondsRemaining;
  final String? error;

  const QuizAttemptState({
    required this.quiz,
    required this.questions,
    required this.status,
    required this.currentQuestionIndex,
    required this.userAnswers,
    required this.secondsRemaining,
    this.error,
  });


  factory QuizAttemptState.initial(QuizModel quiz) {
    return QuizAttemptState(
      quiz: quiz,
      questions: [],
      status: QuizStatus.initial,
      currentQuestionIndex: 0,
      userAnswers: {},
      secondsRemaining: quiz.durationMin * 60,
      error: null,
    );
  }
  QuizAttemptState copyWith({
    List<QuestionModel>? questions,
    QuizStatus? status,
    int? currentQuestionIndex,
    Map<String, int>? userAnswers,
    int? secondsRemaining,
    String? error,
  }) {
    return QuizAttemptState(
      quiz: quiz,
      questions: questions ?? this.questions,
      status: status ?? this.status,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      userAnswers: userAnswers ?? this.userAnswers,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      error: error ?? this.error,
    );
  }
}


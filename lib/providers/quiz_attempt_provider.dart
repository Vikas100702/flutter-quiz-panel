import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';
import 'package:quiz_panel/models/quiz_attempt_state.dart';
import 'package:quiz_panel/models/quiz_model.dart';
import 'package:quiz_panel/repositories/quiz_repository.dart';

// --- 1. Provider ---
final quizAttemptProvider = StateNotifierProvider.autoDispose
    .family<QuizAttemptNotifier, QuizAttemptState, QuizModel>((ref, quiz) {
      return QuizAttemptNotifier(ref.read(quizRepositoryProvider), quiz);
    });

// --- 2. State Notifier (The "Manager") ---
class QuizAttemptNotifier extends StateNotifier<QuizAttemptState> {
  final QuizRepository _quizRepository;
  Timer? _timer; // Timer ko hold karne ke liye

  QuizAttemptNotifier(this._quizRepository, QuizModel quiz)
    // Super() ko call karke initial state set karein
    : super(QuizAttemptState.initial(quiz));

  // --- 3. Public Functions ---

  // Function: Quiz start karna
  Future<void> startQuiz() async {
    try {
      state = state.copyWith(status: QuizStatus.loading);

      final questions = await _quizRepository
          .getQuestionsForQuiz(state.quiz.quizId)
          .first;

      if (questions.isNotEmpty) {
        state = state.copyWith(
          questions: questions,
          status: QuizStatus.active,
          // Timer ko reset karein
          secondsRemaining: state.quiz.durationMin * 60,
        );
        _startTimer();
      } else {
        state = state.copyWith(
          status: QuizStatus.error,
          error: 'Is quiz mein koi questions nahi hain.',
        );
      }
    } catch (e) {
      state = state.copyWith(status: QuizStatus.error, error: e.toString());
    }
  }

  // Function: Answer select karna
  void selectAnswer(String questionId, int answerIndex) {
    final newAnswers = Map<String, int>.from(state.userAnswers);
    newAnswers[questionId] = answerIndex;
    state = state.copyWith(userAnswers: newAnswers);
  }

  // Function: Agle question par jaana
  void nextQuestion() {
    if (state.currentQuestionIndex < state.questions.length - 1) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
      );
    }
  }

  // Function: Pichhle question par jaana
  void previousQuestion() {
    if (state.currentQuestionIndex > 0) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex - 1,
      );
    }
  }

  // --- FUNCTION UPDATE (SCORE CALCULATION LOGIC) ---
  void submitQuiz() {
    _timer?.cancel(); // Timer rokein

    // --- Score Calculation Logic ---
    int correct = 0;
    int incorrect = 0;
    int unanswered = 0;

    final marksPerQuestion = state.quiz.marksPerQuestion;

    // Saare questions par loop karein
    for (final question in state.questions) {
      final questionId = question.questionId;

      // Check karein ki answer diya hai ya nahi
      if (state.userAnswers.containsKey(questionId)) {
        // Answer diya hai
        if (state.userAnswers[questionId] == question.correctAnswerIndex) {
          // Answer sahi hai
          correct++;
        } else {
          // Answer galat hai
          incorrect++;
        }
      } else {
        // Answer nahi diya
        unanswered++;
      }
    }

    // Total score calculate karein
    final finalScore =
        correct * marksPerQuestion; // No negative marking for now

    // State ko result ke saath update karein
    state = state.copyWith(
      status: QuizStatus.finished,
      totalCorrect: correct,
      totalIncorrect: incorrect,
      totalUnanswered: unanswered,
      score: finalScore,
    );
  }

  // --- 4. Private Helper Functions ---

  // Function: Timer start karna
  void _startTimer() {
    _timer?.cancel(); // Puraana timer (agar hai) cancel karein
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.secondsRemaining > 0) {
        state = state.copyWith(secondsRemaining: state.secondsRemaining - 1);
      } else {
        _timer?.cancel();
        submitQuiz(); // Time khatam hone par auto-submit
      }
    });
  }

  // Jab provider destroy ho, tab timer cancel karein
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

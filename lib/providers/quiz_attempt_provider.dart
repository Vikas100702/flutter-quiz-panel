// lib/providers/quiz_attempt_provider.dart

import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';
import 'package:quiz_panel/models/quiz_attempt_state.dart';
import 'package:quiz_panel/models/quiz_model.dart';
import 'package:quiz_panel/repositories/quiz_repository.dart';

/// **Why we used this Provider (quizAttemptProvider):**
/// This provider creates a unique "Game Controller" for a specific quiz.
///
/// **How it helps:**
/// 1. **.autoDispose:** As soon as the user leaves the quiz screen, this provider is destroyed.
///    This automatically cancels the timer and frees up memory.
/// 2. **.family:** This allows us to pass the specific `QuizModel` as an argument.
///    This way, we can have different states for different quizzes at the same time if needed.
final quizAttemptProvider = StateNotifierProvider.autoDispose
    .family<QuizAttemptNotifier, QuizAttemptState, QuizModel>((ref, quiz) {

  // We allow the Notifier to talk to the database via the repository.
  return QuizAttemptNotifier(ref.read(quizRepositoryProvider), quiz);
});

/// **Why we used this class (QuizAttemptNotifier):**
/// This is the "Brain" of the active quiz screen. It handles all the logic:
/// - Counting down the timer.
/// - Remembering which option the user clicked.
/// - Moving between questions.
/// - Calculating the final score.
class QuizAttemptNotifier extends StateNotifier<QuizAttemptState> {
  final QuizRepository _quizRepository;
  Timer? _timer; // A variable to hold the active countdown timer.

  // **Constructor:**
  // We initialize the state with the 'initial' factory we defined in the Model.
  // This sets up the default timer duration and empty lists.
  QuizAttemptNotifier(this._quizRepository, QuizModel quiz)
      : super(QuizAttemptState.initial(quiz));

  // --- 3. Public Functions (Called from UI) ---

  /// **Logic: Start Quiz**
  /// This function is called when the screen first loads.
  ///
  /// **What it does:**
  /// 1. Sets status to 'loading'.
  /// 2. Fetches the questions for this quiz ID from Firebase.
  /// 3. If questions exist, it starts the timer and shows the first question.
  Future<void> startQuiz() async {
    try {
      state = state.copyWith(status: QuizStatus.loading);

      // Fetch questions from the repository
      final questions = await _quizRepository
          .getQuestionsForQuiz(state.quiz.quizId)
          .first;

      if (questions.isNotEmpty) {
        // Questions loaded successfully.
        state = state.copyWith(
          questions: questions,
          status: QuizStatus.active, // The quiz is now live.
          secondsRemaining: state.quiz.durationMin * 60, // Reset timer to full duration.
        );

        // Start the countdown logic.
        _startTimer();
      } else {
        // No questions found in the database.
        state = state.copyWith(
          status: QuizStatus.error,
          error: 'This quiz has no questions available.',
        );
      }
    } catch (e) {
      state = state.copyWith(status: QuizStatus.error, error: e.toString());
    }
  }

  /// **Logic: Select Answer**
  /// Called when a user taps on an option (A, B, C, or D).
  ///
  /// **How it works:**
  /// We update the `userAnswers` map.
  /// - Key: The Question ID.
  /// - Value: The index of the option selected (0, 1, 2, 3).
  void selectAnswer(String questionId, int answerIndex) {
    // Create a copy of the existing answers map (State Immutability).
    final newAnswers = Map<String, int>.from(state.userAnswers);

    // Add or update the answer for this question.
    newAnswers[questionId] = answerIndex;

    // Update the state with the new map.
    state = state.copyWith(userAnswers: newAnswers);
  }

  /// **Logic: Navigation (Next)**
  /// Moves to the next question if we are not already at the last one.
  void nextQuestion() {
    if (state.currentQuestionIndex < state.questions.length - 1) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
      );
    }
  }

  /// **Logic: Navigation (Previous)**
  /// Moves to the previous question if we are not at the first one.
  void previousQuestion() {
    if (state.currentQuestionIndex > 0) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex - 1,
      );
    }
  }

  /// **Logic: Submit Quiz & Calculate Score**
  /// This is the final step. It stops the quiz and generates the report card.
  ///
  /// **How it works:**
  /// 1. Stops the timer.
  /// 2. Loops through every question in the quiz.
  /// 3. Compares the user's selected answer with the correct answer from the database.
  /// 4. Calculates the total score based on `marksPerQuestion`.
  void submitQuiz() {
    _timer?.cancel(); // Important: Stop the timer so it doesn't keep ticking in the background.

    // Initialize counters
    int correct = 0;
    int incorrect = 0;
    int unanswered = 0;

    final marksPerQuestion = state.quiz.marksPerQuestion;

    // Loop through all questions
    for (final question in state.questions) {
      final questionId = question.questionId;

      // Check if the user attempted this question
      if (state.userAnswers.containsKey(questionId)) {
        // User answered this question.
        if (state.userAnswers[questionId] == question.correctAnswerIndex) {
          correct++; // Answer matched!
        } else {
          incorrect++; // Answer did not match.
        }
      } else {
        // User skipped this question.
        unanswered++;
      }
    }

    // Calculate final numeric score.
    final finalScore = correct * marksPerQuestion; // (We are not deducting marks for wrong answers here).

    // Update the state to 'finished' and save the results.
    // The UI will see this change and automatically navigate to the Result Screen.
    state = state.copyWith(
      status: QuizStatus.finished,
      totalCorrect: correct,
      totalIncorrect: incorrect,
      totalUnanswered: unanswered,
      score: finalScore,
    );
  }

  // --- 4. Private Helper Functions ---

  /// **Logic: Internal Timer**
  /// Creates a periodic timer that ticks every 1 second.
  void _startTimer() {
    _timer?.cancel(); // Cancel any existing timer to prevent duplicates.

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.secondsRemaining > 0) {
        // Decrease time by 1 second.
        state = state.copyWith(secondsRemaining: state.secondsRemaining - 1);
      } else {
        // Time is up!
        _timer?.cancel();
        submitQuiz(); // Auto-submit the quiz.
      }
    });
  }

  // **Cleanup:**
  // When this provider is disposed (user leaves screen), ensure the timer stops.
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
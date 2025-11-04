import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';
import 'package:quiz_panel/models/quiz_attempt_state.dart';
import 'package:quiz_panel/models/quiz_model.dart';
import 'package:quiz_panel/repositories/quiz_repository.dart';

final quizAttemptProvider = StateNotifierProvider.autoDispose
    .family<QuizAttemptNotifier, QuizAttemptState, QuizModel>((ref, quiz) {
      // Jab provider create hoga, toh woh QuizRepository ko bhi access karega
      return QuizAttemptNotifier(ref.read(quizRepositoryProvider), quiz);
    });

// --- 2. State Notifier (The "Manager") ---
class QuizAttemptNotifier extends StateNotifier<QuizAttemptState> {
  final QuizRepository _quizRepository;
  Timer? _timer; // Timer ko hold karne ke liye

  QuizAttemptNotifier(this._quizRepository, QuizModel quiz)
    // Super() ko call karke initial state set karein
    : super(QuizAttemptState.initial(quiz));

  // --- 3. Public Functions (Jo UI se call honge) ---

  // Function: Quiz start karna
  Future<void> startQuiz() async {
    try {
      // 1. Status ko 'loading' set karein
      state = state.copyWith(status: QuizStatus.loading);

      // 2. Repository se questions fetch karein
      // Hum .get() ka istemaal kar rahe hain .snapshots() ka nahi,
      // kyunki hum nahi chahte ki quiz ke beech mein questions badlein.
      final questions = await _quizRepository
          .getQuestionsForQuiz(state.quiz.quizId)
          .first; // .first se Stream -> Future ban jaata hai

      // 3. Agar questions mile, toh timer start karein aur status 'active' karein
      if (questions.isNotEmpty) {
        state = state.copyWith(questions: questions, status: QuizStatus.active);
        _startTimer();
      } else {
        // 4. Agar koi question nahi mila
        state = state.copyWith(
          status: QuizStatus.error,
          error: 'Is quiz mein koi questions nahi hain.',
        );
      }
    } catch (e) {
      // 5. Agar koi error aaye
      state = state.copyWith(status: QuizStatus.error, error: e.toString());
    }
  }

  // Function: Answer select karna
  void selectAnswer(String questionId, int answerIndex) {
    // Ek naya map banayein
    final newAnswers = Map<String, int>.from(state.userAnswers);
    // Naye answer ko add/update karein
    newAnswers[questionId] = answerIndex;
    // State ko update karein
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

  // Function: Quiz submit karna
  void submitQuiz() {
    _timer?.cancel(); // Timer rokein
    state = state.copyWith(status: QuizStatus.finished);
    // Hum score calculation yahaan ya ResultScreen mein kar sakte hain
  }

  // --- 4. Private Helper Functions ---

  // Function: Timer start karna
  void _startTimer() {
    // Har second par timer chalega
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.secondsRemaining > 0) {
        // Agar time baaki hai, toh state update karein
        state = state.copyWith(secondsRemaining: state.secondsRemaining - 1);
      } else {
        // Agar time khatam, toh timer rokein aur quiz submit karein
        _timer?.cancel();
        submitQuiz();
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

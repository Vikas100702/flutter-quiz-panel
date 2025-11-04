/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/utils/app_routes.dart';
import 'package:quiz_panel/models/subject_model.dart';
import 'package:quiz_panel/providers/quiz_provider.dart';
import 'package:quiz_panel/providers/user_data_provider.dart';
import 'package:quiz_panel/repositories/quiz_repository.dart';
import 'package:quiz_panel/utils/app_strings.dart';

class QuizManagementScreen extends ConsumerStatefulWidget {
  // This screen needs to know which subject it's managing
  final SubjectModel subject;

  const QuizManagementScreen({
    super.key,
    required this.subject,
  });

  @override
  ConsumerState<QuizManagementScreen> createState() =>
      _QuizManagementScreenState();
}

class _QuizManagementScreenState extends ConsumerState<QuizManagementScreen> {
  final _titleController = TextEditingController();
  final _durationController = TextEditingController(text: '25');
  final _questionsController = TextEditingController(text: '25');
  bool _isCreating = false;

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    _questionsController.dispose();
    super.dispose();
  }

  // --- Logic to Create a New Quiz ---
  Future<void> _createQuiz() async {
    // Get the currently logged-in teacher's UID
    final teacherUid = ref.read(userDataProvider).value?.uid;
    if (teacherUid == null || teacherUid.isEmpty) {
      _showError('Error: Could not find teacher ID. Please re-login.');
      return;
    }
    if (_titleController.text.isEmpty) {
      _showError('Quiz Title cannot be empty.');
      return;
    }
    final duration = int.tryParse(_durationController.text);
    final totalQuestions = int.tryParse(_questionsController.text);

    if (duration == null || duration <= 0) {
      _showError('Please enter a valid duration.');
      return;
    }
    if (totalQuestions == null || totalQuestions <= 0) {
      _showError('Please enter a valid number of questions.');
      return;
    }

    setState(() { _isCreating = true; });

    try {
      // Call the 'Chef' (QuizRepository)
      await ref.read(quizRepositoryProvider).createQuiz(
        title: _titleController.text.trim(),
        subjectId: widget.subject.subjectId,
        duration: duration,
        totalQuestions: totalQuestions,
        teacherUid: teacherUid, // Pass the UID
        marksPerQuestion: 4, // Default marks
      );

      // Show success message
      if (mounted) {
        _showError(AppStrings.quizCreatedSuccess, isError: false);
        _titleController.clear();
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() { _isCreating = false; });
      }
    }
  }

  // Helper to show SnackBar
  void _showError(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Show the subject name in the app bar
        title: Text(widget.subject.name),
        backgroundColor: Colors.blue[700],
      ),
      // We use SingleChildScrollView to make the page scrollable
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- 1. The "Create Quiz" Form ---
              _buildCreateQuizForm(context),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),

              // --- 2. The "My Quizzes" List ---
              Text(
                AppStrings.myQuizzesTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              _buildQuizzesList(context),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widget: Create Quiz Form ---
  Widget _buildCreateQuizForm(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.createQuizTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: AppStrings.quizTitleLabel,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _durationController,
                    decoration: const InputDecoration(
                      labelText: AppStrings.quizDurationLabel,
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.timer),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _questionsController,
                    decoration: const InputDecoration(
                      labelText: AppStrings.totalQuestionsLabel,
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.question_mark),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _isCreating ? null : _createQuiz,
              child: _isCreating
                  ? const CircularProgressIndicator()
                  : const Text(AppStrings.createQuizButton),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widget: Quizzes List ---
  Widget _buildQuizzesList(BuildContext context) {
    // 2. Watch the 'Manager' (.family provider)
    //    We pass in the subjectId from the widget.
    final quizzesAsync = ref.watch(quizzesProvider(widget.subject.subjectId));

    // 3. Use .when() to handle loading/error/data states
    return quizzesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) {
        // This is where the Firestore Index error will appear
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Error loading quizzes.\n\nIf this is your first time, Firestore may need an index.\nPlease check the browser console (F12 or Ctrl+Shift+I) for a URL link to create the index.\n\n${error.toString()}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
      data: (quizzes) {
        // If the list is empty, show a message
        if (quizzes.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(AppStrings.noQuizzesFound),
            ),
          );
        }

        // If we have data, build the list
        return ListView.builder(
          itemCount: quizzes.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final quiz = quizzes[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(quiz.title),
                subtitle: Text(
                  '${quiz.totalQuestions} ${AppStrings.totalQuestionsLabel} | ${quiz.durationMin} ${AppStrings.minutesLabel}',
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                // 5. We make the tile clickable
                onTap: () {
                  // 6. Navigate using GoRouter
                  context.pushNamed(
                    AppRouteNames.questionManagement, // The 'name' of the route
                    // We pass the quizId to build the URL
                    pathParameters: {'quizId': quiz.quizId},
                    // We pass the *entire* quiz object to the screen
                    extra: quiz,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/models/quiz_model.dart'; // QuizModel import
import 'package:quiz_panel/utils/app_routes.dart';
import 'package:quiz_panel/models/subject_model.dart';
import 'package:quiz_panel/providers/quiz_provider.dart';
import 'package:quiz_panel/providers/user_data_provider.dart';
import 'package:quiz_panel/repositories/quiz_repository.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/utils/constants.dart'; // ContentStatus ke liye import

class QuizManagementScreen extends ConsumerStatefulWidget {
  final SubjectModel subject;

  const QuizManagementScreen({
    super.key,
    required this.subject,
  });

  @override
  ConsumerState<QuizManagementScreen> createState() =>
      _QuizManagementScreenState();
}

class _QuizManagementScreenState extends ConsumerState<QuizManagementScreen> {
  final _titleController = TextEditingController();
  final _durationController = TextEditingController(text: '25');
  final _questionsController = TextEditingController(text: '25');
  bool _isCreating = false;

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    _questionsController.dispose();
    super.dispose();
  }

  Future<void> _createQuiz() async {
    final teacherUid = ref.read(userDataProvider).value?.uid;
    if (teacherUid == null || teacherUid.isEmpty) {
      _showError('Error: Could not find teacher ID. Please re-login.');
      return;
    }
    if (_titleController.text.isEmpty) {
      _showError('Quiz Title cannot be empty.');
      return;
    }
    final duration = int.tryParse(_durationController.text);
    final totalQuestions = int.tryParse(_questionsController.text);

    if (duration == null || duration <= 0) {
      _showError('Please enter a valid duration.');
      return;
    }
    if (totalQuestions == null || totalQuestions <= 0) {
      _showError('Please enter a valid number of questions.');
      return;
    }

    setState(() { _isCreating = true; });

    try {
      await ref.read(quizRepositoryProvider).createQuiz(
        title: _titleController.text.trim(),
        subjectId: widget.subject.subjectId,
        duration: duration,
        totalQuestions: totalQuestions,
        teacherUid: teacherUid,
        marksPerQuestion: 4,
      );

      if (mounted) {
        _showError(AppStrings.quizCreatedSuccess, isError: false);
        _titleController.clear();
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() { _isCreating = false; });
      }
    }
  }

  void _showError(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject.name),
        backgroundColor: Colors.blue[700],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCreateQuizForm(context),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              Text(
                AppStrings.myQuizzesTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              _buildQuizzesList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateQuizForm(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.createQuizTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: AppStrings.quizTitleLabel,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _durationController,
                    decoration: const InputDecoration(
                      labelText: AppStrings.quizDurationLabel,
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.timer),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _questionsController,
                    decoration: const InputDecoration(
                      labelText: AppStrings.totalQuestionsLabel,
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.question_mark),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _isCreating ? null : _createQuiz,
              child: _isCreating
                  ? const CircularProgressIndicator()
                  : const Text(AppStrings.createQuizButton),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET UPDATE (Yahaan changes hain) ---
  Widget _buildQuizzesList(BuildContext context) {
    // Hum 'quizzesProvider' (Teacher waala) watch kar rahe hain
    final quizzesAsync = ref.watch(quizzesProvider(widget.subject.subjectId));

    return quizzesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Error loading quizzes.\n\n${error.toString()}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
      data: (quizzes) {
        if (quizzes.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(AppStrings.noQuizzesFound),
            ),
          );
        }

        return ListView.builder(
          itemCount: quizzes.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final quiz = quizzes[index];
            final bool isPublished = quiz.status == ContentStatus.published;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(quiz.title),
                subtitle: Text(
                  '${quiz.totalQuestions} ${AppStrings.totalQuestionsLabel} | ${quiz.durationMin} ${AppStrings.minutesLabel}',
                ),

                // --- YEH HAI NAYA LOGIC ---
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Publish Switch
                    Switch(
                      value: isPublished,
                      onChanged: (newValue) {
                        final newStatus = newValue
                            ? ContentStatus.published
                            : ContentStatus.draft;

                        // Repository function ko call karein
                        ref.read(quizRepositoryProvider).updateQuizStatus(
                          quizId: quiz.quizId,
                          newStatus: newStatus,
                        );

                        // User ko feedback dein
                        _showError(
                          newValue
                              ? AppStrings.quizPublished
                              : AppStrings.quizUnpublished,
                          isError: false,
                        );
                      },
                    ),
                    // Navigate to Questions Button
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios),
                      tooltip: AppStrings.addQuestionsButton,
                      onPressed: () {
                        // Question management screen par navigate karein
                        context.pushNamed(
                          AppRouteNames.questionManagement,
                          pathParameters: {'quizId': quiz.quizId},
                          extra: quiz,
                        );
                      },
                    ),
                  ],
                ),
                // --- END NAYA LOGIC ---
              ),
            );
          },
        );
      },
    );
  }
}

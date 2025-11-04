import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_panel/models/subject_model.dart';
import 'package:quiz_panel/providers/quiz_provider.dart';
import 'package:quiz_panel/providers/user_data_provider.dart';
import 'package:quiz_panel/repositories/quiz_repository.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/widgets/loading_dialog.dart'; // We'll reuse this
// import 'package:quiz_panel/widgets/responsive_list_card.dart'; // We'll reuse this

class QuizManagementScreen extends ConsumerStatefulWidget {
  // This screen needs to know WHICH subject it's managing.
  // We pass in the entire SubjectModel.
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
  // Form controllers for the 'Create Quiz' form
  final _titleController = TextEditingController();
  final _durationController = TextEditingController();
  bool _isCreatingQuiz = false;

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  // --- Logic to Create a New Quiz ---
  Future<void> _createQuiz() async {
    // Get the currently logged-in teacher's UID
    final teacherUid = ref.read(userDataProvider).value?.uid;
    if (teacherUid == null || teacherUid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Could not find teacher ID. Please re-login.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_titleController.text.isEmpty || _durationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() { _isCreatingQuiz = true; });

    try {
      // Call the 'Chef' (QuizRepository)
      await ref.read(quizRepositoryProvider).createQuiz(
        title: _titleController.text.trim(),
        subjectId: widget.subject.subjectId, // From the subject passed to this screen
        teacherUid: teacherUid,
        duration: int.parse(_durationController.text.trim()),
      );

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.quizCreatedSuccess),
            backgroundColor: Colors.green,
          ),
        );
        _titleController.clear();
        _durationController.clear();
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isCreatingQuiz = false; });
      }
    }
  }

  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Show the subject name in the title
        title: Text('${widget.subject.name}: ${AppStrings.manageQuizzesTitle}'),
        backgroundColor: Colors.blue[700],
      ),
      // We use SingleChildScrollView to make the page scrollable
      // This is good for responsive design on small screens.
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
              _buildQuizList(context),
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
            TextField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: AppStrings.quizDurationLabel,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.timer),
              ),
              // Only allow numbers
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _isCreatingQuiz ? null : _createQuiz,
              child: _isCreatingQuiz
                  ? const CircularProgressIndicator()
                  : const Text(AppStrings.createQuizButton),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widget: Quiz List ---
  Widget _buildQuizList(BuildContext context) {
    // 1. Watch the 'Manager' (.family provider)
    //    We pass in the subjectId from the widget.
    final quizzesAsync = ref.watch(quizzesProvider(widget.subject.subjectId));

    // 2. Use .when() to handle loading/error/data states
    return quizzesAsync.when(

      // 2a. Loading State
      loading: () => const Center(child: CircularProgressIndicator()),

      // 2b. Error State
      error: (error, stackTrace) {
        // --- THIS IS THE WARNING ---
        // The first time you run this, it will show this error
        // because the Firestore Index is missing.
        // CHECK THE CONSOLE (F12) FOR THE LINK TO CREATE IT.
        return Center(
          child: Text(
            'Error loading quizzes. \n\n${error.toString()}',
            style: const TextStyle(color: Colors.red),
          ),
        );
      },

      // 2c. Data State
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
          shrinkWrap: true, // Needed inside a SingleChildScrollView
          physics: const NeverScrollableScrollPhysics(), // List is inside scroll view
          itemBuilder: (context, index) {
            final quiz = quizzes[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.quiz),
                title: Text(quiz.title),
                subtitle: Text(
                  '${quiz.totalQuestions} ${AppStrings.totalQuestionsLabel} | ${quiz.durationMin} ${AppStrings.minutesLabel}',
                ),
                trailing: ElevatedButton(
                  child: const Text(AppStrings.addQuestionsButton),
                  onPressed: () {
                    // TODO: Navigate to the Question Management Screen
                    // e.g., context.go('/teacher/quizzes/${quiz.quizId}/questions')
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

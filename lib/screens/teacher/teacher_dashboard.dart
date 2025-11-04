import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/utils/app_routes.dart';
import 'package:quiz_panel/providers/auth_provider.dart';
import 'package:quiz_panel/providers/subject_provider.dart';
import 'package:quiz_panel/providers/user_data_provider.dart';
import 'package:quiz_panel/repositories/quiz_repository.dart';
import 'package:quiz_panel/utils/app_strings.dart';

class TeacherDashboard extends ConsumerStatefulWidget {
  const TeacherDashboard({super.key});

  @override
  ConsumerState<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends ConsumerState<TeacherDashboard> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // --- Logic to Create a New Subject ---
  Future<void> _createSubject() async {
    // Get the currently logged-in teacher's UID
    final teacherUid = ref.read(userDataProvider).value?.uid;
    if (teacherUid == null || teacherUid.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Could not find teacher ID. Please re-login.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (_nameController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subject Name cannot be empty.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      // Call the 'Chef' (QuizRepository)
      await ref.read(quizRepositoryProvider).createSubject(
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        teacherUid: teacherUid,
      );

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.subjectCreatedSuccess),
            backgroundColor: Colors.green,
          ),
        );
        _nameController.clear();
        _descController.clear();
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
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.teacherDashboardTitle),
        backgroundColor: Colors.blue[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: AppStrings.logoutButton,
            onPressed: () {
              ref.read(authRepositoryProvider).signOut();
            },
          ),
        ],
      ),
      // We use SingleChildScrollView to make the page scrollable
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- 1. The "Create Subject" Form ---
              _buildCreateSubjectForm(context),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),

              // --- 2. The "My Subjects" List ---
              Text(
                AppStrings.mySubjectsTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              _buildSubjectsList(context),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widget: Create Subject Form ---
  Widget _buildCreateSubjectForm(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.createSubjectTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: AppStrings.subjectNameLabel,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: AppStrings.subjectDescLabel,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _isCreating ? null : _createSubject,
              child: _isCreating
                  ? const CircularProgressIndicator()
                  : const Text(AppStrings.createSubjectButton),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widget: Subject List ---
  Widget _buildSubjectsList(BuildContext context) {
    // 2. Watch the 'Manager' (subjectsProvider)
    final subjectsAsync = ref.watch(subjectsProvider);

    // 3. Use .when() to handle loading/error/data states
    return subjectsAsync.when(
      // 3a. Loading State
      loading: () => const Center(child: CircularProgressIndicator()),

      // 3b. Error State
      error: (error, stackTrace) {
        // This is where the Firestore Index error will appear
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Error loading subjects.\n\n${error.toString()}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },

      // 3c. Data State
      data: (subjects) {
        // If the list is empty, show a message
        if (subjects.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(AppStrings.noSubjectsFound),
            ),
          );
        }

        // If we have data, build the list
        // We use LayoutBuilder for a responsive grid
        return LayoutBuilder(
          builder: (context, constraints) {
            // Determine cross axis count based on available width
            int crossAxisCount = 1; // Default for mobile
            if (constraints.maxWidth > 1200) {
              crossAxisCount = 4;
            } else if (constraints.maxWidth > 800) {
              crossAxisCount = 3;
            } else if (constraints.maxWidth > 500) {
              crossAxisCount = 2;
            }

            return GridView.builder(
              itemCount: subjects.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 2.5, // Widen the cards
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final subject = subjects[index];

                // --- 4. THIS IS THE UPDATE ---
                // We wrap the Card in InkWell to make it clickable
                return InkWell(
                  onTap: () {
                    // 5. Navigate using GoRouter
                    context.pushNamed(
                      AppRouteNames.quizManagement, // The 'name' of the route

                      // --- FIX (from Step 12.8) ---
                      // The parameter is 'pathParameters', not 'params'
                      pathParameters: {'subjectId': subject.subjectId},
                      // --- END FIX ---

                      // We pass the *entire* subject object to the screen
                      extra: subject,
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            subject.name,
                            style: Theme.of(context).textTheme.titleLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          // --- FIX (from Step 12.9) ---
                          // Check if description is not null AND not empty
                          if (subject.description != null &&
                              subject.description!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                // We are safe to use '!' because of the check above
                                subject.description!,
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          // --- END FIX ---

                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}


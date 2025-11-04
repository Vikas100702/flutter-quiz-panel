import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/utils/app_routes.dart';
import 'package:quiz_panel/providers/auth_provider.dart';
import 'package:quiz_panel/providers/subject_provider.dart';
import 'package:quiz_panel/providers/user_data_provider.dart';
import 'package:quiz_panel/repositories/quiz_repository.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/utils/constants.dart';

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
    final teacherUid = ref.read(userDataProvider).value?.uid;
    if (teacherUid == null || teacherUid.isEmpty) {
      _showError(AppStrings.genericError); // Show generic error
      return;
    }

    if (_nameController.text.isEmpty) {
      _showError('Subject Name cannot be empty.'); // This should be in AppStrings
      return;
    }

    setState(() { _isCreating = true; });

    try {
      await ref.read(quizRepositoryProvider).createSubject(
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        teacherUid: teacherUid,
      );

      _showError(AppStrings.subjectCreatedSuccess, isError: false);
      _nameController.clear();
      _descController.clear();
      if (mounted) FocusScope.of(context).unfocus();

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCreateSubjectForm(context),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              Text(
                AppStrings.mySubjectsTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              _buildSubjectsList(context, ref), // Pass ref
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
  //    (We pass 'ref' to call repository functions)
  /*Widget _buildSubjectsList(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(subjectsProvider);

    return subjectsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) {
        // This is where the Firestore Index error appeared
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${AppStrings.firestoreIndexError}\n\nError: ${error.toString()}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
      data: (subjects) {
        if (subjects.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(AppStrings.noSubjectsFound),
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = 1;
            if (constraints.maxWidth > 1200) {
              crossAxisCount = 3;
            }
            else if (constraints.maxWidth > 800) {
              crossAxisCount = 2;
            }

            return GridView.builder(
              itemCount: subjects.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 2.8, // Make cards a bit wider
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final subject = subjects[index];
                // Check if the subject is published
                final bool isPublished = subject.status == 'published';

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- 1. CLICKABLE AREA (FOR NAVIGATION) ---
                        InkWell(
                          onTap: () {
                            context.pushNamed(
                              AppRouteNames.quizManagement,
                              pathParameters: {'subjectId': subject.subjectId},
                              extra: subject,
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subject.name,
                                style: Theme.of(context).textTheme.titleLarge,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (subject.description != null && subject.description!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    subject.description!,
                                    style: Theme.of(context).textTheme.bodySmall,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // --- 2. NEW WIDGETS (STATUS & BUTTON) ---
                        const Spacer(), // Pushes to the bottom
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Status Text
                              Text(
                                '${AppStrings.subjectStatusLabel} ${isPublished ? AppStrings.subjectStatusPublished : AppStrings.subjectStatusDraft}',
                                style: TextStyle(
                                  color: isPublished ? Colors.green[700] : Colors.orange[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              // Publish/Unpublish Button
                              TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: isPublished ? Colors.red : Colors.green,
                                ),
                                child: Text(isPublished ? AppStrings.unpublishButton : AppStrings.publishButton),
                                onPressed: () async {
                                  // This is the toggle logic
                                  final newStatus = isPublished ? 'draft' : 'published';
                                  try {
                                    // Call the 'Chef'
                                    await ref.read(quizRepositoryProvider).updateSubjectStatus(
                                      subjectId: subject.subjectId,
                                      newStatus: newStatus,
                                    );
                                    if (mounted) {
                                      _showError(AppStrings.subjectStatusUpdated, isError: false);
                                    }
                                  } catch (e) {
                                    _showError(e.toString());
                                  }
                                },
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }*/
  Widget _buildSubjectsList(BuildContext context, WidgetRef ref) {
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
              '${AppStrings.firestoreIndexError}\n\nError: ${error.toString()}',
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
                childAspectRatio: 2.0,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final subject = subjects[index];
                // Check if subject is published
                final bool isPublished =
                    subject.status == ContentStatus.published;

                return Card(
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
                        InkWell(
                          onTap: () {
                            context.pushNamed(
                              AppRouteNames.quizManagement,
                              pathParameters: {'subjectId': subject.subjectId},
                              extra: subject,
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subject.name,
                                style: Theme.of(context).textTheme.titleLarge,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (subject.description != null &&
                                  subject.description!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    subject.description!,
                                    style:
                                    Theme.of(context).textTheme.bodySmall,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const Spacer(),
                        const Divider(),
                        
                        SwitchListTile(
                          title: Text(
                            isPublished
                                ? AppStrings.statusPublished
                                : AppStrings.statusDraft,
                            style: TextStyle(
                              color: isPublished ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: const Text(AppStrings.publishSubject),
                          value: isPublished,
                          onChanged: (newValue) {
                            final newStatus = newValue
                                ? ContentStatus.published
                                : ContentStatus.draft;
                            ref
                                .read(quizRepositoryProvider)
                                .updateSubjectStatus(
                              subjectId: subject.subjectId,
                              newStatus: newStatus,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  newValue
                                      ? AppStrings.subjectPublished
                                      : AppStrings.subjectUnpublished,
                                ),
                                backgroundColor:
                                newValue ? Colors.green : Colors.orange,
                              ),
                            );
                          },
                        ),
                      ],
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


// lib/screens/student/student_home_screen.dart

/*
    /// Why we used this file:
    /// This screen serves as the main entry point (dashboard) for users with the 'student' role.
    /// It provides an organized view of all educational content available to the student.
    ///
    /// How it's helpful:
    /// It fetches and displays a list of all 'published' subjects, allowing the student
    /// to easily browse and select a subject to view available quizzes. It also provides
    /// a personalized welcome message and access to account settings.
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/providers/subject_provider.dart';
import 'package:quiz_panel/providers/user_data_provider.dart';
import 'package:quiz_panel/utils/app_routes.dart';
import 'package:quiz_panel/utils/app_strings.dart';

/// Why we used this Widget:
/// This is a ConsumerWidget, ideal for a dashboard screen that only needs to read (watch)
/// immutable data streams from Riverpod (user profile, list of subjects) without managing local state.
class StudentHomeScreen extends ConsumerWidget {
  const StudentHomeScreen({super.key});

  @override
  /// What it is doing: Builds the responsive UI, including the welcome message and the grid of available subjects.
  /// How it is working: It watches two primary Riverpod providers (`userDataProvider` and `allPublishedSubjectsProvider`)
  /// to render content based on the latest asynchronous data state.
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch the current user's data to get their name and profile details.
    final userData = ref.watch(userDataProvider);

    // 2. Watch the provider for all *published* subjects.
    // How it's helpful: This ensures students only see complete, ready-to-take content.
    final subjectsAsync = ref.watch(allPublishedSubjectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.studentDashboardTitle),
        actions: [
          // Button to navigate to the user's account settings hub.
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'My Account',
            onPressed: () {
              context.push(AppRoutePaths.myAccount);
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
              // 3. Show a personalized welcome message.
              // How it is working: Uses .when() to display the welcome text only when user data is successfully loaded.
              userData.when(
                data: (user) => Text(
                  '${AppStrings.studentWelcome} ${user?.displayName ?? ''}!',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                loading: () => const SizedBox.shrink(), // Hide during loading.
                error: (e, s) => const SizedBox.shrink(), // Hide on error.
              ),
              const SizedBox(height: 24),

              Text(
                AppStrings.studentHomeTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),

              // 4. Display the list of subjects.
              // How it is working: Uses .when() to handle the asynchronous states of the subjects data stream.
              subjectsAsync.when(
                // 4a. Loading State: Show a spinner while fetching subjects from Firestore.
                loading: () => const Center(child: CircularProgressIndicator()),

                // 4b. Error State: Handles errors, particularly database index warnings.
                error: (error, stackTrace) {
                  // How it's helpful: Directly informs the user/developer about the potential missing Firestore Index.
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

                // 4c. Data State: Renders the grid of available subjects.
                data: (subjects) {
                  // If the list is empty, show a dedicated message.
                  if (subjects.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(AppStrings.noSubjectsAvailable),
                      ),
                    );
                  }

                  // Build the responsive subject grid.
                  return LayoutBuilder(
                    // How it is working: Dynamically adjusts the number of columns based on screen width.
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
                        // Ensures the GridView takes minimum space needed.
                        shrinkWrap: true,
                        // Disables scrolling on the grid itself since the parent is scrollable.
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          // Aspect ratio makes the cards horizontal rectangles (2.5 times wider than high).
                          childAspectRatio: 2.5,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemBuilder: (context, index) {
                          final subject = subjects[index];
                          return InkWell(
                            onTap: () {
                              // Navigates to the quiz list screen for the selected subject.
                              context.pushNamed(
                                AppRouteNames.studentQuizList,
                                pathParameters: {
                                  'subjectId': subject.subjectId,
                                },
                                // Passes the SubjectModel object to the next screen.
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
                                    // Subject Name
                                    Text(
                                      subject.name,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    // Subject Description (if available)
                                    if (subject.description != null &&
                                        subject.description!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 4.0,
                                        ),
                                        child: Text(
                                          subject.description!,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

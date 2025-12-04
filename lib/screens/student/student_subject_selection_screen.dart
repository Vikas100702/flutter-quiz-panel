import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/providers/subject_provider.dart';
import 'package:quiz_panel/utils/app_routes.dart';
import 'package:quiz_panel/utils/app_strings.dart';

class StudentSubjectSelectionScreen extends ConsumerWidget {
  final String actionType; // 'quiz' or 'learning'
  const StudentSubjectSelectionScreen({super.key, required this.actionType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Determine title based on action type
    final String pageTitle = actionType == 'quiz'
        ? "Select Subject for Quiz"
        : "Select Subject to Learn";

    final subjectAsync = ref.watch(allPublishedSubjectsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(pageTitle)),

      // 4. Display the list of subjects.
      // How it is working: Uses .when() to handle the asynchronous states of the subjects data stream.
      body: subjectAsync.when(
        // Loading State: Show a spinner while fetching subjects from Firestore.
        loading: () => const Center(child: CircularProgressIndicator()),

        // Error State: Handles errors, particularly database index warnings.
        error: (error, stackTrace) =>
            // How it's helpful: Directly informs the user/developer about the potential missing Firestore Index.
            Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '${AppStrings.firestoreIndexError}\n\nError: ${error.toString()}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

        // Data State: Renders the grid of available subjects.
        data: (subjects) {
          // If the list is empty, show a dedicated message.
          if (subjects.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(AppStrings.noSubjectsAvailable),
              ),
            );
          }

          // Build the responsive subject grid.
          return LayoutBuilder(
            // How it is working: Dynamically adjusts the number of columns based on screen width.
            builder: (context, constraints) {
              int crossAxisAccount = 1; // Default for mobile
              if (constraints.maxWidth > 1200) {
                crossAxisAccount = 4;
              } else if (constraints.maxWidth > 800) {
                crossAxisAccount = 3;
              } else if (constraints.maxWidth > 500) {
                crossAxisAccount = 2;
              }

              return GridView.builder(
                padding: EdgeInsets.all(16),
                itemCount: subjects.length,
                shrinkWrap: true,
                // Ensures the GridView takes minimum space needed.
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisAccount,
                  childAspectRatio: 2.5,
                  // Aspect ratio makes the cards horizontal rectangles (2.5 times wider than high).
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  return InkWell(
                    onTap: () {
                      if (actionType == "quiz") {
                        // Navigates to the quiz list screen for the selected subject.
                        context.pushNamed(
                          AppRouteNames.studentQuizList,
                          pathParameters: {'subjectId': subject.subjectId},
                          // Passes the SubjectModel object to the next screen.
                          extra: subject,
                        );
                      } else {
                        // Go to Youtube Learning
                        // We pass the subject name as the search query
                        // How it's helpful: Navigates to the learning screen, auto-searching for content
                        // related to the quiz title, making the learning path seamless.
                        context.pushNamed(
                          AppRouteNames.youtubeLearning,
                          extra: '${subject.name} tutorial',
                        );
                      }
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
                              style: Theme.of(context).textTheme.titleLarge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            // Subject Description (if available)
                            if (subject.description != null &&
                                subject.description!.isNotEmpty)
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
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

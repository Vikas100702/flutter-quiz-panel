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

    /*// 2. Watch the provider for all *published* subjects.
    // How it's helpful: This ensures students only see complete, ready-to-take content.
    final subjectsAsync = ref.watch(allPublishedSubjectsProvider);*/

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
      body: Padding(
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
            const SizedBox(height: 16),

            Text(
              'What would you like to do today?',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 24),

            // OPTION 1: START QUIZ
            Expanded(
              child: _buildActionCard(
                context,
                title: "Start Quiz",
                description: "Choose a subject and test your knowledge.",
                icon: Icons.quiz_outlined,
                color: Colors.blueAccent,
                onTap: () {
                  // Navigate to subject selection with actionType = 'quiz'
                  context.pushNamed(
                    AppRouteNames.studentSubjectSelection,
                    pathParameters: {'actionType': 'quiz'},
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // OPTION 2: LEARNING TUTORIALS
            Expanded(
              child: _buildActionCard(
                context,
                title: "Learning Tutorials",
                description: "Watch videos and learn new topics.",
                icon: Icons.video_library_outlined,
                color: Colors.redAccent,
                onTap: () {
                  // Navigate to subject selection with actionType = 'learning'
                  context.pushNamed(
                    AppRouteNames.studentSubjectSelection,
                    pathParameters: {'actionType': 'learning'},
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: color),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}

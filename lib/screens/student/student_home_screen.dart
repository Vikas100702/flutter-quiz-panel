/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_panel/providers/auth_provider.dart';
import 'package:quiz_panel/providers/subject_provider.dart'; // We need our new provider
import 'package:quiz_panel/providers/user_data_provider.dart'; // To get user's name
import 'package:quiz_panel/utils/app_strings.dart';

class StudentHomeScreen extends ConsumerWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. Watch the current user's data to get their name
    final userData = ref.watch(userDataProvider);

    // 3. Watch the new provider for all *published* subjects
    final subjectsAsync = ref.watch(allPublishedSubjectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.studentDashboardTitle),
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
              // 4. Show a personalized welcome message
              userData.when(
                data: (user) => Text(
                  '${AppStrings.studentWelcome} ${user?.displayName ?? ''}!',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                loading: () => const SizedBox.shrink(),
                error: (e, s) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),

              Text(
                AppStrings.studentHomeTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),

              // 5. Use .when() to show the list of subjects
              subjectsAsync.when(
                // 5a. Loading State
                loading: () => const Center(child: CircularProgressIndicator()),

                // 5b. Error State
                error: (error, stackTrace) {
                  // This is where the NEW Firestore Index error will appear
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

                // 5c. Data State
                data: (subjects) {
                  // If the list is empty, show a message
                  if (subjects.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(AppStrings.noSubjectsAvailable),
                      ),
                    );
                  }

                  // If we have data, build the responsive grid
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
                          childAspectRatio: 2.5,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemBuilder: (context, index) {
                          final subject = subjects[index];
                          return InkWell(
                            onTap: () {
                              // TODO: (Step 14.5)
                              // Navigate to StudentQuizListScreen
                              // context.pushNamed(AppRouteNames.studentQuizList, ...);
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

*/

/*import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/providers/auth_provider.dart';
import 'package:quiz_panel/providers/subject_provider.dart'; // We need our new provider
import 'package:quiz_panel/providers/user_data_provider.dart'; // To get user's name
import 'package:quiz_panel/utils/app_routes.dart';
import 'package:quiz_panel/utils/app_strings.dart';

class StudentHomeScreen extends ConsumerWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. Watch the current user's data to get their name
    final userData = ref.watch(userDataProvider);

    // 3. Watch the new provider for all *published* subjects
    final subjectsAsync = ref.watch(allPublishedSubjectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.studentDashboardTitle),
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
              // 4. Show a personalized welcome message
              userData.when(
                data: (user) => Text(
                  '${AppStrings.studentWelcome} ${user?.displayName ?? ''}!',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                loading: () => const SizedBox.shrink(),
                error: (e, s) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),

              Text(
                AppStrings.studentHomeTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),

              // 5. Use .when() to show the list of subjects
              subjectsAsync.when(
                // 5a. Loading State
                loading: () => const Center(child: CircularProgressIndicator()),

                // 5b. Error State
                error: (error, stackTrace) {
                  // This is where the NEW Firestore Index error will appear
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

                // 5c. Data State
                data: (subjects) {
                  // If the list is empty, show a message
                  if (subjects.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(AppStrings.noSubjectsAvailable),
                      ),
                    );
                  }

                  // If we have data, build the responsive grid
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
                          childAspectRatio: 2.5,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemBuilder: (context, index) {
                          final subject = subjects[index];
                          return InkWell(
                            onTap: () {
                              context.pushNamed(
                                AppRouteNames.studentQuizList,
                                pathParameters: {
                                  'subjectId': subject.subjectId
                                },
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
                                      style:
                                      Theme.of(context).textTheme.titleLarge,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (subject.description != null &&
                                        subject.description!.isNotEmpty)
                                      Padding(
                                        padding:
                                        const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          subject.description!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
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
}*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/providers/auth_provider.dart';
import 'package:quiz_panel/providers/subject_provider.dart';
import 'package:quiz_panel/providers/user_data_provider.dart';
import 'package:quiz_panel/utils/app_routes.dart';
import 'package:quiz_panel/utils/app_strings.dart';

class StudentHomeScreen extends ConsumerWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. Watch the current user's data to get their name
    final userData = ref.watch(userDataProvider);

    // 3. Watch the new provider for all *published* subjects
    final subjectsAsync = ref.watch(allPublishedSubjectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.studentDashboardTitle),
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
              // 4. Show a personalized welcome message
              userData.when(
                data: (user) => Text(
                  '${AppStrings.studentWelcome} ${user?.displayName ?? ''}!',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                loading: () => const SizedBox.shrink(),
                error: (e, s) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),

              Text(
                AppStrings.studentHomeTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),

              // 5. Use .when() to show the list of subjects
              subjectsAsync.when(
                // 5a. Loading State
                loading: () => const Center(child: CircularProgressIndicator()),

                // 5b. Error State
                error: (error, stackTrace) {
                  // This is where the NEW Firestore Index error will appear
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

                // 5c. Data State
                data: (subjects) {
                  // If the list is empty, show a message
                  if (subjects.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(AppStrings.noSubjectsAvailable),
                      ),
                    );
                  }

                  // If we have data, build the responsive grid
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
                          childAspectRatio: 2.5,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemBuilder: (context, index) {
                          final subject = subjects[index];
                          return InkWell(
                            onTap: () {
                              context.pushNamed(
                                AppRouteNames.studentQuizList,
                                pathParameters: {
                                  'subjectId': subject.subjectId
                                },
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
                                      style:
                                      Theme.of(context).textTheme.titleLarge,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (subject.description != null &&
                                        subject.description!.isNotEmpty)
                                      Padding(
                                        padding:
                                        const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          subject.description!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
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




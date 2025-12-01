// lib/screens/profile/my_account_screen.dart
//
// Why we used this file:
// This screen acts as the central hub for user account settings and management.
// It provides a consolidated view of the user's identity and navigation to
// critical actions like profile editing, password change, and logout.
//
// How it's helpful:
// It simplifies navigation by grouping all security and personal settings
// in one place, accessible from all user dashboards.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/providers/auth_provider.dart';
import 'package:quiz_panel/providers/user_data_provider.dart';
import 'package:quiz_panel/utils/app_routes.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/widgets/buttons/app_button.dart';

// What it is doing: A stateless widget that consumes data from Riverpod (ConsumerWidget).
class MyAccountScreen extends ConsumerWidget {
  const MyAccountScreen({super.key});

  @override
  // How it is working: The build method constructs the UI based on the user's loaded profile data.
  Widget build(BuildContext context, WidgetRef ref) {
    // What it is doing: Watches the userDataProvider to get the user's full profile (name, email, photo, role).
    // How it's helpful: The UI automatically rebuilds whenever the user data changes (e.g., after a name update).
    final userData = ref.watch(userDataProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Account')),
      body: Center(
        // How it's helpful: Constrains the content width to ensure readability and a professional look on large screens (e.g., web).
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // User Info Header
                // How it is working: Uses the .when() method to gracefully handle asynchronous states.
                userData.when(
                  // State 1: Data is loaded successfully.
                  data: (user) => user == null
                      ? const SizedBox.shrink() // Handles case where user is null (safety fallback)
                      : Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                // What it is doing: Displays the user's profile picture or a default icon.
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: AppColors.primaryLight,
                                  // How it's helpful: Renders a NetworkImage if a photoURL exists and is not empty.
                                  backgroundImage:
                                      (user.photoURL != null &&
                                          user.photoURL!.isNotEmpty)
                                      ? NetworkImage(user.photoURL!)
                                      : null,
                                  // What it is doing: Shows a fallback icon if no photo is available.
                                  child:
                                      (user.photoURL == null ||
                                          user.photoURL!.isEmpty)
                                      ? Icon(
                                          Icons.person,
                                          size: 30,
                                          color: AppColors.primary,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // What it is doing: Displays the user's full name.
                                    Text(
                                      user.displayName,
                                      style: AppTextStyles.titleLarge,
                                    ),
                                    // What it is doing: Displays the user's email (read-only in this view).
                                    Text(
                                      user.email,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                  // State 2: Data is currently loading (shows a spinner).
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  // State 3: An error occurred during fetching (hides the widget).
                  error: (e, s) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 24),

                // Settings Options
                Card(
                  elevation: 2,
                  child: Column(
                    children: [
                      // Option 1: Manage Profile
                      ListTile(
                        leading: const Icon(
                          Icons.edit_outlined,
                          color: AppColors.primary,
                        ),
                        title: const Text('Manage Profile'),
                        subtitle: const Text(
                          'Update your name and phone number',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // How it is working: Uses GoRouter to navigate to the profile editing screen.
                          context.push(AppRoutePaths.profile);
                        },
                      ),
                      const Divider(height: 1),
                      // Option 2: Change Password
                      ListTile(
                        leading: const Icon(
                          Icons.lock_outline_rounded,
                          color: AppColors.primary,
                        ),
                        title: const Text('Change Password'),
                        subtitle: const Text('Update your account password'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // How it is working: Uses GoRouter to navigate to the password change screen.
                          context.push(AppRoutePaths.changePassword);
                        },
                      ),
                    ],
                  ),
                ),
                // How it's helpful: Pushes the next widget (Sign Out Button) down to the bottom of the screen.
                const Spacer(),

                // Sign Out Button
                AppButton(
                  text: AppStrings.logoutButton,
                  onPressed: () {
                    // What it is doing: Reads the AuthRepository and calls the signOut method.
                    ref.read(authRepositoryProvider).signOut();
                    // How it is working: Firebase Auth state changes. The AppRouterProvider automatically detects this
                    // and redirects the user from the dashboard to the LoginScreen.
                  },
                  type: AppButtonType.primary,
                  icon: Icons.logout,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

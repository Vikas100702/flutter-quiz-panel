// lib/screens/profile/my_account_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/providers/auth_provider.dart';
import 'package:quiz_panel/providers/user_data_provider.dart';
import 'package:quiz_panel/utils/app_routes.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/widgets/buttons/app_button.dart';

class MyAccountScreen extends ConsumerWidget {
  const MyAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(userDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // User Info Header
                userData.when(
                  data: (user) => user == null
                      ? const SizedBox.shrink()
                      : Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: AppColors.primaryLight,
                            backgroundImage: (user.photoURL != null &&
                                user.photoURL!.isNotEmpty)
                                ? NetworkImage(user.photoURL!)
                                : null,
                            child: (user.photoURL == null ||
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
                              Text(
                                user.displayName,
                                style: AppTextStyles.titleLarge,
                              ),
                              Text(
                                user.email,
                                style: AppTextStyles.bodyMedium
                                    .copyWith(color: AppColors.textTertiary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 24),

                // Settings Options
                Card(
                  elevation: 2,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.edit_outlined,
                            color: AppColors.primary),
                        title: const Text('Manage Profile'),
                        subtitle:
                        const Text('Update your name and phone number'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // This navigates to the existing profile screen
                          context.push(AppRoutePaths.profile);
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.lock_outline_rounded,
                            color: AppColors.primary),
                        title: const Text('Change Password'),
                        subtitle: const Text('Update your account password'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // This navigates to the new screen we are creating
                          context.push(AppRoutePaths.changePassword);
                        },
                      ),
                    ],
                  ),
                ),
                const Spacer(), // Pushes the sign out button to the bottom

                // Sign Out Button
                AppButton(
                  text: AppStrings.logoutButton,
                  onPressed: () {
                    ref.read(authRepositoryProvider).signOut();
                    // The app router provider will automatically handle
                    // navigation back to the login screen.
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
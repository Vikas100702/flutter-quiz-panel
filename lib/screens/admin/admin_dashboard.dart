import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/providers/auth_provider.dart';
import 'package:quiz_panel/utils/app_strings.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.adminDashboardTitle),
        backgroundColor: AppColors.warning,
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
      body: Center(
        child: Text(
          AppStrings.welcomeAdmin,
          style: AppTextStyles.displaySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/utils/app_routes.dart';
import 'package:quiz_panel/utils/app_strings.dart';

class SuperAdminDashboard extends ConsumerWidget {
  const SuperAdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // List of categories for Super Admin
    final List<Map<String, dynamic>> categories = [
      {
        'title': 'Pending Approvals',
        'icon': Icons.pending_actions,
        'color': AppColors.warning,
        'filter': 'pending'
      },
      {
        'title': 'Manage Teachers',
        'icon': Icons.school,
        'color': AppColors.primary,
        'filter': 'teachers'
      },
      {
        'title': 'Manage Students',
        'icon': Icons.person,
        'color': AppColors.success,
        'filter': 'students'
      },
      {
        'title': 'Manage Admins',
        'icon': Icons.verified_user,
        'color': AppColors.secondary,
        'filter': 'admins'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.superAdminDashboardTitle),
        backgroundColor: AppColors.error,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'My Account',
            onPressed: () {
              context.push(AppRoutePaths.myAccount);
            },
          ),
        ],
        // No more TabBar
      ),
      // No more TabBarView
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Dynamic column count
          int crossAxisCount = 2; // Default for mobile
          if (constraints.maxWidth > 1000) {
            crossAxisCount = 4;
          } else if (constraints.maxWidth > 600) {
            crossAxisCount = 3;
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 1.2, // Square-ish cards
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildCategoryCard(
                context: context,
                title: category['title'],
                icon: category['icon'],
                color: category['color'],
                onTap: () {
                  // Navigate to the new list screen with the filter
                  context.pushNamed(
                    AppRouteNames.adminUserList,
                    pathParameters: {'filter': category['filter']},
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // Helper widget to build a category card
  Widget _buildCategoryCard({
    required BuildContext context,
    required String title,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.titleMedium
                  .copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
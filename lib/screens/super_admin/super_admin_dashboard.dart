// lib/screens/super_admin/super_admin_dashboard.dart

/*
/// Why we used this file (SuperAdminDashboard):
/// This screen serves as the **highest-level administrative control center** within the application, exclusive to the `super_admin` role.
/// It provides a centralized hub for managing the entire user base, including other administrators and teachers.

/// What it is doing:
/// 1. **Access Control Hub:** Presents a visual grid interface linking to all critical user management functions (Admins, Teachers, Students, Pending Approvals).
/// 2. **Role Filtering:** Pre-configures links to the generic user list screen, passing a specific `filter` parameter ('admins', 'teachers', 'pending') to determine the data to be fetched and displayed.

/// How it is working:
/// It uses a **GridView.builder** wrapped in a **LayoutBuilder** to dynamically adjust the number of columns based on the screen width (responsive design).
/// Navigation is handled via **GoRouter** using a `pushNamed` approach, ensuring the high-privilege context is maintained as the user navigates to the list screens. The distinct `AppColors.error` theme reinforces the top-level role.

/// How it's helpful:
/// It provides a clear, organized, and responsive interface for top-tier system governance, simplifying tasks like auditing teacher approval queues and managing the access levels of other administrative personnel.
*/
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/utils/app_routes.dart';
import 'package:quiz_panel/utils/app_strings.dart';

/// Why we used this Widget:
/// As a **ConsumerWidget**, it efficiently provides the main navigation structure without managing any local state.
/// It acts as the immutable presentation layer for the Super Admin's core links.
class SuperAdminDashboard extends ConsumerWidget {
  const SuperAdminDashboard({super.key});

  @override
  /// What it is doing: Defines the main UI layout, including the AppBar and the categorized grid of actions.
  Widget build(BuildContext context, WidgetRef ref) {
    // What it is doing: Defines a hardcoded list of links/categories available to the Super Admin.
    // How it's helpful: Each map entry contains a `filter` key which is crucial for instructing the downstream list screen on which user data stream to fetch.
    final List<Map<String, dynamic>> categories = [
      {
        'title': 'Pending Approvals',
        'icon': Icons.pending_actions,
        'color': AppColors.warning,
        'filter':
            'pending', // Filter key to fetch newly registered teachers/phone users.
      },
      {
        'title': 'Manage Teachers',
        'icon': Icons.school,
        'color': AppColors.primary,
        'filter': 'teachers', // Filter key to fetch all teachers.
      },
      {
        'title': 'Manage Students',
        'icon': Icons.person,
        'color': AppColors.success,
        'filter': 'students', // Filter key to fetch all students.
      },
      {
        'title': 'Manage Admins',
        'icon': Icons.verified_user,
        'color': AppColors.secondary,
        'filter': 'admins', // Filter key to fetch all regular admins.
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.superAdminDashboardTitle),
        // Why we used AppColors.error: To visually distinguish this dashboard as the highest-level, Super Admin role.
        backgroundColor: AppColors.error,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'My Account',
            onPressed: () {
              // What it is doing: Navigates to the central profile management screen.
              context.push(AppRoutePaths.myAccount);
            },
          ),
        ],
        // No more TabBar: The dashboard now uses a grid structure instead of tabs.
      ),
      // No more TabBarView: Content is directly rendered below the AppBar.
      body: LayoutBuilder(
        // Why we used LayoutBuilder: To enable dynamic responsiveness based on the available width.
        builder: (context, constraints) {
          // What it is doing: Calculates the appropriate number of columns.
          // How it is working: The column count increases as the screen width grows.
          int crossAxisCount = 2; // Default for mobile
          if (constraints.maxWidth > 1000) {
            crossAxisCount = 4; // Max columns for wide screens
          } else if (constraints.maxWidth > 600) {
            crossAxisCount = 3; // Intermediate width screens (tablets)
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            // How it is working: Configures the grid structure with the calculated column count.
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio:
                  1.2, // What it is doing: Makes the cards slightly rectangular (wider than tall).
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
                  // What it is doing: Triggers navigation to the generic user listing screen.
                  // How it is working: Passes the 'filter' key as a path parameter so the destination screen knows which list of users to query.
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
  /// What it is doing: Creates a single, visually distinct card for a dashboard action.
  /// How it's helpful: Encapsulates the card UI logic for reuse within the GridView.
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
        onTap:
            onTap, // What it is doing: Executes the navigation logic when the card is tapped.
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              // How it is working: Uses a lightly tinted background for the icon circle, derived from the main color.
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

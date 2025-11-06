// lib/screens/auth/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_panel/providers/user_data_provider.dart';
import 'package:quiz_panel/screens/admin/admin_dashboard.dart';
import 'package:quiz_panel/screens/auth/approval_pending_screen.dart';
import 'package:quiz_panel/screens/auth/login_screen.dart';
import 'package:quiz_panel/screens/student/student_home_screen.dart';
import 'package:quiz_panel/screens/super_admin/super_admin_dashboard.dart';
import 'package:quiz_panel/screens/teacher/teacher_dashboard.dart';
import 'package:quiz_panel/utils/constants.dart';
import 'package:quiz_panel/widgets/auth/auth_loading_screen.dart';
import 'package:quiz_panel/widgets/auth/auth_error_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(userDataProvider);

    return userData.when(
      data: (userModel) {
        return _buildUserInterface(userModel, context, ref);
      },
      error: (error, stackTrace) {
        return AuthErrorScreen(
          error: error.toString(),
          onRetry: () => ref.invalidate(userDataProvider),
        );
      },
      loading: () {
        return const AuthLoadingScreen();
      },
    );
  }

  Widget _buildUserInterface(userModel, BuildContext context, WidgetRef ref) {
    // User is logged out
    if (userModel == null) {
      return const LoginScreen();
    }

    // Handle user status
    switch (userModel.status) {
      case UserStatus.pending:
        return const ApprovalPendingScreen();

      case UserStatus.rejected:
        return _buildRejectedScreen(context, ref);

      case UserStatus.approved:
        return _buildRoleBasedDashboard(userModel.role);

      default:
        return _buildUnknownStatusScreen(context, ref);
    }
  }

  Widget _buildRoleBasedDashboard(String role) {
    switch (role) {
      case UserRoles.superAdmin:
        return const SuperAdminDashboard();
      case UserRoles.admin:
        return const AdminDashboard();
      case UserRoles.teacher:
        return const TeacherDashboard();
      case UserRoles.student:
        return const StudentHomeScreen();
      default:
        return _buildUnknownRoleScreen();
    }
  }

  Widget _buildRejectedScreen(BuildContext context, WidgetRef ref) {
    // For now, using ApprovalPendingScreen with different message
    // We'll create a dedicated RejectedScreen later
    return const ApprovalPendingScreen();
  }

  Widget _buildUnknownStatusScreen(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              'Unknown Account Status',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Please contact support for assistance',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.invalidate(userDataProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnknownRoleScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.person_off_rounded,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Unknown User Role',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please contact administrator',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
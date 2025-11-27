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

/// **Why we used this Widget (AuthWrapper):**
/// This is the primary **Access Control Gate** for the entire application.
/// It sits right after the Splash Screen and decides *which screen* the user should see
/// based on their authentication and account status (Role, Approval, etc.).
///
/// **How it helps:**
/// It centralizes the logic for determining the user's destination, preventing scattered
/// checks (if user is admin, go here; if user is pending, go there) across multiple screens.
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. **Watch the User Data Stream:**
    // This watches `userDataProvider`, which is a FutureProvider that fetches the user's
    // profile (role, status) from Firebase Firestore after they log in.
    final userData = ref.watch(userDataProvider);

    // **State-Based Rendering (using .when):**
    // Riverpod's AsyncValue pattern allows us to cleanly handle the three possible states:
    return userData.when(
      // **State 3: Data Loaded Successfully**
      data: (userModel) {
        // Now that we have the full profile, we can decide the final destination.
        return _buildUserInterface(userModel, context, ref);
      },

      // **State 2: Error**
      error: (error, stackTrace) {
        // If the user is authenticated in Firebase Auth but their data is missing in Firestore,
        // or if there's a serious connectivity problem, this screen is shown.
        return AuthErrorScreen(
          error: error.toString(),
          // Allows the user to try fetching the data again.
          onRetry: () => ref.invalidate(userDataProvider),
        );
      },

      // **State 1: Loading**
      loading: () {
        // The app is currently waiting for Firebase Auth or Firestore data to arrive.
        return const AuthLoadingScreen();
      },
    );
  }

  /// **Logic: Determine User Status & Route**
  /// This function takes the loaded `UserModel` and redirects based on account criteria.
  Widget _buildUserInterface(userModel, BuildContext context, WidgetRef ref) {
    // **Scenario A: Logged Out**
    // If the provider returned null, the user is not authenticated.
    if (userModel == null) {
      return const LoginScreen();
    }

    // **Scenario B: Logged In - Check Status**
    // If the user exists, check their approval status from constants.dart.
    switch (userModel.status) {
      case UserStatus.pending:
      // Teacher registered but waiting for Admin approval.
        return const ApprovalPendingScreen();

      case UserStatus.rejected:
      // Teacher was rejected by Admin. (Currently uses the pending screen for messaging).
        return _buildRejectedScreen(context, ref);

      case UserStatus.approved:
      // User is active and ready; redirect to their respective dashboard based on role.
        return _buildRoleBasedDashboard(userModel.role);

      default:
      // Failsafe for unexpected status values.
        return _buildUnknownStatusScreen(context, ref);
    }
  }

  /// **Logic: Select Dashboard based on Role**
  /// The final destination for approved users.
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
      // Failsafe for an undefined role string.
        return _buildUnknownRoleScreen();
    }
  }

  /// **Widget: Rejected Account Screen**
  /// Currently redirects to the pending screen as a temporary solution.
  Widget _buildRejectedScreen(BuildContext context, WidgetRef ref) {
    // In a final application, this would be a dedicated screen with a message
    // like "Your account request was rejected on [Date]."
    return const ApprovalPendingScreen();
  }

  /// **Widget: Unknown Status Handler**
  /// Displayed if the status field in Firestore contains a value not recognized by the system.
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
            // Button to force a re-check of the status.
            ElevatedButton(
              onPressed: () => ref.invalidate(userDataProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// **Widget: Unknown Role Handler**
  /// Displayed if the role field in Firestore contains a value not recognized by the system.
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
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/providers/auth_provider.dart';
import 'package:quiz_panel/providers/user_data_provider.dart';
import 'package:quiz_panel/screens/admin/admin_dashboard.dart';
import 'package:quiz_panel/screens/auth/approval_pending_screen.dart';
import 'package:quiz_panel/screens/auth/login_screen.dart';
import 'package:quiz_panel/screens/auth/register_screen.dart';
import 'package:quiz_panel/screens/splash/splash_screen.dart';
import 'package:quiz_panel/screens/student/student_home_screen.dart';
import 'package:quiz_panel/screens/super_admin/super_admin_dashboard.dart';
import 'package:quiz_panel/screens/teacher/teacher_dashboard.dart';
import 'package:quiz_panel/utils/app_routes.dart';
import 'package:quiz_panel/utils/constants.dart';

// Create the GoRouter Provider
final routerProvider = Provider<GoRouter>((ref) {
  // Create and return the GoRouter
  return GoRouter(
    initialLocation: AppRoutePaths.splash, // Start at the splash screen
    // Use the list of routes we defined in app_routes.dart
    routes: appRoutes,

    // --- THIS IS THE "GATEKEEPER" LOGIC ---
    redirect: (BuildContext context, GoRouterState state) {
      // --- Watch the providers ---
      // We watch the state of our two main providers.
      final authState = ref.watch(authStateProvider);
      final userData = ref.watch(userDataProvider);

      // Get the path the user is trying to go to
      final String location = state.matchedLocation;

      // --- Handle Loading State ---
      // If auth is loading OR user data is loading,
      // and we are NOT on the splash screen, go to splash.
      // This prevents seeing a "flash" of the login screen.
      if ((authState.isLoading || userData.isLoading) &&
          location != AppRoutePaths.splash) {
        return AppRoutePaths.splash;
      }

      // --- Handle Logged-Out User ---
      // If auth is done loading, and there is no user.
      if (!authState.isLoading && authState.value == null) {
        // If the user is trying to go anywhere BUT login or register, send them to the login screen.
        if (location != AppRoutePaths.login &&
            location != AppRoutePaths.register) {
          return AppRoutePaths.login;
        }

        // Otherwise, let them stay on /login or /register
        return null;
      }

      // --- Handle Logged-In User ---
      // If we have an auth user, but the user data (role/status) has an error.
      if (userData.hasError) {
        // TODO: Create an error screen
        // For now, let's just show the error on the splash screen
        return AppRoutePaths.splash;
      }

      // If we have both auth user and user data.
      if (userData.value != null) {
        final user = userData.value!;

        // Check Status (Pending or Rejected)
        if (user.status == UserStatus.pending ||
            user.status == UserStatus.rejected) {
          // If user is pending/rejected, they can ONLY be on the pending screen.
          if (location != AppRoutePaths.pendingApproval) {
            return AppRoutePaths.pendingApproval;
          }
          return null; // Already on the right screen
        }

        // Check Role (if status is 'approved')
        if (user.status == UserStatus.approved) {

          // If user is approved but NOT active (deactivated by admin)
          if (!user.isActive) {
            // Send them to the pending screen.
            // We need to update this screen to show a "Deactivated" message.
            if (location != AppRoutePaths.pendingApproval) {
              return AppRoutePaths.pendingApproval;
            }
            return null; // Already on the right screen
          }

          // If user is approved AND active, proceed to check their role
          String dashboardPath;
          switch (user.role) {
            case UserRoles.superAdmin:
              dashboardPath = AppRoutePaths.superAdminDashboard;
              break;
            case UserRoles.admin:
              dashboardPath = AppRoutePaths.adminDashboard;
              break;
            case UserRoles.teacher:
              dashboardPath = AppRoutePaths.teacherDashboard;
              break;
            case UserRoles.student:
            default:
              dashboardPath = AppRoutePaths.studentDashboard;
          }

          // If user is on a "public" page (login, splash, register) send them to their correct dashboard.
          if (location == AppRoutePaths.splash ||
              location == AppRoutePaths.login ||
              location == AppRoutePaths.register ||
              location == AppRoutePaths.pendingApproval) {
            return dashboardPath;
          }
        }
      }

      // If no other logic matched, let the user go (e.g., they are logged in and approved, and already on their correct dashboard).
      return null;
    },
  );
});

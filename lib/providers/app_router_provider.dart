// lib/providers/app_router_provider.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/providers/auth_provider.dart';
import 'package:quiz_panel/providers/user_data_provider.dart';
import 'package:quiz_panel/utils/app_routes.dart';
import 'package:quiz_panel/utils/constants.dart';
import 'package:quiz_panel/utils/app_strings.dart';

/// **Why we used this file (AppRouterProvider):**
/// This file acts as the "Traffic Controller" or "Security Guard" for our application.
/// It decides which screen a user is allowed to see based on their login status and role.
///
/// **How it helps:**
/// Instead of checking "Is the user logged in?" on every single screen, we define the rules here once.
/// If a logged-out user tries to access a protected page (like the dashboard), this router
/// automatically kicks them back to the login screen.
final routerProvider = Provider<GoRouter>((ref) {

  return GoRouter(
    // **Initial Route:**
    // Where the app starts when opened. We start at the Splash screen to load data.
    initialLocation: AppRoutePaths.splash,

    // **Routes List:**
    // The actual map of all available screens, imported from 'app_routes.dart'.
    routes: appRoutes,

    // --- THE "GATEKEEPER" LOGIC (redirect) ---
    // This function runs every time the user tries to navigate to a new screen.
    // It returns a String (the new path) to redirect them, or null to let them proceed.
    redirect: (BuildContext context, GoRouterState state) {

      // 1. Watch the Authentication State (Is the user logged in to Firebase?)
      final authState = ref.watch(authStateProvider);

      // 2. Watch the User Data (Do we have their role/profile from Firestore?)
      final userData = ref.watch(userDataProvider);

      // The URL the user is trying to go to right now.
      final String location = state.matchedLocation;

      // ---------------------------------------------------------
      // SCENARIO 1: App is still loading data
      // ---------------------------------------------------------
      // If Auth or User Data is still fetching, keep the user on the Splash screen.
      // This prevents errors where the UI tries to display a name that isn't loaded yet.
      if ((authState.isLoading || userData.isLoading) &&
          location != AppRoutePaths.splash) {
        return AppRoutePaths.splash;
      }

      // ---------------------------------------------------------
      // SCENARIO 2: User is NOT logged in (Guest)
      // ---------------------------------------------------------
      if (!authState.isLoading && authState.value == null) {
        // **Whitelisting:**
        // We define a list of "Public" screens that guests are allowed to see.
        // (Login, Register, Forgot Password, OTP screens).
        if (location != AppRoutePaths.login &&
            location != AppRoutePaths.register &&
            location != AppRoutePaths.forgotPassword &&
            location != AppRoutePaths.phoneLogin &&
            location != AppRoutePaths.otpVerify
        ) {
          // If they try to go anywhere else (like Dashboard), send them to Login.
          return AppRoutePaths.login;
        }
        // If they are going to a public screen, let them pass (return null).
        return null;
      }

      // ---------------------------------------------------------
      // SCENARIO 3: User IS logged in (Authenticated)
      // ---------------------------------------------------------
      if (authState.value != null) {

        // **Edge Case: Missing Firestore Data**
        // Sometimes a user is created in Auth (Firebase) but their document isn't in Firestore yet.
        // This usually happens during a brand new registration.
        if (userData.hasError) {
          final errorMsg = userData.error.toString();

          // We check for our specific "User Data Not Found" error.
          if (errorMsg.contains(AppStrings.userDataNotFound)) {
            final authUser = authState.value!;

            // **Check: Is this a Phone User?**
            // Phone users need an extra step to enter their Name and Role.
            final bool isPhoneUser = authUser.providerData.any((p) => p.providerId == 'phone');

            if (isPhoneUser) {
              // Redirect new phone users to the details form.
              if (location != AppRoutePaths.phoneRegisterDetails) {
                return AppRoutePaths.phoneRegisterDetails;
              }
            } else {
              // **Check: Is this an Email User?**
              // If it's a new email user, they might be in the middle of creation.
              // Send them to verify their email as a safe fallback.
              if (location != AppRoutePaths.verifyEmail) {
                return AppRoutePaths.verifyEmail;
              }
            }
            return null; // They are on the correct setup screen.
          }

          // If it's a real error (like no internet), fallback to login.
          return AppRoutePaths.login;
        }

        // ---------------------------------------------------------
        // SCENARIO 4: User Data is Fully Loaded
        // ---------------------------------------------------------
        if (userData.value != null) {
          final userModel = userData.value!;
          final authUser = authState.value!;

          // **Check: Email Verification**
          // If they signed up with password, they MUST verify their email before entering.
          final isPasswordUser = userModel.authProviders.contains('password');
          if (isPasswordUser && !authUser.emailVerified) {
            // If email is NOT verified, force them to the verification screen.
            if (location != AppRoutePaths.verifyEmail) {
              return AppRoutePaths.verifyEmail;
            }
            return null;
          }

          // **Check: Account Status (Pending/Rejected)**
          // If the admin hasn't approved them yet, show the "Pending Approval" screen.
          if (userModel.status == UserStatus.pending ||
              userModel.status == UserStatus.rejected) {
            if (location != AppRoutePaths.pendingApproval) {
              return AppRoutePaths.pendingApproval;
            }
            return null;
          }

          // **Check: Role-Based Redirection**
          // If the user is Approved and Active, we decide where they should go.
          if (userModel.status == UserStatus.approved) {

            // If they are banned (isActive = false), show pending/blocked screen.
            if (!userModel.isActive) {
              if (location != AppRoutePaths.pendingApproval) {
                return AppRoutePaths.pendingApproval;
              }
              return null;
            }

            // Determine their correct home dashboard based on their role.
            String dashboardPath;
            switch (userModel.role) {
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

            // **Final Logic:**
            // If the user is on a "Login" or "Setup" page but they are already logged in & approved,
            // immediately redirect them to their Dashboard.
            if (location == AppRoutePaths.splash ||
                location == AppRoutePaths.login ||
                location == AppRoutePaths.register ||
                location == AppRoutePaths.pendingApproval ||
                location == AppRoutePaths.verifyEmail ||
                location == AppRoutePaths.phoneLogin ||
                location == AppRoutePaths.otpVerify ||
                location == AppRoutePaths.phoneRegisterDetails
            ) {
              return dashboardPath;
            }
          }
        }
      }

      // If none of the rules matched (e.g., User is on a valid page for their role),
      // allow the navigation to proceed.
      return null;
    },
  );
});
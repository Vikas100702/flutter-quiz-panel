// lib/providers/app_router_provider.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/providers/auth_provider.dart';
import 'package:quiz_panel/providers/user_data_provider.dart';
import 'package:quiz_panel/utils/app_routes.dart';
import 'package:quiz_panel/utils/constants.dart';
import 'package:quiz_panel/utils/app_strings.dart';

// Create the GoRouter Provider
final routerProvider = Provider<GoRouter>((ref) {
  // Create and return the GoRouter
  return GoRouter(
    initialLocation: AppRoutePaths.splash, // Start at the splash screen
    routes: appRoutes, // app_routes.dart से

    // --- THIS IS THE "GATEKEEPER" LOGIC ---
    redirect: (BuildContext context, GoRouterState state) {
      // --- Watch the providers ---
      final authState = ref.watch(authStateProvider);
      final userData = ref.watch(userDataProvider);

      final String location = state.matchedLocation;

      // --- Handle Loading State ---
      if ((authState.isLoading || userData.isLoading) &&
          location != AppRoutePaths.splash) {
        return AppRoutePaths.splash;
      }

      // --- Handle Logged-Out User ---
      if (!authState.isLoading && authState.value == null) {
        // Public routes ko allow karein
        if (location != AppRoutePaths.login &&
            location != AppRoutePaths.register &&
            location != AppRoutePaths.forgotPassword &&
            location != AppRoutePaths.phoneLogin && // Phone route allow karein
            location != AppRoutePaths.otpVerify // Phone route allow karein
        ) {
          return AppRoutePaths.login;
        }
        return null;
      }

      // --- Handle Logged-In User ---
      if (authState.value != null) {
        // User Firebase Auth mein logged in hai

        // --- NEW LOGIC: Check if user exists in Firestore ---
        if (userData.hasError) {
          final errorMsg = userData.error.toString();

          // Check karein agar error 'userDataNotFound' hai
          if (errorMsg.contains(AppStrings.userDataNotFound)) {

            // --- ASLI FIX YAHAN HAI ---
            final authUser = authState.value!;
            // 'phone' provider ID se check karein
            final bool isPhoneUser = authUser.providerData.any((p) => p.providerId == 'phone');

            if (isPhoneUser) {
              // YEH EK NAYA PHONE USER HAI
              // Use registration details screen par bhejein.
              if (location != AppRoutePaths.phoneRegisterDetails) {
                return AppRoutePaths.phoneRegisterDetails;
              }
            } else {
              // YEH EK NAYA EMAIL/PASSWORD USER HAI (Race condition)
              // Hum jaante hain ki use database mein create kiya ja raha hai
              // aur use email verify karna hoga.
              // Toh use seedha 'verifyEmail' screen par bhej dein.
              if (location != AppRoutePaths.verifyEmail) {
                return AppRoutePaths.verifyEmail;
              }
            }
            // --- FIX ENDS ---

            return null; // Pehle se hi sahi screen par hain
          }

          // Koi aur error (jaise network) hai, toh login par wapas bhejein
          return AppRoutePaths.login;
        }
        // --- END NEW LOGIC ---

        // Agar user data hai (loading nahi hai aur error nahi hai)
        if (userData.value != null) {
          final userModel = userData.value!;
          final authUser = authState.value!;

          // --- EMAIL VERIFICATION CHECK ---
          final isPasswordUser = userModel.authProviders.contains('password');
          if (isPasswordUser && !authUser.emailVerified) {
            if (location != AppRoutePaths.verifyEmail) {
              return AppRoutePaths.verifyEmail;
            }
            return null; // Pehle se hi sahi screen par hain
          }
          // --- END NEW CHECK ---

          // Check Status (Pending or Rejected)
          // Naye phone users yahaan redirect honge
          if (userModel.status == UserStatus.pending ||
              userModel.status == UserStatus.rejected) {
            if (location != AppRoutePaths.pendingApproval) {
              return AppRoutePaths.pendingApproval;
            }
            return null;
          }

          // Check Role (if status is 'approved')
          if (userModel.status == UserStatus.approved) {
            if (!userModel.isActive) {
              if (location != AppRoutePaths.pendingApproval) {
                return AppRoutePaths.pendingApproval;
              }
              return null;
            }

            // Role-based dashboard path
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

            // If user is on a "public" or "auth" page, send them to their dashboard.
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

      // If no other logic matched, let the user go.
      return null;
    },
  );
});
/*
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
        if (location != AppRoutePaths.login &&
            location != AppRoutePaths.register &&
            location != AppRoutePaths.forgotPassword) {
          return AppRoutePaths.login;
        }
        return null;
      }

      // --- Handle Logged-In User ---
      if (userData.hasError) {
        // यदि यूजर ऑथेंटिकेटेड है लेकिन Firestore में नहीं मिला (शायद नया गूगल साइन-इन)
        // तो उन्हें लॉग इन करने दें। user_repository इसे हैंडल करेगा।
        // लेकिन अगर वे पहले से ही लॉग इन हैं और कोई और एरर है, तो उन्हें लॉगआउट करें।
        if (location == AppRoutePaths.login || location == AppRoutePaths.splash) {
          return null;
        }
        // सुरक्षित फॉलबैक के लिए लॉगिन पर वापस भेजें
        return AppRoutePaths.login;
      }

      // If we have both auth user and user data.
      if (userData.value != null && authState.value != null) {
        final userModel = userData.value!;
        final authUser = authState.value!;

        // --- NEW: EMAIL VERIFICATION CHECK ---
        // जांचें कि क्या यूजर ने ईमेल/पासवर्ड से साइन अप किया है और वेरिफाइड नहीं है
        final isPasswordUser = userModel.authProviders.contains('password');
        if (isPasswordUser && !authUser.emailVerified) {
          // यदि वे वेरिफाइड नहीं हैं, तो वे केवल /verify-email स्क्रीन पर जा सकते हैं
          if (location != AppRoutePaths.verifyEmail) {
            return AppRoutePaths.verifyEmail;
          }
          return null; // पहले से ही सही स्क्रीन पर हैं
        }
        // --- END NEW CHECK ---

        // Check Status (Pending or Rejected)
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

          // If user is on a "public" page, send them to their dashboard.
          if (location == AppRoutePaths.splash ||
              location == AppRoutePaths.login ||
              location == AppRoutePaths.register ||
              location == AppRoutePaths.pendingApproval ||
              location == AppRoutePaths.verifyEmail) { // Added verifyEmail
            return dashboardPath;
          }
        }
      }

      // If no other logic matched, let the user go.
      return null;
    },
  );
});*/

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
            // User authenticated hai lekin database mein nahi hai.
            // Yeh ek NAYA user hai (Phone Auth se).
            // Use registration details screen par bhejein.
            if (location != AppRoutePaths.phoneRegisterDetails) {
              return AppRoutePaths.phoneRegisterDetails;
            }
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
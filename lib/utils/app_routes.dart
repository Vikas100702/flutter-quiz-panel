// lib/utils/app_routes.dart

/*
/// Why we used this file (app_routes.dart):
/// This file serves as the **Single Source of Truth** for all navigation paths and logic across the entire application.
/// It uses the `go_router` package to define a declarative routing map, enabling deep linking and predictable navigation.

/// What it is doing:
/// 1. **Path Constants:** Defines all URL paths (`/login`, `/teacher/dashboard`, etc.) as static constants (`AppRoutePaths`).
/// 2. **Name Constants:** Defines human-readable names for routes (`AppRouteNames`) for safe, type-checked navigation.
/// 3. **Route Configuration:** Creates the final `appRoutes` list, mapping paths to their corresponding screen widgets and handling runtime parameter/extra extraction.

/// How it is working:
/// It registers the routes using `GoRoute` objects. In cases where the destination screen requires data (like a `SubjectModel` or `QuizModel`),
/// the `builder` function extracts this data from `state.extra` or `state.pathParameters` and implements immediate fallback logic (e.g., redirecting to the dashboard) if the data is missing.

/// How it's helpful:
/// It centralizes the navigation structure, making the application easy to scale and maintain. By defining all paths and names here,
/// we ensure consistency and allow the `AppRouterProvider` to apply global authentication and authorization rules efficiently.
*/
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/models/quiz_model.dart';
import 'package:quiz_panel/models/subject_model.dart';
import 'package:quiz_panel/models/user_model.dart';
import 'package:quiz_panel/screens/admin/admin_dashboard.dart';
import 'package:quiz_panel/screens/admin/user_details_screen.dart';
import 'package:quiz_panel/screens/admin/user_management_list_screen.dart';
import 'package:quiz_panel/screens/auth/approval_pending_screen.dart';
import 'package:quiz_panel/screens/auth/forgot_password_screen.dart';
import 'package:quiz_panel/screens/auth/login_screen.dart';
import 'package:quiz_panel/screens/auth/otp_verify_screen.dart';
import 'package:quiz_panel/screens/auth/phone_login_screen.dart';
import 'package:quiz_panel/screens/auth/phone_register_details_screen.dart';
import 'package:quiz_panel/screens/auth/register_screen.dart';
import 'package:quiz_panel/screens/auth/verify_email_screen.dart';
import 'package:quiz_panel/screens/profile/change_password_screen.dart';
import 'package:quiz_panel/screens/profile/manage_profile_screen.dart';
import 'package:quiz_panel/screens/profile/my_account_screen.dart';
import 'package:quiz_panel/screens/splash/splash_screen.dart';
import 'package:quiz_panel/screens/student/quiz_attempt_screen.dart';
import 'package:quiz_panel/screens/student/quiz_result_screen.dart';
import 'package:quiz_panel/screens/student/quiz_start_screen.dart';
import 'package:quiz_panel/screens/student/student_home_screen.dart';
import 'package:quiz_panel/screens/student/student_quiz_list_screen.dart';
import 'package:quiz_panel/screens/student/youtube_learning_screen.dart';
import 'package:quiz_panel/screens/super_admin/edit_user_screen.dart';
import 'package:quiz_panel/screens/super_admin/super_admin_dashboard.dart';
import 'package:quiz_panel/screens/teacher/question_management_screen.dart'; // New
import 'package:quiz_panel/screens/teacher/quiz_management_screen.dart';
import 'package:quiz_panel/screens/teacher/teacher_dashboard.dart';

/// Why we used this class: It provides static constants for all URL path segments, making paths easy to reference and rename globally.
class AppRoutePaths {
  // --- Public & Utility Paths ---
  static const String splash = '/';
  static const String login = '/login';
  static const String phoneLogin = '/login/phone';
  static const String otpVerify = '/login/otp';
  static const String phoneRegisterDetails = '/register/phone';
  static const String forgotPassword = '/forgot-password';
  static const String register = '/register';
  static const String pendingApproval = '/pending-approval';
  static const String verifyEmail = '/verify-email';
  static const String profile = '/profile';
  static const String myAccount =
      '/account'; // Central hub for profile settings
  static const String changePassword = '/account/change-password';

  // --- Teacher Paths (Dynamic Segments) ---
  // How it is working: Uses ':subjectId' as a dynamic segment in the URL to pass data.
  static const String teacherDashboard = '/teacher/dashboard';
  static const String quizManagement = '/teacher/subjects/:subjectId';
  static const String questionManagement = '/teacher/quizzes/:quizId/questions';

  // --- Student Paths (Dynamic Segments) ---
  static const String studentDashboard = '/student/dashboard';
  static const String studentQuizList = '/student/subjects/:subjectId';
  static const String studentQuizStart = '/student/quiz/:quizId/start';
  static const String studentQuizAttempt = '/student/quiz/attempt/:quizId';
  static const String studentQuizResult = '/student/quizzes/:quizId/result';
  static const String youtubeLearning = '/student/learning';

  // --- Admin Paths (Dynamic Segments) ---
  static const String adminDashboard = '/admin/dashboard';
  static const String superAdminDashboard = '/superadmin/dashboard';
  static const String editUser = '/superadmin/users/:userId/edit';
  static const String userDetails = '/admin/users/:userId/details';
  // How it is working: Uses ':filter' to pass the user list type (e.g., 'pending', 'teachers') as a parameter.
  static const String adminUserList = '/admin/users/list/:filter';
}

/// Why we used this class: Provides unique, semantic names for each route, allowing navigation using `context.pushNamed(AppRouteNames.someRoute)`
/// instead of hardcoding URL strings, which is safer and less error-prone.
class AppRouteNames {
  static const String splash = 'splash';
  static const String login = 'login';
  static const String phoneLogin = 'phoneLogin';
  static const String otpVerify = 'otpVerify';
  static const String phoneRegisterDetails = 'phoneRegisterDetails';
  static const String forgotPassword = 'forgot-password';
  static const String register = 'register';
  static const String pendingApproval = 'pendingApproval';
  static const String verifyEmail = 'verifyEmail';
  static const String profile = 'profile';
  static const String myAccount = 'myAccount';
  static const String changePassword = 'changePassword';

  // Teacher names
  static const String teacherDashboard = 'teacherDashboard';
  static const String quizManagement = 'quizManagement';
  static const String questionManagement = 'questionManagement';

  // Student names
  static const String studentDashboard = 'studentDashboard';
  static const String studentQuizList = 'studentQuizList';
  static const String studentQuizStart = 'studentQuizStart';
  static const String studentQuizAttempt = 'studentQuizAttempt';
  static const String studentQuizResult = 'studentQuizResult';
  static const String youtubeLearning = 'youtubeLearning';

  // Admin names
  static const String adminDashboard = 'adminDashboard';
  static const String superAdminDashboard = 'superAdminDashboard';
  static const String editUser = 'editUser';
  static const String userDetails = 'userDetails';
  static const String adminUserList = 'adminUserList';
}

/// What it is doing: The main list of all application routes, mapping path patterns to screen builders.
/// How it's helpful: This list is passed to the `GoRouter` constructor in `app_router_provider.dart`.
final List<GoRoute> appRoutes = [
  // --- PUBLIC ROUTES ---
  GoRoute(
    path: AppRoutePaths.splash,
    name: AppRouteNames.splash,
    builder: (context, state) => const SplashScreen(),
  ),
  GoRoute(
    path: AppRoutePaths.login,
    name: AppRouteNames.login,
    builder: (context, state) => const LoginScreen(),
  ),
  GoRoute(
    path: AppRoutePaths.forgotPassword,
    name: 'forgot-password',
    builder: (context, state) => const ForgotPasswordScreen(),
  ),
  GoRoute(
    path: AppRoutePaths.register,
    name: AppRouteNames.register,
    builder: (context, state) => const RegisterScreen(),
  ),
  GoRoute(
    path: AppRoutePaths.phoneLogin,
    name: AppRouteNames.phoneLogin,
    builder: (context, state) => const PhoneLoginScreen(),
  ),
  GoRoute(
    path: AppRoutePaths.otpVerify,
    name: AppRouteNames.otpVerify,
    builder: (context, state) {
      // How it is working: Extracts the `verificationId` passed from the Phone Login screen via `extra`.
      final verificationId = state.extra as String?;
      if (verificationId == null) {
        // How it's helpful: Implements a safety fallback, forcing the user back to the first step if the critical ID is missing.
        return const PhoneLoginScreen();
      }
      return OtpVerifyScreen(verificationId: verificationId);
    },
  ),
  GoRoute(
    path: AppRoutePaths.phoneRegisterDetails,
    name: AppRouteNames.phoneRegisterDetails,
    builder: (context, state) => const PhoneRegisterDetailsScreen(),
  ),
  GoRoute(
    path: AppRoutePaths.pendingApproval,
    name: AppRouteNames.pendingApproval,
    builder: (context, state) => const ApprovalPendingScreen(),
  ),
  GoRoute(
    path: AppRoutePaths.verifyEmail,
    name: AppRouteNames.verifyEmail,
    builder: (context, state) => const VerifyEmailScreen(),
  ),
  GoRoute(
    path: AppRoutePaths.profile,
    name: AppRouteNames.profile,
    builder: (context, state) => const ManageProfileScreen(),
  ),
  GoRoute(
    path: AppRoutePaths.myAccount,
    name: AppRouteNames.myAccount,
    builder: (context, state) => const MyAccountScreen(),
  ),
  GoRoute(
    path: AppRoutePaths.changePassword,
    name: AppRouteNames.changePassword,
    builder: (context, state) => const ChangePasswordScreen(),
  ),

  // --- TEACHER ROUTES ---
  GoRoute(
    path: AppRoutePaths.teacherDashboard,
    name: AppRouteNames.teacherDashboard,
    builder: (context, state) => const TeacherDashboard(),
  ),
  GoRoute(
    path: AppRoutePaths.quizManagement,
    name: AppRouteNames.quizManagement,
    builder: (context, state) {
      // What it is doing: Extracts the required `SubjectModel` object passed during navigation via `extra`.
      final SubjectModel? subject = state.extra as SubjectModel?;
      if (subject == null) {
        // How it's helpful: Ensures the screen has the necessary data; falls back to the Teacher Dashboard.
        return const TeacherDashboard();
      }
      return QuizManagementScreen(subject: subject);
    },
  ),
  GoRoute(
    path: AppRoutePaths.questionManagement,
    name: AppRouteNames.questionManagement,
    builder: (context, state) {
      // What it is doing: Extracts the required `QuizModel` object passed during navigation via `extra`.
      final QuizModel? quiz = state.extra as QuizModel?;
      if (quiz == null) {
        // How it's helpful: Ensures data integrity; falls back to the Teacher Dashboard.
        return const TeacherDashboard();
      }
      return QuestionManagementScreen(quiz: quiz);
    },
  ),

  // --- STUDENT ROUTES ---
  GoRoute(
    path: AppRoutePaths.studentDashboard,
    name: AppRouteNames.studentDashboard,
    builder: (context, state) => const StudentHomeScreen(),
  ),
  GoRoute(
    path: AppRoutePaths.studentQuizList,
    name: AppRouteNames.studentQuizList,
    builder: (context, state) {
      // What it is doing: Extracts the `SubjectModel` object needed to display the correct quizzes list.
      final SubjectModel? subject = state.extra as SubjectModel?;
      if (subject == null) {
        return const StudentHomeScreen();
      }
      return StudentQuizListScreen(subject: subject);
    },
  ),
  GoRoute(
    path: AppRoutePaths.studentQuizStart,
    name: AppRouteNames.studentQuizStart,
    builder: (context, state) {
      // What it is doing: Extracts the target `QuizModel` object.
      final QuizModel? quiz = state.extra as QuizModel?;
      if (quiz == null) {
        return const StudentHomeScreen();
      }
      // How it's helpful: Navigates to the instruction screen before starting the timed attempt.
      return QuizStartScreen(quiz: quiz);
    },
  ),
  GoRoute(
    path: AppRoutePaths.studentQuizAttempt,
    name: AppRouteNames.studentQuizAttempt,
    builder: (context, state) {
      // What it is doing: Extracts the `QuizModel` required by the live attempt screen.
      final QuizModel? quiz = state.extra as QuizModel?;
      if (quiz == null) {
        return const StudentHomeScreen(); // safety fallback
      }
      return QuizAttemptScreen(quiz: quiz);
    },
  ),
  GoRoute(
    path: AppRoutePaths.studentQuizResult,
    name: AppRouteNames.studentQuizResult,
    builder: (context, state) {
      // What it is doing: Extracts the `QuizModel` required by the result screen.
      final QuizModel? quiz = state.extra as QuizModel?;
      if (quiz == null) {
        return const StudentHomeScreen();
      }
      return QuizResultScreen(quiz: quiz);
    },
  ),
  GoRoute(
    path: AppRoutePaths.youtubeLearning,
    name: AppRouteNames.youtubeLearning,
    builder: (context, state) {
      // What it is doing: Extracts an optional `initialQuery` string for the search bar.
      final initialQuery = state.extra as String? ?? '';
      return YoutubeLearningScreen(initialQuery: initialQuery);
    },
  ),

  // --- ADMIN ROUTES ---
  GoRoute(
    path: AppRoutePaths.adminDashboard,
    name: AppRouteNames.adminDashboard,
    builder: (context, state) => const AdminDashboard(),
  ),
  GoRoute(
    path: AppRoutePaths.superAdminDashboard,
    name: AppRouteNames.superAdminDashboard,
    builder: (context, state) => const SuperAdminDashboard(),
  ),
  GoRoute(
    path: AppRoutePaths.editUser,
    name: AppRouteNames.editUser,
    builder: (context, state) {
      // What it is doing: Extracts the `UserModel` for the user to be edited.
      final UserModel? user = state.extra as UserModel?;
      if (user == null) {
        // How it's helpful: Ensures the screen has target data; falls back to the Super Admin dashboard.
        return const SuperAdminDashboard();
      }
      return EditUserScreen(user: user);
    },
  ),
  GoRoute(
    path: AppRoutePaths.userDetails,
    name: AppRouteNames.userDetails,
    builder: (context, state) {
      // What it is doing: Extracts the `UserModel` for the user whose details are to be displayed.
      final UserModel? user = state.extra as UserModel?;
      if (user == null) {
        // How it's helpful: Fallback if user data is missing during navigation.
        return const LoginScreen();
      }
      return UserDetailsScreen(user: user);
    },
  ),
  GoRoute(
    path: AppRoutePaths.adminUserList,
    name: AppRouteNames.adminUserList,
    builder: (context, state) {
      // How it is working: Extracts the dynamic segment (parameter) from the URL path, which determines the list content.
      final filter = state.pathParameters['filter'] ?? 'pending';
      return UserManagementListScreen(filter: filter);
    },
  ),
];

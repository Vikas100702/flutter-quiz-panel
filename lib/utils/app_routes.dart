import 'package:go_router/go_router.dart';
import 'package:quiz_panel/models/subject_model.dart';
import 'package:quiz_panel/screens/admin/admin_dashboard.dart';
import 'package:quiz_panel/screens/auth/approval_pending_screen.dart';
import 'package:quiz_panel/screens/auth/login_screen.dart';
import 'package:quiz_panel/screens/auth/register_screen.dart';
import 'package:quiz_panel/screens/splash/splash_screen.dart';
import 'package:quiz_panel/screens/student/student_home_screen.dart';
import 'package:quiz_panel/screens/super_admin/super_admin_dashboard.dart';
import 'package:quiz_panel/screens/teacher/quiz_management_screen.dart';
import 'package:quiz_panel/screens/teacher/teacher_dashboard.dart';

// This class will hold all our route 'names' and 'paths'
// Using constants for route names helps avoid typos in our code.

class AppRoutePaths {
  static const String splash = '/'; // The entry point of the app
  static const String login = '/login';
  static const String register = '/register';
  static const String pendingApproval = '/pending-approval';

  // We'll add dashboard paths here later
  static const String studentDashboard = '/student/dashboard';
  static const String teacherDashboard = '/teacher/dashboard';
  static const String adminDashboard = '/admin/dashboard';
  static const String superAdminDashboard = '/superadmin/dashboard';

  // This is a dynamic path. ':subjectId' is a placeholder.
  static const String quizManagement = '/teacher/subjects/:subjectId';
}

class AppRouteNames {
  static const String splash = 'splash';
  static const String login = 'login';
  static const String register = 'register';
  static const String pendingApproval = 'pendingApproval';

  // Dashboard names
  static const String studentDashboard = 'studentDashboard';
  static const String teacherDashboard = 'teacherDashboard';
  static const String adminDashboard = 'adminDashboard';
  static const String superAdminDashboard = 'superAdminDashboard';

  static const String quizManagement = 'quizManagement';
}

// We create the list of routes here and our routerProvider will use it.
final List<GoRoute> appRoutes = [
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
    path: AppRoutePaths.register,
    name: AppRouteNames.register,
    builder: (context, state) => const RegisterScreen(),
  ),
  GoRoute(
    path: AppRoutePaths.pendingApproval,
    name: AppRouteNames.pendingApproval,
    builder: (context, state) => const ApprovalPendingScreen(),
  ),

  // --- DASHBOARD ROUTES ---
  GoRoute(
    path: AppRoutePaths.studentDashboard,
    name: AppRouteNames.studentDashboard,
    builder: (context, state) => const StudentHomeScreen(),
  ),
  GoRoute(
    path: AppRoutePaths.teacherDashboard,
    name: AppRouteNames.teacherDashboard,
    builder: (context, state) => const TeacherDashboard(),
  ),
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

  // This is the route for managing quizzes for a specific subject
  GoRoute(
    path: AppRoutePaths.quizManagement,
    name: AppRouteNames.quizManagement,
    builder: (context, state) {
      // 3. We retrieve the 'SubjectModel' object that
      //    we will pass via the 'extra' parameter on navigation.
      final SubjectModel subject = state.extra as SubjectModel;

      // 4. We build the screen and pass the subject to it.
      return QuizManagementScreen(subject: subject);
    },
  ),
];
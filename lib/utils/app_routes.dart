import 'package:go_router/go_router.dart';
import 'package:quiz_panel/models/quiz_model.dart';
import 'package:quiz_panel/models/subject_model.dart';
import 'package:quiz_panel/screens/admin/admin_dashboard.dart';
import 'package:quiz_panel/screens/auth/approval_pending_screen.dart';
import 'package:quiz_panel/screens/auth/login_screen.dart';
import 'package:quiz_panel/screens/auth/register_screen.dart';
import 'package:quiz_panel/screens/splash/splash_screen.dart';
import 'package:quiz_panel/screens/student/student_home_screen.dart';
import 'package:quiz_panel/screens/super_admin/super_admin_dashboard.dart';
import 'package:quiz_panel/screens/teacher/question_management_screen.dart'; // New
import 'package:quiz_panel/screens/teacher/quiz_management_screen.dart';
import 'package:quiz_panel/screens/teacher/teacher_dashboard.dart';

// This class holds all our route 'paths'
class AppRoutePaths {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String pendingApproval = '/pending-approval';

  // Teacher paths
  static const String teacherDashboard = '/teacher/dashboard';
  static const String quizManagement = '/teacher/subjects/:subjectId';
  static const String questionManagement = '/teacher/quizzes/:quizId/questions';

  // Student paths
  static const String studentDashboard = '/student/dashboard';

  // Admin paths
  static const String adminDashboard = '/admin/dashboard';
  static const String superAdminDashboard = '/superadmin/dashboard';
}

// This class holds all our route 'names'
class AppRouteNames {
  static const String splash = 'splash';
  static const String login = 'login';
  static const String register = 'register';
  static const String pendingApproval = 'pendingApproval';

  // Teacher names
  static const String teacherDashboard = 'teacherDashboard';
  static const String quizManagement = 'quizManagement';
  static const String questionManagement = 'questionManagement';

  // Student names
  static const String studentDashboard = 'studentDashboard';

  // Admin names
  static const String adminDashboard = 'adminDashboard';
  static const String superAdminDashboard = 'superAdminDashboard';
}

// This is the single source of truth for all our routes.
// We create the list of routes here and our routerProvider will use it.
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
    path: AppRoutePaths.register,
    name: AppRouteNames.register,
    builder: (context, state) => const RegisterScreen(),
  ),
  GoRoute(
    path: AppRoutePaths.pendingApproval,
    name: AppRouteNames.pendingApproval,
    builder: (context, state) => const ApprovalPendingScreen(),
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
      // Get the SubjectModel object passed during navigation
      final SubjectModel? subject = state.extra as SubjectModel?;
      if (subject == null) {
        // If we land here with no data, go back to safety
        return const TeacherDashboard();
      }
      return QuizManagementScreen(subject: subject);
    },
  ),
  GoRoute(
    path: AppRoutePaths.questionManagement,
    name: AppRouteNames.questionManagement,
    builder: (context, state) {
      // Get the QuizModel object passed during navigation
      final QuizModel? quiz = state.extra as QuizModel?;
      if (quiz == null) {
        // If we land here with no data, go back to safety
        // (Ideally, we'd go back to the *previous* screen,
        // but TeacherDashboard is safer for now)
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
];


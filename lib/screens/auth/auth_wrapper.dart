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

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. We now watch 'userDataProvider' (Manager 2)
    //    This provider depends on 'authStateProvider' (Manager 1)
    //    So we only need to watch this one.
    final userData = ref.watch(userDataProvider);

    // We use .when() to decide what to show.
    return userData.when(

      // 3. DATA: We have a result (UserModel or null)
      data: (userModel) {

        // 3a. If userModel is NULL, user is logged out.
        if (userModel == null) {
          return const LoginScreen();
        }

        // 3b. If userModel is NOT NULL, user is logged in.
        //     Now we check their STATUS.
        if (userModel.status == UserStatus.pending) {
          return const ApprovalPendingScreen();
        }

        if (userModel.status == UserStatus.rejected) {
          // TODO: Create a 'RejectedScreen'
          // For now, show pending screen
          return const ApprovalPendingScreen();
        }

        // 3c. If status is 'approved', check their ROLE.
        switch (userModel.role) {
          case UserRoles.superAdmin:
            return const SuperAdminDashboard();
          case UserRoles.admin:
            return const AdminDashboard();
          case UserRoles.teacher:
            return const TeacherDashboard();
          case UserRoles.student:
            return const StudentHomeScreen();
          default:
          // If role is unknown, send to login
            return const LoginScreen();
        }
      },

      // 4. ERROR: Something went wrong fetching user data
      error: (error, stackTrace) {
        return Scaffold(
          body: Center(
            // Use the clean error message
            child: Text('Error: ${error.toString()}'),
          ),
        );
      },

      // 5. LOADING: We are checking auth AND fetching user data
      loading: () {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
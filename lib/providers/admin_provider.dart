// lib/providers/admin_provider.dart


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_panel/models/user_model.dart';
import 'package:quiz_panel/repositories/admin_repository.dart';
// 1. Import the providers we need to check the role
import 'package:quiz_panel/providers/user_data_provider.dart';
import 'package:quiz_panel/utils/constants.dart';

// --- 1. Stream Provider for Pending Teachers ---

// We keep .autoDispose, which is good practice
final pendingTeachersProvider = StreamProvider.autoDispose<List<UserModel>>((ref) {

  // 2. --- THE FIX ---
  //    Watch the *current* user's data
  final currentUserData = ref.watch(userDataProvider);

  // Use .when() to check the current user's role
  return currentUserData.when(
    data: (user) {
      // 3. Check if a user is logged in AND is an admin/super_admin
      if (user != null &&
          (user.role == UserRoles.admin || user.role == UserRoles.superAdmin)) {

        // 4. ONLY if they are an admin, watch the repo
        //    This is the compound query that needs the index.
        final adminRepo = ref.watch(adminRepositoryProvider);
        return adminRepo.getPendingTeachers();
      } else {
        // 5. If user is null, or a student, or a teacher,
        //    do NOT run the query. Just return an empty list.
        //    This prevents the 400 Bad Request error for non-admins.
        return Stream.value([]);
      }
    },
    // If user data is loading or has an error, also return an empty list
    loading: () => Stream.value([]),
    error: (e, s) => Stream.value([]),
  );
  // --- END FIX ---
});

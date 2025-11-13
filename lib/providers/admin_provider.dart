import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_panel/models/user_model.dart';
import 'package:quiz_panel/repositories/admin_repository.dart';

// 1. Import the providers we need to check the role
import 'package:quiz_panel/providers/user_data_provider.dart';
import 'package:quiz_panel/utils/constants.dart';

// --- 1. Stream Provider for Pending Teachers (Unchanged) ---

final pendingTeachersProvider = StreamProvider.autoDispose<List<UserModel>>((
    ref,
    ) {
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
});

// --- 2. NEW: Provider for All Teachers ---
final allTeachersProvider = StreamProvider.autoDispose<List<UserModel>>((ref) {
  final currentUserData = ref.watch(userDataProvider);
  return currentUserData.when(
    data: (user) {
      if (user != null && (user.role == UserRoles.admin || user.role == UserRoles.superAdmin)) {
        return ref.watch(adminRepositoryProvider).getUsersByRole(UserRoles.teacher);
      }
      return Stream.value([]);
    },
    loading: () => Stream.value([]),
    error: (e, s) => Stream.error(e,s), // Pass error along
  );
});

// --- 3. NEW: Provider for All Students ---
final allStudentsProvider = StreamProvider.autoDispose<List<UserModel>>((ref) {
  final currentUserData = ref.watch(userDataProvider);
  return currentUserData.when(
    data: (user) {
      if (user != null && (user.role == UserRoles.admin || user.role == UserRoles.superAdmin)) {
        return ref.watch(adminRepositoryProvider).getUsersByRole(UserRoles.student);
      }
      return Stream.value([]);
    },
    loading: () => Stream.value([]),
    error: (e, s) => Stream.error(e,s), // Pass error along
  );
});

// --- 4. NEW: Provider for All Admins (Super Admin Only) ---
final allAdminsProvider = StreamProvider.autoDispose<List<UserModel>>((ref) {
  final currentUserData = ref.watch(userDataProvider);
  return currentUserData.when(
    data: (user) {
      // This one is ONLY for Super Admin
      if (user != null && user.role == UserRoles.superAdmin) {
        return ref.watch(adminRepositoryProvider).getUsersByRole(UserRoles.admin);
      }
      return Stream.value([]);
    },
    loading: () => Stream.value([]),
    error: (e, s) => Stream.error(e,s), // Pass error along
  );
});


// --- 5. Stream Provider for All Users (DEPRECATED by dashboards, but kept for now) ---
// This provider fetches all users for the Super Admin
final allUsersProvider = StreamProvider.autoDispose<List<UserModel>>((ref) {
  // Watch the current user's data
  final currentUserData = ref.watch(userDataProvider);

  // Use .when() to check the current user's role
  return currentUserData.when(
    data: (user) {
      // Check if a user is logged in AND is an admin/super_admin
      if (user != null &&
          (user.role == UserRoles.admin || user.role == UserRoles.superAdmin)) {
        // ONLY if they are an admin, watch the repo and call the new function
        final adminRepo = ref.watch(adminRepositoryProvider);
        return adminRepo.getAllUsers();
      } else {
        // If user is null, or not an admin, do NOT run the query.
        return Stream.value([]);
      }
    },
    // If user data is loading or has an error, also return an empty list
    loading: () => Stream.value([]),
    error: (e, s) => Stream.value([]),
  );
});

// --- 6. Stream Provider for Managed Users (DEPRECATED by dashboards, but kept for now) ---
final adminManagedUsersProvider =
StreamProvider.autoDispose<List<UserModel>>((ref) {
  final currentUserData = ref.watch(userDataProvider);

  return currentUserData.when(
    data: (user) {
      // Yeh provider sirf Admin ke liye chalega
      if (user != null && user.role == UserRoles.admin) {
        final adminRepo = ref.watch(adminRepositoryProvider);
        // Naya function call karein
        return adminRepo.getManagedUsers();
      } else {
        return Stream.value([]);
      }
    },
    loading: () => Stream.value([]),
    error: (e, s) => Stream.value([]),
  );
});
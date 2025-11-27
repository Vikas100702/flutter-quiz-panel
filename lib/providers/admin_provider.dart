import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_panel/models/user_model.dart';
import 'package:quiz_panel/repositories/admin_repository.dart';
import 'package:quiz_panel/providers/user_data_provider.dart';
import 'package:quiz_panel/utils/constants.dart';

/// **What is this file for?**
/// This file acts as the "State Management" hub for all Admin-related data.
/// It defines "Providers" that fetch specific lists of users (like pending teachers, students, etc.)
/// from the database and feed them to the UI.
///
/// **Why do we need separate providers?**
/// Instead of having one giant list of users and filtering it on the screen (which is slow),
/// we create specific providers for specific needs. This makes the app faster and easier to manage.

/// **1. Provider: Pending Teachers (pendingTeachersProvider)**
///
/// **Why we used this:**
/// The Admin Dashboard needs to show a notification or list of teachers waiting for approval.
/// This provider listens specifically for that data.
///
/// **How it works:**
/// 1. It checks who is currently logged in.
/// 2. If the user is an Admin or Super Admin, it asks the `AdminRepository` to fetch the list.
/// 3. If the user is a Student or Teacher, it returns an empty list (security check).
/// 4. Because it is a `StreamProvider`, the list updates automatically in real-time if a new teacher registers.
final pendingTeachersProvider = StreamProvider.autoDispose<List<UserModel>>((ref) {
  // We watch 'userDataProvider' to get the current user's profile details.
  final currentUserData = ref.watch(userDataProvider);

  // We use '.when' to safely handle the loading, error, and data states of the user profile.
  return currentUserData.when(
    data: (user) {
      // **Security Check:**
      // Only run the database query if the user is an Admin or Super Admin.
      if (user != null &&
          (user.role == UserRoles.admin || user.role == UserRoles.superAdmin)) {

        // Fetch the AdminRepository.
        final adminRepo = ref.watch(adminRepositoryProvider);

        // Call the specific function to get pending teachers.
        return adminRepo.getPendingTeachers();
      } else {
        // If the user is not authorized, return an empty stream to prevent errors.
        return Stream.value([]);
      }
    },
    // If the user data is still loading or has an error, return an empty list.
    loading: () => Stream.value([]),
    error: (e, s) => Stream.value([]),
  );
});

/// **2. Provider: All Teachers (allTeachersProvider)**
///
/// **Why we used this:**
/// Allows Admins to view a directory of all registered teachers to manage them (e.g., deactivate account).
///
/// **How it works:**
/// It reuses the same security logic as above but asks the repository for users with the role 'teacher'.
final allTeachersProvider = StreamProvider.autoDispose<List<UserModel>>((ref) {
  final currentUserData = ref.watch(userDataProvider);

  return currentUserData.when(
    data: (user) {
      if (user != null && (user.role == UserRoles.admin || user.role == UserRoles.superAdmin)) {
        // Call repository to search for 'teacher' role.
        return ref.watch(adminRepositoryProvider).getUsersByRole(UserRoles.teacher);
      }
      return Stream.value([]);
    },
    loading: () => Stream.value([]),
    error: (e, s) => Stream.error(e,s),
  );
});

/// **3. Provider: All Students (allStudentsProvider)**
///
/// **Why we used this:**
/// Allows Admins to view and manage all student accounts.
///
/// **How it works:**
/// Identical to the teacher provider, but asks the repository for users with the role 'student'.
final allStudentsProvider = StreamProvider.autoDispose<List<UserModel>>((ref) {
  final currentUserData = ref.watch(userDataProvider);

  return currentUserData.when(
    data: (user) {
      if (user != null && (user.role == UserRoles.admin || user.role == UserRoles.superAdmin)) {
        // Call repository to search for 'student' role.
        return ref.watch(adminRepositoryProvider).getUsersByRole(UserRoles.student);
      }
      return Stream.value([]);
    },
    loading: () => Stream.value([]),
    error: (e, s) => Stream.error(e,s),
  );
});

/// **4. Provider: All Admins (allAdminsProvider)**
///
/// **Why we used this:**
/// This is a special provider ONLY for the **Super Admin**. Regular Admins cannot manage other Admins.
///
/// **How it works:**
/// The security check here is stricter: `user.role == UserRoles.superAdmin`.
final allAdminsProvider = StreamProvider.autoDispose<List<UserModel>>((ref) {
  final currentUserData = ref.watch(userDataProvider);

  return currentUserData.when(
    data: (user) {
      // **Strict Security Check:** Only Super Admin can see this list.
      if (user != null && user.role == UserRoles.superAdmin) {
        return ref.watch(adminRepositoryProvider).getUsersByRole(UserRoles.admin);
      }
      return Stream.value([]);
    },
    loading: () => Stream.value([]),
    error: (e, s) => Stream.error(e,s),
  );
});

/// **5. Provider: All Users (allUsersProvider)**
///
/// **Status:** *Deprecated (Legacy)*
///
/// **Why we used this:**
/// Originally intended to show everyone mixed together.
/// We keep it for reference, but the categorized providers above are preferred for cleaner UI.
final allUsersProvider = StreamProvider.autoDispose<List<UserModel>>((ref) {
  final currentUserData = ref.watch(userDataProvider);

  return currentUserData.when(
    data: (user) {
      if (user != null &&
          (user.role == UserRoles.admin || user.role == UserRoles.superAdmin)) {
        final adminRepo = ref.watch(adminRepositoryProvider);
        return adminRepo.getAllUsers();
      } else {
        return Stream.value([]);
      }
    },
    loading: () => Stream.value([]),
    error: (e, s) => Stream.value([]),
  );
});

/// **6. Provider: Managed Users (adminManagedUsersProvider)**
///
/// **Status:** *Deprecated (Legacy)*
///
/// **Why we used this:**
/// Was used to show Students + Teachers together for regular Admins.
final adminManagedUsersProvider = StreamProvider.autoDispose<List<UserModel>>((ref) {
  final currentUserData = ref.watch(userDataProvider);

  return currentUserData.when(
    data: (user) {
      if (user != null && user.role == UserRoles.admin) {
        final adminRepo = ref.watch(adminRepositoryProvider);
        return adminRepo.getManagedUsers();
      } else {
        return Stream.value([]);
      }
    },
    loading: () => Stream.value([]),
    error: (e, s) => Stream.value([]),
  );
});
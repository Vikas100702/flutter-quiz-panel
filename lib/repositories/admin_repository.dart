// lib/repositories/admin_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_panel/models/user_model.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/utils/constants.dart';

/// **What is this Provider? (adminRepositoryProvider)**
/// This provider creates and exposes our `AdminRepository`.
///
/// **Why do we need it?**
/// Instead of creating a new instance of the repository in every widget (which is inefficient),
/// we use this provider. Any Admin-related screen can simply read this provider to access
/// the database functions defined below.
final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  // Dependency Injection: We inject the specific instance of Firestore we want to use.
  return AdminRepository(FirebaseFirestore.instance);
});

/// **Why we used this class (AdminRepository):**
/// This class handles all the "Business Logic" for administrative tasks.
/// If an Admin needs to approve a teacher, ban a student, or view a list of users,
/// the logic lives here. It separates the Database code from the UI code.
class AdminRepository {
  final FirebaseFirestore _db;

  AdminRepository(this._db);

  // --- 1. Get Pending Teachers ---

  /// **Logic: Fetch Pending Approvals**
  /// This function provides a list of teachers who have registered but are not yet allowed to login.
  ///
  /// **How it works:**
  /// 1. It queries the `users` collection.
  /// 2. It filters for `role == teacher` AND `status == pending`.
  /// 3. It returns a **Stream**. This means if a new teacher registers right now,
  ///    the Admin's screen will update automatically without refreshing.
  Stream<List<UserModel>> getPendingTeachers() {
    try {
      return _db
          .collection('users')
          .where('role', isEqualTo: UserRoles.teacher)
          .where('status', isEqualTo: UserStatus.pending)
          .snapshots() // Listen for real-time updates.
          .map((snapshot) {
            // Convert the raw database documents into our 'UserModel' objects.
            return snapshot.docs
                .map((doc) => UserModel.fromFirestore(doc))
                .toList();
          });
    } catch (e) {
      // If permission is denied or an error occurs, return an empty list gracefully.
      return Stream.value([]);
    }
  }

  // --- 2. Approve a User ---

  /// **Logic: Approve Teacher**
  /// This function officially grants access to a pending teacher.
  ///
  /// **How it works:**
  /// It finds the user's document by their `uid` and updates two fields:
  /// - `status`: Changed to 'approved'.
  /// - `approvedBy`: Records the UID of the Admin who clicked the button (for audit logs).
  Future<void> approveUser({
    required String uid,
    required String approvedByUid,
  }) async {
    try {
      final userDocRef = _db.collection('users').doc(uid);

      await userDocRef.update({
        'status': UserStatus.approved,
        'approvedBy': approvedByUid,
      });
    } on FirebaseException catch (e) {
      throw e.message ?? AppStrings.genericError;
    } catch (e) {
      throw AppStrings.genericError;
    }
  }

  // --- 3. Reject a User ---

  /// **Logic: Reject Teacher**
  /// This denies access to a pending teacher.
  ///
  /// **How it works:**
  /// It updates the `status` field to 'rejected'. The user will remain in the database
  /// but will be blocked from logging in by our `AppRouterProvider`.
  Future<void> rejectUser({required String uid}) async {
    try {
      final userDocRef = _db.collection('users').doc(uid);

      await userDocRef.update({'status': UserStatus.rejected});
    } on FirebaseException catch (e) {
      throw e.message ?? AppStrings.genericError;
    } catch (e) {
      throw AppStrings.genericError;
    }
  }

  // --- 4. Get All Users (Super Admin Only) ---

  /// **Logic: View Full User Database**
  /// This is a powerful query intended for Super Admins to see everyone in the system.
  ///
  /// **How it works:**
  /// It fetches every document in the `users` collection, sorted by when they joined (`createdAt`).
  Stream<List<UserModel>> getAllUsers() {
    try {
      return _db
          .collection('users')
          .orderBy('createdAt', descending: true) // Newest users first.
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => UserModel.fromFirestore(doc))
                .toList();
          });
    } catch (e) {
      return Stream.value([]);
    }
  }

  // --- 5. Deactivate/Reactivate User ---

  /// **Logic: Ban/Unban User**
  /// This allows an Admin to temporarily disable an account without deleting it.
  ///
  /// **How it works:**
  /// It toggles the `isActive` boolean field. If `false`, the login screen will block them.
  Future<void> updateUserActiveStatus({
    required String uid,
    required bool isActive,
  }) async {
    try {
      final userDocRef = _db.collection('users').doc(uid);
      await userDocRef.update({'isActive': isActive});
    } on FirebaseException catch (e) {
      throw e.message ?? AppStrings.genericError;
    } catch (e) {
      throw AppStrings.genericError;
    }
  }

  // --- 6. Update User Role (Super Admin Only) ---

  /// **Logic: Promote/Demote User**
  /// Allows changing a user's role (e.g., promoting a Teacher to an Admin).
  ///
  /// **How it works:**
  /// Simply updates the `role` string field in the user's document.
  Future<void> updateUserRole({
    required String uid,
    required String newRole,
  }) async {
    try {
      final userDocRef = _db.collection('users').doc(uid);
      await userDocRef.update({'role': newRole});
    } on FirebaseException catch (e) {
      throw e.message ?? AppStrings.genericError;
    } catch (e) {
      throw AppStrings.genericError;
    }
  }

  // --- 7. Get Managed Users (Admin Only) ---

  /// **Logic: View Manageable Users**
  /// Regular Admins cannot manage other Admins or Super Admins.
  /// This query fetches ONLY 'Teachers' and 'Students'.
  ///
  /// **How it works:**
  /// It uses the `whereIn` operator to filter for multiple values at once.
  Stream<List<UserModel>> getManagedUsers() {
    try {
      return _db
          .collection('users')
          .where('role', whereIn: [UserRoles.teacher, UserRoles.student])
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => UserModel.fromFirestore(doc))
                .toList();
          });
    } catch (e) {
      return Stream.value([]);
    }
  }

  // --- 8. Get Users by Specific Role ---

  /// **Logic: Filter Users by Role**
  /// This helps in the dashboard when we click "All Students" or "All Teachers".
  ///
  /// **Technical Note:**
  /// Because we filter by `role` AND sort by `displayName`, Firestore requires a
  /// "Composite Index". If this query fails, check the debug console for a link to create it.
  Stream<List<UserModel>> getUsersByRole(String role) {
    try {
      return _db
          .collection('users')
          .where('role', isEqualTo: role)
          .orderBy('displayName', descending: false) // A-Z sorting
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => UserModel.fromFirestore(doc))
                .toList();
          });
    } catch (e) {
      return Stream.error(e);
    }
  }

  // --- 9. Get Extra Profile Data ---

  /// **Logic: Fetch Detailed Profile**
  /// Our `users` collection only holds basic info (Auth data).
  /// Extra details (like a Student's Grade or a Teacher's Qualification) are stored
  /// in separate collections (`student_profiles` or `teacher_profiles`).
  ///
  /// **How it works:**
  /// 1. It checks the user's role to decide which collection to look in.
  /// 2. It fetches the document with the same `uid`.
  /// 3. It returns the data as a Map to be displayed on the User Details screen.
  Future<Map<String, dynamic>> getRoleProfileData(
    String uid,
    String role,
  ) async {
    String profileCollection;

    // Determine the correct collection based on role.
    if (role == UserRoles.student) {
      profileCollection = 'student_profiles';
    } else if (role == UserRoles.teacher) {
      profileCollection = 'teacher_profiles';
    } else {
      // Admins don't have a separate profile collection, return empty.
      return {};
    }

    try {
      final docSnap = await _db.collection(profileCollection).doc(uid).get();
      if (docSnap.exists) {
        return docSnap.data() as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      return {};
    }
  }
}

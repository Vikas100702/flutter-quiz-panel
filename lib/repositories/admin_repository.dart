import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_panel/models/user_model.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/utils/constants.dart';

// --- 1. Provider for the Repository ---
final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(FirebaseFirestore.instance);
});

// --- 2. The Repository Class ---

// This class handles actions performed by Admins
// e.g., fetching users, approving users, etc.

class AdminRepository {
  final FirebaseFirestore _db;

  AdminRepository(this._db);

  // --- 3. Get Pending Teachers ---
  // This function returns a LIVE STREAM of all users
  // who are 'teachers' and whose status is 'pending_approval'.

  Stream<List<UserModel>> getPendingTeachers() {
    try {
      // We look in the 'users' collection
      return _db
          .collection('users')
          .where('role', isEqualTo: UserRoles.teacher)
          .where('status', isEqualTo: UserStatus.pending)
          .snapshots() // 'snapshots()' returns a Stream, so our UI will update automatically when a new teacher registers.
          .map((snapshot) {
            // We convert the list of documents into a list of UserModel objects
            return snapshot.docs
                .map((doc) => UserModel.fromFirestore(doc))
                .toList();
          });
    } catch (e) {
      // If the stream fails, return an empty list
      return Stream.value([]);
    }
  }

  // --- 4. Approve a User ---
  // This function updates a user's status to 'approved'.
  Future<void> approveUser({
    required String uid,
    required String approvedByUid, // The UID of the admin doing the approving
  }) async {
    try {
      // Get the document for the user we want to approve
      final userDocRef = _db.collection('users').doc(uid);

      // Update their status
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

  // --- 5. Reject a User ---
  // This function updates a user's status to 'rejected'.
  Future<void> rejectUser({required String uid}) async {
    try {
      // Get the document for the user we want to reject
      final userDocRef = _db.collection('users').doc(uid);

      // Update their status
      await userDocRef.update({'status': UserStatus.rejected});
    } on FirebaseException catch (e) {
      throw e.message ?? AppStrings.genericError;
    } catch (e) {
      throw AppStrings.genericError;
    }
  }

  // --- 6. Get All Users ---
  Stream<List<UserModel>> getAllUsers() {
    try {
      return _db
          .collection('users')
          .orderBy(
            'createdAt',
            descending: true,
          ) // Order by creation date, new users will be at top
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => UserModel.fromFirestore(doc))
                .toList();
          });
    } catch (e) {
      return Stream.value([]); // If the stream fails, return an empty list
    }
  }

  // --- 7. Deactivate/Reactivate User ---
  // This function updates a user's 'isActive' status.
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

  // --- 8. Update User Role ---
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

  // TODO: Hum yahaan future mein aur functions add karenge:
// - Future<void> deleteUser({required String uid})
// - Future<void> updateUserRole({required String uid, required String newRole})
}

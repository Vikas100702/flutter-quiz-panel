import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_panel/models/user_model.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/utils/constants.dart';

// Provider for the Repository
// This provider creates our UserRepository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(FirebaseFirestore.instance);
});

// Repository class
class UserRepository {
  final FirebaseFirestore _db;

  UserRepository(this._db);

  // Get user data from Firestore
  Future<UserModel> getUserData(String uid) async {
    try {
      final docSnap = await _db.collection('users').doc(uid).get();

      if (docSnap.exists) {
        return UserModel.fromFirestore(docSnap);
      } else {
        throw AppStrings.userDataNotFound;
      }
    } on FirebaseException catch (e) {
      throw e.message ?? AppStrings.genericError;
    }
  }

  // Register user in firestore (For Email/Password)
  // This function saves the user's data to the
  // 'users' collection after they are created in Auth.
  Future<void> registerUserInFireStore({
    required UserCredential userCredential,
    required String name,
    required String role, // This will be 'student' or 'teacher'
  }) async {

    try {
      // Determine the status based on the role
      String status;
      if(role == UserRoles.student) {
        // Students are auto-approved (but will need email verification)
        status = UserStatus.approved;
      } else if(role == UserRoles.teacher) {
        // Teachers must be approved by an admin or super admin
        status = UserStatus.pending;
      } else {
        // Failsafe, should not happen from register screen
        status = UserStatus.rejected;
      }

      // Create the UserModel object
      final newUser = UserModel(
        uid: userCredential.user!.uid,
        role: role,
        status: status,
        displayName: name,
        email: userCredential.user?.email ?? '',
        phoneNumber: userCredential.user?.phoneNumber,
        photoURL: userCredential.user?.photoURL,
        authProviders: ['password'], // --- UPDATED ---: Specify auth provider
        createdAt: Timestamp.now(),
        approvedBy: null, // No one has approved yet
        isActive: true,
      );

      // Create a WriteBatch to save all data at once
      // A 'batch' ensures that either ALL writes succeed, or ALL fail.
      // This prevents having a user in 'users' but not in 'profiles'
      final batch = _db.batch();

      // Set the main user document in 'users' collection
      final userDocRef = _db.collection('users').doc(newUser.uid);

      // We must convert our UserModel to a Map to save it.
      batch.set(userDocRef, newUser.toMap());

      // Create the profile documents
      if(role == UserRoles.student) {
        // Create a document in 'student_profiles'
        final profileDocRef = _db.collection('student_profiles').doc(newUser.uid);
        batch.set(profileDocRef, {
          'studentId': newUser.uid,
          'name': name,
          'email': newUser.email,
          'institution': null, // Can be filled out by user later
          'grade': null, // Can be filled out by user later
        });
      } else if(role == UserRoles.teacher) {
        // Create a document in 'teacher_profiles'
        final profileDocRef = _db.collection('teacher_profiles').doc(newUser.uid);
        batch.set(profileDocRef, {
          'teacherId': newUser.uid,
          'name': name,
          'email': newUser.email,
          'qualification': null, // Can be filled out by user later
          'specialization': [],
        });
      }

      // Commit (save) the batch
      await batch.commit();

      // TODO:
      // We will add more functions here later, such as:
      // - updateUserData(...)
      // - approveUser(...)
    } on FirebaseException catch (e) {
      throw e.message ?? AppStrings.genericError;
    } catch (e) {
      throw AppStrings.genericError;
    }
  }

  // --- NEW FUNCTION (For Google Sign-In) ---
  Future<void> registerGoogleUserInFirestore({
    required UserCredential userCredential,
  }) async {
    try {
      final user = userCredential.user;
      if (user == null) return;

      final userDocRef = _db.collection('users').doc(user.uid);
      final docSnap = await userDocRef.get();

      // 1. Check if user ALREADY exists in Firestore
      if (docSnap.exists) {
        // User already exists, maybe update their photoURL or auth provider list
        await userDocRef.update({
          'photoURL': user.photoURL,
          'authProviders': FieldValue.arrayUnion(['google.com']),
        });
        return;
      }

      // 2. If user does NOT exist, create them
      // Google users are auto-approved and default to 'student'
      final newUser = UserModel(
        uid: user.uid,
        role: UserRoles.student,
        status: UserStatus.approved,
        displayName: user.displayName ?? 'Google User',
        email: user.email ?? '',
        phoneNumber: user.phoneNumber,
        photoURL: user.photoURL,
        authProviders: ['google.com'], // Auth provider is Google
        createdAt: Timestamp.now(),
        approvedBy: 'google_auth', // Auto-approved
        isActive: true,
      );

      // Use a batch to create user and profile
      final batch = _db.batch();

      // Set user document
      batch.set(userDocRef, newUser.toMap());

      // Set student_profile document
      final profileDocRef = _db.collection('student_profiles').doc(newUser.uid);
      batch.set(profileDocRef, {
        'studentId': newUser.uid,
        'name': newUser.displayName,
        'email': newUser.email,
        'institution': null,
        'grade': null,
      });

      // Commit the batch
      await batch.commit();

    } on FirebaseException catch (e) {
      throw e.message ?? AppStrings.genericError;
    } catch (e) {
      throw AppStrings.genericError;
    }
  }
}
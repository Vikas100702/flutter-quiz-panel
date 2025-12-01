import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_panel/models/user_model.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/utils/constants.dart';

/// **What is this Provider? (userRepositoryProvider)**
/// This provider creates and exposes the `UserRepository`.
///
/// **Why do we need it?**
/// This allows any part of our app (like the Registration Screen or Profile Screen)
/// to access the database functions without needing to create a new connection every time.
final userRepositoryProvider = Provider<UserRepository>((ref) {
  // Dependency Injection: We inject the Firestore instance.
  return UserRepository(FirebaseFirestore.instance);
});

/// **Why we used this class (UserRepository):**
/// This class handles all "Write" and "Read" operations related to User Profiles in the database.
/// While `AuthRepository` handles *Login credentials*, this repository handles the
/// *Actual Data* (Name, Role, Grade, etc.) stored in Firestore.
class UserRepository {
  final FirebaseFirestore _db;

  UserRepository(this._db);

  // --- 1. Get User Data ---

  /// **Logic: Fetch Profile**
  /// Retrieves the full profile details of a logged-in user.
  ///
  /// **How it works:**
  /// 1. It looks for a document in the `users` collection with the matching `uid`.
  /// 2. If found, it converts the data into a `UserModel` object.
  /// 3. If not found (rare, but possible if registration failed midway), it throws a specific error.
  Future<UserModel> getUserData(String uid) async {
    try {
      final docSnap = await _db.collection('users').doc(uid).get();

      if (docSnap.exists) {
        return UserModel.fromFirestore(docSnap);
      } else {
        // Critical Error: User is logged in (Auth), but has no data (Firestore).
        // The AppRouter catches this to redirect them to a fix-it screen.
        throw AppStrings.userDataNotFound;
      }
    } on FirebaseException catch (e) {
      throw e.message ?? AppStrings.genericError;
    }
  }

  // --- 2. Register User (Email/Password) ---

  /// **Logic: Create New Account Profile**
  /// Called immediately after a user successfully signs up with Email & Password.
  ///
  /// **What it does:**
  /// 1. **Determines Status:** Automatically approves Students, but marks Teachers as 'pending'.
  /// 2. **Creates User Doc:** Saves the main user info (Role, Email, Name) in the `users` collection.
  /// 3. **Creates Role Profile:** Creates a separate document in `student_profiles` or `teacher_profiles`
  ///    to store role-specific data (like Grade or Qualifications).
  ///
  /// **How it is helpful:**
  /// It uses a **Batch Write**. This ensures that either *both* documents (User + Profile) are created,
  /// or *neither* is. This prevents "half-created" accounts if the internet cuts out.
  Future<void> registerUserInFireStore({
    required UserCredential userCredential,
    required String name,
    required String role, // This will be 'student' or 'teacher'
  }) async {
    try {
      // Step 1: Set initial status based on role.
      String status;
      if (role == UserRoles.student) {
        status = UserStatus.approved; // Students can enter immediately.
      } else if (role == UserRoles.teacher) {
        status = UserStatus.pending; // Teachers need Admin approval.
      } else {
        status = UserStatus.rejected; // Failsafe.
      }

      // Step 2: Prepare the main User Model.
      final newUser = UserModel(
        uid: userCredential.user!.uid,
        role: role,
        status: status,
        displayName: name,
        email: userCredential.user?.email ?? '',
        phoneNumber: userCredential.user?.phoneNumber,
        photoURL: userCredential.user?.photoURL,
        authProviders: ['password'],
        createdAt: Timestamp.now(),
        approvedBy: null,
        isActive: true,
      );

      // Step 3: Start a Batch (Atomic Operation).
      final batch = _db.batch();

      // Reference to the main user document.
      final userDocRef = _db.collection('users').doc(newUser.uid);
      batch.set(userDocRef, newUser.toMap());

      // Step 4: Create the secondary Role Profile document.
      if (role == UserRoles.student) {
        final profileDocRef = _db
            .collection('student_profiles')
            .doc(newUser.uid);
        batch.set(profileDocRef, {
          'studentId': newUser.uid,
          'name': name,
          'email': newUser.email,
          'institution': null, // Placeholder for future data.
          'grade': null,
        });
      } else if (role == UserRoles.teacher) {
        final profileDocRef = _db
            .collection('teacher_profiles')
            .doc(newUser.uid);
        batch.set(profileDocRef, {
          'teacherId': newUser.uid,
          'name': name,
          'email': newUser.email,
          'qualification': null,
          'specialization': [],
        });
      }

      // Step 5: Save everything at once.
      await batch.commit();
    } on FirebaseException catch (e) {
      throw e.message ?? AppStrings.genericError;
    } catch (e) {
      throw AppStrings.genericError;
    }
  }

  // --- 3. Register Google User ---

  /// **Logic: Handle Google Sign-In**
  /// Called when a user signs in with Google.
  ///
  /// **How it works:**
  /// 1. **Check Existence:** It checks if this user already exists in our database.
  /// 2. **Existing User:** If yes, it just updates their Photo URL (in case they changed it on Google).
  /// 3. **New User:** If no, it creates a new account automatically.
  ///    - Note: Google users are auto-approved and defaulted to the 'Student' role.
  Future<void> registerGoogleUserInFirestore({
    required UserCredential userCredential,
  }) async {
    try {
      final user = userCredential.user;
      if (user == null) return;

      final userDocRef = _db.collection('users').doc(user.uid);
      final docSnap = await userDocRef.get();

      // Scenario A: User is returning (Login).
      if (docSnap.exists) {
        await userDocRef.update({
          'photoURL': user.photoURL,
          'authProviders': FieldValue.arrayUnion(['google.com']),
        });
        return;
      }

      // Scenario B: User is new (Registration).
      final newUser = UserModel(
        uid: user.uid,
        role: UserRoles.student, // Default to Student.
        status: UserStatus.approved, // Auto-approve.
        displayName: user.displayName ?? 'Google User',
        email: user.email ?? '',
        phoneNumber: user.phoneNumber,
        photoURL: user.photoURL,
        authProviders: ['google.com'],
        createdAt: Timestamp.now(),
        approvedBy: 'google_auth',
        isActive: true,
      );

      final batch = _db.batch();

      // Create User Doc
      batch.set(userDocRef, newUser.toMap());

      // Create Student Profile Doc
      final profileDocRef = _db.collection('student_profiles').doc(newUser.uid);
      batch.set(profileDocRef, {
        'studentId': newUser.uid,
        'name': newUser.displayName,
        'email': newUser.email,
        'institution': null,
        'grade': null,
      });

      await batch.commit();
    } on FirebaseException catch (e) {
      throw e.message ?? AppStrings.genericError;
    } catch (e) {
      throw AppStrings.genericError;
    }
  }

  // --- 4. Register Phone User ---

  /// **Logic: Handle Phone Sign-Up**
  /// Called after a user verifies their OTP for the first time.
  ///
  /// **Why is this special?**
  /// Unlike Email or Google, Phone Auth doesn't give us a Name or Email.
  /// We collect those in a separate screen (`PhoneRegisterDetailsScreen`) and then call this function.
  Future<void> registerPhoneUserInFirestore({
    required User user,
    required String name,
    required String role, // 'student' or 'teacher'
  }) async {
    try {
      final userDocRef = _db.collection('users').doc(user.uid);
      final docSnap = await userDocRef.get();

      // Safety check: Don't overwrite existing users.
      if (docSnap.exists) {
        return;
      }

      // **Policy:** All phone users start as 'pending'.
      // This is because we can't easily verify their identity like we can with Google.
      const status = UserStatus.pending;

      final newUser = UserModel(
        uid: user.uid,
        role: role,
        status: status,
        displayName: name,
        email: user.email ?? '', // Might be null for phone users.
        phoneNumber: user.phoneNumber ?? '',
        photoURL: user.photoURL,
        authProviders: ['phone'],
        createdAt: Timestamp.now(),
        approvedBy: null,
        isActive: true,
      );

      final batch = _db.batch();

      // Create User Doc
      batch.set(userDocRef, newUser.toMap());

      // Create Role Profile Doc
      if (role == UserRoles.student) {
        final profileDocRef = _db
            .collection('student_profiles')
            .doc(newUser.uid);
        batch.set(profileDocRef, {
          'studentId': newUser.uid,
          'name': name,
          'email': newUser.email,
          'phone': newUser.phoneNumber,
        });
      } else if (role == UserRoles.teacher) {
        final profileDocRef = _db
            .collection('teacher_profiles')
            .doc(newUser.uid);
        batch.set(profileDocRef, {
          'teacherId': newUser.uid,
          'name': name,
          'email': newUser.email,
          'phone': newUser.phoneNumber,
        });
      }

      await batch.commit();
    } on FirebaseException catch (e) {
      throw e.message ?? AppStrings.genericError;
    } catch (e) {
      throw AppStrings.genericError;
    }
  }

  // --- 5. Update User Profile ---

  /// **Logic: Edit Profile**
  /// Allows users to change their Name or Phone Number from the 'Manage Profile' screen.
  ///
  /// **How it works:**
  /// 1. It prepares a map of only the changed fields.
  /// 2. It updates the main `users` document.
  /// 3. It intelligently finds the correct `_profiles` document (student or teacher)
  ///    and updates that too, keeping data in sync.
  Future<void> updateUserData(
    String uid, {
    String? displayName,
    String? phoneNumber,
  }) async {
    try {
      final userDocRef = _db.collection('users').doc(uid);
      final Map<String, dynamic> dataToUpdate = {};

      if (displayName != null) {
        dataToUpdate['displayName'] = displayName;
      }
      if (phoneNumber != null) {
        dataToUpdate['phoneNumber'] = phoneNumber;
      }

      if (dataToUpdate.isNotEmpty) {
        // Update main user doc
        await userDocRef.update(dataToUpdate);

        // Fetch user to know their role
        final userDoc = await userDocRef.get();
        final user = UserModel.fromFirestore(userDoc);

        // Update the specific profile doc to match
        if (user.role == UserRoles.student) {
          final profileDocRef = _db.collection('student_profiles').doc(uid);
          await profileDocRef.update(dataToUpdate);
        } else if (user.role == UserRoles.teacher) {
          final profileDocRef = _db.collection('teacher_profiles').doc(uid);
          await profileDocRef.update(dataToUpdate);
        }
      }
    } on FirebaseException catch (e) {
      throw e.message ?? AppStrings.genericError;
    } catch (e) {
      throw AppStrings.genericError;
    }
  }
}

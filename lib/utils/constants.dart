// lib/utils/constants.dart

/*
/// Why we used this file:
/// This file centralizes all **Business Logic Constants** and fixed configuration values
/// used throughout the application (e.g., user types, access states, content states).

/// What it is doing:
/// It defines classes containing static string constants. These constants are used in the application's logic,
/// database schemas (Firestore keys/values), and security rules, rather than for display purposes (which is handled by `AppStrings`).

/// How it's helpful:
/// 1. **Data Consistency:** Ensures that the same string value is used everywhere (e.g., 'super_admin') to avoid typos in the database.
/// 2. **Maintainability:** If a role name needs to be changed (e.g., from 'teacher' to 'instructor'), it only needs to be updated here.
/// 3. **Clarity:** Code that reads `if (user.role == UserRoles.admin)` is clearer than `if (user.role == 'admin')`.

/// How it is working:
/// The classes are used statically; they are never instantiated. The fields are defined using `static const String` to ensure compile-time speed and immutability.
*/

// User Roles
/// What it is doing: Defines the four distinct user authorization levels in the application.
class UserRoles {
  static const String superAdmin =
      'super_admin'; // Highest authority, controls all users including other Admins.
  static const String admin =
      'admin'; // Manages Teachers, Students, and the approval queue.
  static const String teacher =
      'teacher'; // Creates and manages Subjects and Quizzes.
  static const String student =
      'student'; // Primary end-user role, takes quizzes.
}

// User Statuses
/// What it is doing: Defines the lifecycle states for a user account, particularly important for the Teacher/Admin approval workflow.
class UserStatus {
  static const String approved =
      'approved'; // User is fully authorized and can access their dashboard.
  static const String pending =
      'pending_approval'; // User has registered but is waiting for an Admin to review and grant access.
  static const String rejected =
      'rejected'; // User's request for access was denied by an Admin.
}

// Content Statuses (for Subjects and Quizzes)
/// What it is doing: Defines the visibility states for educational content (Subjects and Quizzes).
class ContentStatus {
  static const String published =
      'published'; // Content is active and visible to Students.
  static const String draft =
      'draft'; // Content is incomplete or under review; only visible to the creator (Teacher/Admin).
  static const String archived =
      'archived'; // Placeholder for future logic (e.g., hiding old content).
}

// Default Values
/// What it is doing: Provides safe, initial values used during the user registration process or when data is unexpectedly missing.
class DefaultValues {
  static const String defaultRole = UserRoles
      .student; // The default role assigned during registration if not specified.
  static const String defaultStatus = UserStatus
      .pending; // The safe default status for new users, forcing them through approval checks.
  static const String defaultDisplayName =
      'New User'; // Fallback name if the user profile is incomplete.
}

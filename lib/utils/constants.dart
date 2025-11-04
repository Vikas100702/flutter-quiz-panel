// This file holds constant values for our app's logic,
// like user roles or default values.
// This is different from AppStrings, which holds UI text.

// User Roles
class UserRoles {
  static const String superAdmin = 'super_admin';
  static const String admin = 'admin';
  static const String teacher = 'teacher';
  static const String student = 'student';
}

// User Statuses
class UserStatus {
  static const String approved = 'approved';
  static const String pending = 'pending_approval';
  static const String rejected = 'rejected';
}

// Default Values
class DefaultValues {
  static const String defaultRole = UserRoles.student;
  static const String defaultStatus = UserStatus.pending;
  static const String defaultDisplayName = 'New User';
}
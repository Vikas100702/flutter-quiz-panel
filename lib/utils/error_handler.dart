// lib/utils/error_handling.dart

/*
/// Why we used this file (ErrorHandling):
/// This utility class separates the task of interpreting raw error messages (often technical and confusing, like Firebase error codes or network exceptions)
/// from the code that generated them.

/// What it is doing:
/// 1. **Error Translation:** Contains a static method (`getUserFriendlyError`) that analyzes a technical error string and returns a simple, human-readable message to the user.
/// 2. **Type Checking:** Provides a helper method (`isNetworkError`) to quickly determine if an exception is related to connectivity.

/// How it is working:
/// It converts the dynamic error object to a lowercase string and uses simple string matching (`contains()`) to check for key phrases (e.g., 'timeout', 'weak password', 'network').
/// This allows the UI to display helpful error pop-ups instead of raw, confusing stack traces.

/// How it's helpful:
/// It significantly improves the user experience by giving clear instructions (e.g., "Check your internet.") instead of technical error codes (e.g., "network-request-failed"), guiding them toward a solution.
*/
class ErrorHandling {
  /// What it is doing: Analyzes the dynamic error object and converts it into a non-technical, easy-to-understand message for the end-user.
  static String getUserFriendlyError(dynamic error) {
    // How it is working: Converts the error object to a lowercase string for case-insensitive matching.
    final errorString = error.toString().toLowerCase();

    // What it is doing: Matches common network failures.
    if (errorString.contains('network') || errorString.contains('socket')) {
      return 'Network connection unavailable. Please check your internet.';
    } else if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again.';
    } else if (errorString.contains('permission') ||
        errorString.contains('access denied')) {
      // What it is doing: Matches authorization failures.
      return 'You don\'t have permission to perform this action.';
    } else if (errorString.contains('user not found')) {
      // What it is doing: Matches authentication failures (wrong email).
      return 'Account not found. Please check your credentials.';
    } else if (errorString.contains('invalid email')) {
      return 'Please enter a valid email address.';
    } else if (errorString.contains('wrong password')) {
      // What it is doing: Matches authentication failures (wrong password).
      return 'Incorrect password. Please try again.';
    } else if (errorString.contains('email already in use')) {
      // What it is doing: Matches registration validation errors.
      return 'This email is already registered. Please use a different email.';
    } else if (errorString.contains('weak password')) {
      // What it is doing: Matches registration validation errors.
      return 'Password is too weak. Please use a stronger password.';
    } else {
      // How it's helpful: Provides a safe, generic message for unknown errors.
      return 'An unexpected error occurred. Please try again.';
    }
  }

  /// What it is doing: Determines if the given error is purely a network-related issue.
  static bool isNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    // How it is working: Returns true if any common network keywords are present in the error string.
    return errorString.contains('network') ||
        errorString.contains('socket') ||
        errorString.contains('timeout');
  }
}

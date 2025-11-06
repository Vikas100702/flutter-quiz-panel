// lib/utils/error_handling.dart
class ErrorHandling {
  static String getUserFriendlyError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') || errorString.contains('socket')) {
      return 'Network connection unavailable. Please check your internet.';
    } else if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again.';
    } else if (errorString.contains('permission') || errorString.contains('access denied')) {
      return 'You don\'t have permission to perform this action.';
    } else if (errorString.contains('user not found')) {
      return 'Account not found. Please check your credentials.';
    } else if (errorString.contains('invalid email')) {
      return 'Please enter a valid email address.';
    } else if (errorString.contains('wrong password')) {
      return 'Incorrect password. Please try again.';
    } else if (errorString.contains('email already in use')) {
      return 'This email is already registered. Please use a different email.';
    } else if (errorString.contains('weak password')) {
      return 'Password is too weak. Please use a stronger password.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  static bool isNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') ||
        errorString.contains('socket') ||
        errorString.contains('timeout');
  }
}
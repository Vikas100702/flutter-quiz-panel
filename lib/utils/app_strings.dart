// lib/utils/app_strings.dart

/*
/// Why we used this file (AppStrings):
/// This class serves as the **Centralized Repository** for all user-facing text and messages displayed across the application.
/// It separates presentation data (the text the user reads) from application logic (the code that makes things work).

/// What it is doing:
/// It defines static string constants for titles, labels, button text, error messages, status updates, and instructions.

/// How it is working:
/// UI widgets reference these strings directly (e.g., `Text(AppStrings.loginTitle)`). This ensures consistent capitalization, spelling, and phrasing throughout the app.

/// How it's helpful:
/// 1. **Maintainability:** Changing a label only requires editing this one file.
/// 2. **Clarity:** Code that reads `AppStrings.loginButton` is clearer than code with a hardcoded string `"Login"`.
/// 3. **Internationalization (i18n):** It lays the foundational groundwork for future localization, as all text strings are already centralized.
*/
class AppStrings {
  // --- Login Screen ---
  // What it is doing: Strings used on the primary login and sign-in screen.
  static const String loginTitle = 'Admin & User Login';
  static const String emailLabel = 'Email';
  static const String passwordLabel = 'Password';
  static const String loginButton = 'Login';
  static const String loginWithGoogleButton = 'Sign in with Google';
  static const String forgotPassword = 'Forgot Password?';
  static const String noAccount = "Don't have an account?";
  static const String registerNow = 'Register Now';

  // --- Forgot Password Screen ---
  // What it is doing: Messages and labels specifically for the password recovery flow.
  static const String forgotPasswordTitle = 'Reset Password';
  static const String resetPasswordButton = 'Send Reset Link';
  static const String resetEmailSent = 'Reset Email Sent!';
  static const String checkEmailInstructions =
      'Check your email for password reset instructions';
  static const String emailNotFoundError =
      'No account found with this email address';
  static const String invalidEmailError = 'Please enter a valid email address';
  static const String resetFailedError =
      'Failed to send reset email. Please try again.';
  static const String enterEmailPrompt = 'Please enter your email address';

  // --- Register Screen ---
  // What it is doing: Strings used on the account creation and registration form.
  static const String registerTitle = 'Create Account';
  static const String nameLabel = 'Full Name';
  static const String iAmA = 'I am a...'; // Used for the role selection prompt.
  static const String student = 'Student';
  static const String teacher = 'Teacher';
  static const String registerButton = 'Register';
  static const String passwordMinLength =
      'Password must be at least 6 characters.'; // Used for input hints/validation.
  static const String haveAccount = 'Already have an account?';
  static const String loginNow = 'Login Now';

  // --- NEW PASSWORD ERRORS ---
  // What it is doing: Detailed error messages for password strength validation in the registration form.
  static const String passwordRequiredError = 'Password is required.';
  static const String passwordUppercaseError =
      'Password must contain an uppercase letter.';
  static const String passwordLowercaseError =
      'Password must contain a lowercase letter.';
  static const String passwordNumberError = 'Password must contain a number.';
  static const String passwordSpecialCharError =
      'Password must contain a special character (e.g., !@#\$%).';

  // --- Email Verify Screen ---
  // What it is doing: Strings shown to users who need to verify their email address after registration.
  static const String verifyEmailTitle = 'Verify Your Email';
  static const String verifyEmailMessage =
      'A verification link has been sent to:';
  static const String checkYourInbox =
      'Please check your inbox (and spam folder) to verify your account.';
  static const String resendEmailButton = 'Resend Email';
  static const String resendEmailSuccess = 'Verification email sent!';
  static const String resendEmailCooldown =
      'You can resend in %s seconds'; // %s is a placeholder for the countdown timer.
  static const String refreshStatusButton = 'I\'ve Verified, Continue';

  // --- Error Messages ---
  // What it is doing: General purpose error and status messages used across the repository and UI.
  static const String genericError =
      'An unknown error occurred. Please try again.';
  static const String networkError =
      'Network error. Please check your internet connection.';
  static const String userNotFound = 'No user found for that email.';
  static const String wrongPassword = 'Wrong password provided for that user.';
  static const String noInternet =
      'No internet connection. Please check your network settings.';
  static const String userDataNotFound =
      'No user data found in database. Please contact support.'; // Critical error for AuthWrapper.
  static const String emailInUseError =
      'This email is already in use by another account.';
  static const String weakPasswordError = 'The password provided is too weak.';
  // How it's helpful: Provides instructions to the developer/admin on fixing a common Firestore error.
  static const String firestoreIndexError =
      'Error loading data. If this is your first time, Firestore may need an index. Please check the browser console (F12 or Ctrl+Shift+I) for a URL link to create the index.';
  static const String googleSignInFailed =
      'Google Sign-In failed. Please try again.';

  // --- Dashboard Titles ---
  // What it is doing: Titles for the main navigation bars, used for role-based access differentiation.
  static const String studentDashboardTitle = 'Student Dashboard';
  static const String teacherDashboardTitle = 'Teacher Dashboard';
  static const String adminDashboardTitle = 'Admin Dashboard';
  static const String superAdminDashboardTitle = 'Super Admin Dashboard';

  // --- Welcome Messages ---
  // What it is doing: Static welcome phrases used on dashboards.
  static const String welcomeStudent = 'Welcome, Student!';
  static const String welcomeTeacher = 'Welcome, Teacher!';
  static const String welcomeAdmin = 'Welcome, Admin!';
  static const String welcomeSuperAdmin = 'Welcome, Super Admin!';

  // --- Status Messages ---
  // What it is doing: Messages for the pending approval screen (used for new Teachers).
  static const String approvalPending = 'Your account is pending approval.';
  static const String approvalPendingSubtitle =
      'Your account has been registered but is awaiting approval from an administrator.';

  // --- Admin / Approval ---
  // What it is doing: Strings related to user management, approval queues, and account status toggling.
  static const String approvalListTitle = 'Pending Teacher Approvals';
  static const String noPendingApprovals =
      'There are no pending approvals at this time.';
  static const String approveButton = 'Approve';
  static const String rejectButton = 'Reject';
  static const String approveConfirm =
      'Are you sure you want to approve this user?';
  static const String rejectConfirm =
      'Are you sure you want to reject this user?';
  static const String userApproved = 'User Approved Successfully';
  static const String userRejected = 'User Rejected Successfully';
  static const String allUsersTitle = 'All Users';
  static const String noUsersFound = 'No users found in the system.';
  static const String deactivateUserButton = 'Deactivate';
  static const String reactivateUserButton = 'Reactivate';
  static const String deactivateConfirm =
      'Are you sure you want to deactivate this user?';
  static const String reactivateConfirm =
      'Are you sure you want to reactivate this user?';
  static const String userDeactivated = 'User Deactivated';
  static const String userReactivated = 'User Reactivated';
  static const String statusActive = 'Active';
  static const String statusInactive = 'Inactive';
  static const String editUserRoleTitle = 'Edit User Role';
  static const String saveChangesButton = 'Save Changes';
  static const String roleUpdatedSuccess = 'User role updated successfully';
  static const String manageUserButton = 'Manage User';
  static const String manageUsersTitle = 'Manage Users';
  static const String myContentTitle = 'My Content';
  static const String noManagedUsers = 'No teachers or students found.';

  // --- Teacher Dashboard ---
  // What it is doing: Strings for creating and managing top-level Subjects (courses).
  static const String createSubjectTitle = 'Create New Subject';
  static const String subjectNameLabel =
      'Subject Name (e.g., General Knowledge)';
  static const String subjectDescLabel = 'Subject Description (Optional)';
  static const String createSubjectButton = 'Create Subject';
  static const String subjectCreatedSuccess = 'Subject Created Successfully';
  static const String mySubjectsTitle = 'My Subjects';
  static const String noSubjectsFound =
      'You have not created any subjects yet. Click the button above to get started.';
  static const String subjectStatusLabel = 'Status:';
  static const String subjectStatusDraft = 'Draft';
  static const String subjectStatusPublished = 'Published';
  static const String publishButton = 'Publish';
  static const String unpublishButton = 'Unpublish';
  static const String subjectStatusUpdated = 'Subject status updated!';
  static const String publishSubject = 'Publish Subject';
  static const String publishQuiz = 'Publish Quiz';
  static const String subjectPublished = 'Subject Published';
  static const String subjectUnpublished = 'Subject Unpublished';
  static const String quizPublished = 'Quiz Published';
  static const String quizUnpublished = 'Quiz Unpublished';
  static const String statusLabel = 'Status:';
  static const String statusDraft = 'Draft';
  static const String statusPublished = 'Published';

  // --- Quiz Management ---
  // What it is doing: Strings for managing Quizzes within a Subject.
  static const String manageQuizzesTitle = 'Manage Quizzes';
  static const String createQuizTitle = 'Create New Quiz';
  static const String quizTitleLabel = 'Quiz Title (e.g., GK Set 1)';
  static const String quizDurationLabel = 'Duration (in minutes)';
  static const String createQuizButton = 'Create Quiz';
  static const String quizCreatedSuccess = 'Quiz Created Successfully';
  static const String myQuizzesTitle = 'My Quizzes';
  static const String noQuizzesFound =
      'You have not created any quizzes for this subject yet.';
  static const String totalQuestionsLabel = 'Total Questions';
  static const String minutesLabel = 'min';
  static const String addQuestionsButton = 'Add Questions';

  // --- Quiz Start Screen ---
  // What it is doing: Instructions and labels displayed before a student begins a quiz.
  static const String quizInstructions = 'Quiz Instructions';
  static const String marksPerQuestionLabel = 'Marks Per Question';
  static const String startQuizButton = 'Start Quiz';

  // --- Question Management ---
  // What it is doing: Strings for creating individual questions and options.
  static const String manageQuestionsTitle = 'Manage Questions';
  static const String createQuestionTitle = 'Add New Question';
  static const String questionLabel = 'Question Text';
  static const String option1Label = 'Option 1';
  static const String option2Label = 'Option 2';
  static const String option3Label = 'Option 3';
  static const String option4Label = 'Option 4';
  static const String correctAnswerLabel = 'Correct Answer';
  static const String addQuestionButton = 'Add Question';
  static const String questionAddedSuccess = 'Question Added Successfully';
  static const String allQuestionsTitle = 'All Questions';
  static const String noQuestionsFound =
      'You have not added any questions to this quiz yet.';
  static const String questionMissing = 'Question text cannot be empty.';
  static const String optionsMissing = 'All four options must be filled.';

  // --- Student Flow ---
  // What it is doing: Strings for the student navigation and subject browsing experience.
  static const String studentHomeTitle = 'Available Subjects';
  static const String studentWelcome = 'Welcome,';
  static const String noSubjectsAvailable =
      'There are no subjects available to take a quiz on at this time.';
  static const String quizzesForSubjectTitle = 'Available Quizzes for';
  static const String noQuizzesAvailable =
      'There are no quizzes available for this subject yet.';
  static const String quizRulesTitle = 'Quiz Rules';
  // How it is working: Uses placeholders (%d) that are replaced with the actual number of questions/minutes at runtime.
  static const String quizRulesDetails =
      'This quiz contains %d questions and must be completed in %d minutes.'; // %d are placeholders

  // --- Student Flow (Quiz Attempt) ---
  // What it is doing: Labels for the navigation and action buttons during a live quiz attempt.
  static const String previousButton = 'Previous';
  static const String nextButton = 'Next';
  static const String submitButton = 'Submit';
  static const String submitQuizTitle = 'Submit Quiz?';
  static const String submitQuizMessage =
      'Are you sure you want to submit your quiz?';
  static const String cancelButton = 'Cancel';

  // --- Quiz Result Screen ---
  // What it is doing: Labels and titles for the final result report/certificate.
  static const String resultsTitle = 'Results';
  static const String finalScore = 'Final Score';
  static const String scoreBreakdown = 'Score Breakdown';
  static const String totalQuestions = 'Total Questions';
  static const String correctAnswers = 'Correct Answers';
  static const String incorrectAnswers = 'Incorrect Answers';
  static const String unansweredQuestions = 'Unanswered';
  static const String reviewYourAnswers = 'Review Your Answers';
  static const String backToDashboardButton = 'Back to Dashboard';
  static const String congratulations = 'Congratulations!';
  static const String betterLuckNextTime = 'Try Again!';

  // --- Buttons ---
  // What it is doing: Generic button labels, centralized for consistency.
  static const String logoutButton = 'Logout';
}

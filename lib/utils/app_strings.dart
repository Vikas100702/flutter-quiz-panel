// lib/utils/app_strings.dart

class AppStrings {
  // --- Login Screen ---
  static const String loginTitle = 'Admin & User Login';
  static const String emailLabel = 'Email';
  static const String passwordLabel = 'Password';
  static const String loginButton = 'Login';
  static const String forgotPassword = 'Forgot Password?';
  static const String noAccount = "Don't have an account?";
  static const String registerNow = 'Register Now';

  // --- Register Screen ---
  static const String registerTitle = 'Create Account';
  static const String nameLabel = 'Full Name';
  static const String iAmA = 'I am a...';
  static const String student = 'Student';
  static const String teacher = 'Teacher';
  static const String registerButton = 'Register';
  static const String passwordMinLength = 'Password must be at least 6 characters.';
  static const String haveAccount = 'Already have an account?';
  static const String loginNow = 'Login Now';

  // --- Error Messages ---
  static const String genericError = 'An unknown error occurred. Please try again.';
  static const String networkError = 'Network error. Please check your internet connection.';
  static const String userNotFound = 'No user found for that email.';
  static const String wrongPassword = 'Wrong password provided for that user.';
  static const String noInternet = 'No internet connection. Please check your network settings.';
  static const String userDataNotFound = 'No user data found in database. Please contact support.';
  static const String emailInUseError = 'This email is already in use by another account.';
  static const String weakPasswordError = 'The password provided is too weak.';

  // --- Dashboard Titles ---
  static const String studentDashboardTitle = 'Student Dashboard';
  static const String teacherDashboardTitle = 'Teacher Dashboard';
  static const String adminDashboardTitle = 'Admin Dashboard';
  static const String superAdminDashboardTitle = 'Super Admin Dashboard';

  // --- Welcome Messages ---
  static const String welcomeStudent = 'Welcome, Student!';
  static const String welcomeTeacher = 'Welcome, Teacher!';
  static const String welcomeAdmin = 'Welcome, Admin!';
  static const String welcomeSuperAdmin = 'Welcome, Super Admin!';

  // --- Status Messages ---
  static const String approvalPending = 'Your account is pending approval.';
  static const String approvalPendingSubtitle = 'Your account has been registered but is awaiting approval from an administrator.';

  // --- Admin / Approval ---
  static const String approvalListTitle = 'Pending Teacher Approvals';
  static const String noPendingApprovals = 'There are no pending approvals at this time.';
  static const String approveButton = 'Approve';
  static const String rejectButton = 'Reject';
  static const String approveConfirm = 'Are you sure you want to approve this user?';
  static const String rejectConfirm = 'Are you sure you want to reject this user?';
  static const String userApproved = 'User Approved Successfully';
  static const String userRejected = 'User Rejected Successfully';

  // --- Teacher Dashboard (NEW SECTION) ---
  static const String createSubjectTitle = 'Create New Subject';
  static const String subjectNameLabel = 'Subject Name (e.g., General Knowledge)';
  static const String subjectDescLabel = 'Subject Description (Optional)';
  static const String createSubjectButton = 'Create Subject';
  static const String subjectCreatedSuccess = 'Subject Created Successfully';
  static const String mySubjectsTitle = 'My Subjects';
  static const String noSubjectsFound = 'You have not created any subjects yet. Click the button above to get started.';

  // --- Quiz Management ---
  static const String manageQuizzesTitle = 'Manage Quizzes';
  static const String createQuizTitle = 'Create New Quiz';
  static const String quizTitleLabel = 'Quiz Title (e.g., GK Set 1)';
  static const String quizDurationLabel = 'Duration (in minutes)';
  static const String createQuizButton = 'Create Quiz';
  static const String quizCreatedSuccess = 'Quiz Created Successfully';
  static const String myQuizzesTitle = 'My Quizzes';
  static const String noQuizzesFound = 'You have not created any quizzes for this subject yet.';
  static const String totalQuestionsLabel = 'Total Questions';
  static const String minutesLabel = 'min';
  static const String addQuestionsButton = 'Add Questions';

  // --- Question Management ---
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
  static const String noQuestionsFound = 'You have not added any questions to this quiz yet.';
  static const String questionMissing = 'Question text cannot be empty.';
  static const String optionsMissing = 'All four options must be filled.';


  // --- Buttons ---
  static const String logoutButton = 'Logout';
}
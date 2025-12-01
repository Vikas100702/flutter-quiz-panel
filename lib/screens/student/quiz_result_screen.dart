// lib/screens/student/quiz_result_screen.dart
//
// Why we used this file:
// This screen displays the final outcome of a student's quiz attempt.
// It is the definitive report card, showing the score, performance metrics,
// and providing utility actions like downloading the result or sharing it.
//
// How it's helpful:
// It provides immediate feedback to the student (passed/failed, score, breakdown)
// and integrates services for permanent record keeping (PDF download) and social engagement (sharing).
import 'package:flutter/foundation.dart'; // kIsWeb for platform-specific rendering
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for Clipboard
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/models/quiz_attempt_state.dart';
import 'package:quiz_panel/models/quiz_model.dart';
import 'package:quiz_panel/models/user_model.dart';
import 'package:quiz_panel/providers/quiz_attempt_provider.dart';
import 'package:quiz_panel/providers/user_data_provider.dart';
import 'package:quiz_panel/services/result_pdf_service.dart';
import 'package:quiz_panel/utils/app_routes.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/widgets/buttons/app_button.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class QuizResultScreen extends ConsumerStatefulWidget {
  // What it is doing: Requires the completed QuizModel to fetch the corresponding result state.
  final QuizModel quiz;

  const QuizResultScreen({super.key, required this.quiz});

  @override
  ConsumerState<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends ConsumerState<QuizResultScreen> {
  // What it is doing: Tracks if the automatic result PDF download has already occurred.
  bool _hasDownloaded = false;
  // What it is doing: Controls the loading spinner on the Native Share button.
  bool _isSharing = false;

  @override
  Widget build(BuildContext context) {
    // How it is working: Watches the unique quiz attempt state for this quiz ID.
    // This state contains the final score, correct answers count, etc.
    final resultState = ref.watch(quizAttemptProvider(widget.quiz));
    // How it is working: Watches the user profile data needed for PDF generation and personalized messages.
    final userAsync = ref.watch(userDataProvider);

    // Safety check: If the user navigates here before the quiz status is 'finished',
    // redirect them to prevent viewing incomplete or empty result data.
    if (resultState.status != QuizStatus.finished) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Quiz result not available.'),
              const SizedBox(height: 16),
              AppButton(
                text: 'Go to Dashboard',
                onPressed: () => context.go(AppRoutePaths.studentDashboard),
                type: AppButtonType.primary,
              ),
            ],
          ),
        ),
      );
    }

    // What it is doing: Calculates the overall score and pass/fail status.
    final maxScore =
        resultState.quiz.totalQuestions * resultState.quiz.marksPerQuestion;
    final percentage = (resultState.score / maxScore) * 100;
    // How it's helpful: Defines the passing threshold (40%) to determine the congratulatory/retry message.
    final bool passed = percentage >= 40;

    // Auto download logic: Triggers the PDF download only once, immediately after the screen loads and data is available.
    if (!_hasDownloaded && userAsync.value != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _triggerAutoDownload(
          resultState,
          userAsync.value!,
          maxScore.toDouble(),
          percentage,
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        // Prevents the system back button from appearing since the quiz is over.
        automaticallyImplyLeading: false,
        title: Text('${widget.quiz.title}: ${AppStrings.resultsTitle}'),
        actions: [
          // Button to return directly to the main student dashboard.
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: AppStrings.backToDashboardButton,
            onPressed: () => context.go(AppRoutePaths.studentDashboard),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          // Constrains the content width for optimal reading experience.
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Status Text (Pass/Fail Message)
                Text(
                  passed
                      ? AppStrings.congratulations
                      : AppStrings.betterLuckNextTime,
                  style: AppTextStyles.displayMedium.copyWith(
                    color: passed ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                // Download confirmation message, visible after the auto-download completes.
                if (_hasDownloaded)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Result downloaded successfully!",
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 24),

                // Score Card (Prominent display of results)
                Card(
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Text(
                          AppStrings.finalScore,
                          style: AppTextStyles.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        // Displays the calculated score and maximum possible score.
                        Text(
                          '${resultState.score} / $maxScore',
                          style: AppTextStyles.displayLarge.copyWith(
                            color: passed ? AppColors.success : AppColors.error,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        // Displays the percentage score.
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: AppTextStyles.displaySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Metrics Breakdown
                Text(
                  AppStrings.scoreBreakdown,
                  style: AppTextStyles.displaySmall,
                ),
                const Divider(height: 20),
                Center(
                  // How it's helpful: Uses a Wrap to arrange the metric cards. This ensures
                  // the cards flow onto the next line on smaller screens while remaining centered.
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      // Metric Card 1: Total Questions
                      _buildMetricCard(
                        title: AppStrings.totalQuestions,
                        value: resultState.questions.length,
                        color: AppColors.textSecondary,
                      ),
                      // Metric Card 2: Correct Answers (Success color)
                      _buildMetricCard(
                        title: AppStrings.correctAnswers,
                        value: resultState.totalCorrect,
                        color: AppColors.success,
                      ),
                      // Metric Card 3: Incorrect Answers (Error color)
                      _buildMetricCard(
                        title: AppStrings.incorrectAnswers,
                        value: resultState.totalIncorrect,
                        color: AppColors.error,
                      ),
                      // Metric Card 4: Unanswered Questions (Warning color)
                      _buildMetricCard(
                        title: AppStrings.unansweredQuestions,
                        value: resultState.totalUnanswered,
                        color: AppColors.warning,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // --- 1. Download Button ---
                AppButton(
                  text: 'Download Result Again',
                  icon: Icons.download_rounded,
                  type: AppButtonType.outline,
                  onPressed: () {
                    if (userAsync.value != null) {
                      // Allows the user to manually re-download the certificate.
                      _triggerAutoDownload(
                        resultState,
                        userAsync.value!,
                        maxScore.toDouble(),
                        percentage,
                        isRetry: true,
                      );
                    }
                  },
                ),
                const SizedBox(height: 24),

                // --- 2. Social Share (WEB ONLY) ---
                // kIsWeb is a Flutter constant that is true when running on a web browser.
                if (kIsWeb) ...[
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          "Share directly via",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textTertiary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Displays WhatsApp, LinkedIn, and X icons using font_awesome_flutter.
                  _buildSocialShareRow(
                    resultState,
                    maxScore.toDouble(),
                    percentage,
                  ),
                  const SizedBox(height: 24),
                ],

                // --- 3. Native Share (Visible on both Mobile/Web) ---
                AppButton(
                  text: 'Challenge Friends & Share',
                  icon: Icons.share_rounded,
                  type: AppButtonType.primary,
                  isLoading: _isSharing,
                  onPressed: _isSharing
                      ? null
                      : () => _shareNative(
                          resultState,
                          maxScore.toDouble(),
                          percentage,
                          userAsync.value,
                        ),
                ),

                const SizedBox(height: 24),

                // --- 4. YOUTUBE LEARNING BUTTON ---
                AppButton(
                  text: 'Watch Related Videos',
                  icon: Icons.video_library_rounded,
                  type:
                      AppButtonType.secondary, // Uses the secondary theme color
                  onPressed: () {
                    // How it's helpful: Navigates to the learning screen, auto-searching for content
                    // related to the quiz title, making the learning path seamless.
                    context.pushNamed(
                      AppRouteNames.youtubeLearning,
                      extra: '${widget.quiz.title} tutorial',
                    );
                  },
                ),
                // const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helpers ---

  // What it is doing: Builds an individual card to display one performance metric (e.g., Correct Answers).
  Widget _buildMetricCard({
    required String title,
    required int value,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        // Fix: Changed withValues(alpha: 0.5) to withValues(alpha: )(0.5) for correct Flutter syntax.
        side: BorderSide(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 150, // Fixed width for consistent grid layout
        child: Column(
          children: [
            Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: AppTextStyles.displaySmall.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // What it is doing: Handles the native sharing process using the SharePlus package.
  Future<void> _shareNative(
    QuizAttemptState resultState,
    double maxScore,
    double percentage,
    UserModel? user,
  ) async {
    final box = context.findRenderObject() as RenderBox?;
    setState(() {
      _isSharing = true;
    });

    try {
      final String shareText =
          "I scored ${resultState.score.toInt()}/${maxScore.toInt()} on ${widget.quiz.title}! Can you beat me? #ProOlympiad";

      // How it is working: Generates the PDF file in memory (or temporary storage on mobile).
      final XFile pdfFile = await ResultPdfService.generatePdfXFile(
        resultState: resultState,
        user: user,
        totalScore: resultState.score.toDouble(),
        maxScore: maxScore,
        percentage: percentage,
      );

      if (!mounted) return;

      // How it's helpful: Automatically copies the social caption to the clipboard,
      // so the user can easily paste it when the share sheet opens.
      await Clipboard.setData(ClipboardData(text: shareText));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Caption copied! Paste it in WhatsApp when sharing.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.primary,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // How it is working: Opens the native share sheet with the generated PDF file attached.
      await SharePlus.instance.share(
        ShareParams(
          files: [pdfFile], // Attaches the PDF result document.
          text: shareText,
          subject: 'My Quiz Result',
          sharePositionOrigin: box != null
              ? box.localToGlobal(Offset.zero) & box.size
              : null,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  // What it is doing: Triggers the PDF creation and download function on first load or manual retry.
  Future<void> _triggerAutoDownload(
    QuizAttemptState result,
    UserModel user,
    double maxScore,
    double percentage, {
    bool isRetry = false,
  }) async {
    // Prevents redundant downloads unless explicitly requested via the "Download Again" button.
    if (_hasDownloaded && !isRetry) return;
    try {
      // Calls the service responsible for generating and saving the file to the local device/browser.
      await ResultPdfService.generateAndDownloadResult(
        resultState: result,
        user: user,
        totalScore: result.score.toDouble(),
        maxScore: maxScore,
        percentage: percentage,
      );
      if (mounted) {
        setState(() {
          _hasDownloaded = true;
        });
        if (!isRetry) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Certificate Downloaded!')),
          );
        }
      }
    } catch (e) {
      if (mounted && isRetry) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Download failed: $e')));
      }
    }
  }

  // What it is doing: Builds the row of social icons (WhatsApp, LinkedIn, X) for direct web sharing.
  Widget _buildSocialShareRow(
    QuizAttemptState state,
    double maxScore,
    double percentage,
  ) {
    // Constructs the share text used in the URL parameters for web sharing.
    final String shareText =
        "I scored ${state.score.toInt()}/${maxScore.toInt()} on ${widget.quiz.title}! Can you beat me? #ProOlympiad";

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialIconBtn(
          icon: FontAwesomeIcons.whatsapp,
          color: const Color(0xFF25D366),
          // How it is working: Opens the external WhatsApp web share URL.
          onTap: () => launchUrl(
            Uri.parse('https://wa.me/?text=${Uri.encodeComponent(shareText)}'),
          ),
        ),
        const SizedBox(width: 20),
        _buildSocialIconBtn(
          icon: FontAwesomeIcons.linkedinIn,
          color: const Color(0xFF0077B5),
          // How it is working: Opens the external LinkedIn share URL.
          onTap: () => launchUrl(
            Uri.parse(
              'https://www.linkedin.com/feed/?shareActive=true&text=${Uri.encodeComponent(shareText)}',
            ),
          ),
        ),
        const SizedBox(width: 20),
        _buildSocialIconBtn(
          icon: FontAwesomeIcons.xTwitter,
          color: const Color(0xFF000000),
          // How it is working: Opens the external X/Twitter post creation URL.
          onTap: () => launchUrl(
            Uri.parse(
              'https://twitter.com/intent/tweet?text=${Uri.encodeComponent(shareText)}',
            ),
          ),
        ),
      ],
    );
  }

  // What it is doing: Builds the styled, clickable button for a social media icon.
  Widget _buildSocialIconBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: FaIcon(icon, color: color, size: 24),
      ),
    );
  }
}

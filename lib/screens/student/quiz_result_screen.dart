// lib/screens/student/quiz_result_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/models/quiz_attempt_state.dart';
import 'package:quiz_panel/models/quiz_model.dart';
import 'package:quiz_panel/providers/quiz_attempt_provider.dart';
import 'package:quiz_panel/providers/user_data_provider.dart';
import 'package:quiz_panel/utils/app_routes.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/widgets/buttons/app_button.dart';
import 'package:quiz_panel/services/result_pdf_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class QuizResultScreen extends ConsumerStatefulWidget {
  final QuizModel quiz;

  const QuizResultScreen({super.key, required this.quiz});

  @override
  ConsumerState<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends ConsumerState<QuizResultScreen> {
  bool _hasDownloaded = false;

  @override
  Widget build(BuildContext context) {
    final resultState = ref.watch(quizAttemptProvider(widget.quiz));
    final userAsync = ref.watch(userDataProvider);

    if (resultState.status != QuizStatus.finished) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Quiz abhi khatam nahi hua hai ya koi error hai.'),
              TextButton(
                onPressed: () => context.go(AppRoutePaths.studentDashboard),
                child: const Text('Go to Dashboard'),
              ),
            ],
          ),
        ),
      );
    }

    final maxScore =
        resultState.quiz.totalQuestions * resultState.quiz.marksPerQuestion;
    final percentage = (resultState.score / maxScore) * 100;
    final bool passed = percentage >= 40;

    // Auto download logic
    if (!_hasDownloaded && userAsync.value != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _triggerAutoDownload(
            resultState, userAsync.value!, maxScore.toDouble(), percentage);
      });
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('${widget.quiz.title}: ${AppStrings.resultsTitle}'),
        actions: [
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
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Status Text
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

                // Download Feedback
                if (_hasDownloaded)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Result downloaded successfully!",
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.primary),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 24),

                // Score Card
                Card(
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Text(AppStrings.finalScore,
                            style: AppTextStyles.titleLarge),
                        const SizedBox(height: 12),
                        Text(
                          '${resultState.score} / $maxScore',
                          style: AppTextStyles.displayLarge.copyWith(
                            color: passed ? AppColors.success : AppColors.error,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text('${percentage.toStringAsFixed(1)}%',
                            style: AppTextStyles.displaySmall),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Metrics
                Text(AppStrings.scoreBreakdown,
                    style: AppTextStyles.displaySmall),
                const Divider(height: 20),
                Center(
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildMetricCard(
                          title: AppStrings.totalQuestions,
                          value: resultState.questions.length,
                          color: AppColors.textSecondary),
                      _buildMetricCard(
                          title: AppStrings.correctAnswers,
                          value: resultState.totalCorrect,
                          color: AppColors.success),
                      _buildMetricCard(
                          title: AppStrings.incorrectAnswers,
                          value: resultState.totalIncorrect,
                          color: AppColors.error),
                      _buildMetricCard(
                          title: AppStrings.unansweredQuestions,
                          value: resultState.totalUnanswered,
                          color: AppColors.warning),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // --- Action Buttons ---

                // 1. Download Button
                AppButton(
                  text: 'Download Result Again',
                  icon: Icons.download_rounded,
                  type: AppButtonType.outline,
                  onPressed: () {
                    if (userAsync.value != null) {
                      _triggerAutoDownload(resultState, userAsync.value!,
                          maxScore.toDouble(), percentage,
                          isRetry: true);
                    }
                  },
                ),
                const SizedBox(height: 24),

                // --- Separator for Social Share ---
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

                // --- Social Share Icons ---
                _buildSocialShareRow(
                    resultState, maxScore.toDouble(), percentage),
                const SizedBox(height: 24),

                // --- More Options (Native Share) ---
                // Made this an outline button so it's cleaner
                AppButton(
                  text: 'More Options...',
                  icon: Icons.share_rounded,
                  type: AppButtonType.text, // Clean text button
                  onPressed: () =>
                      _shareNative(resultState, maxScore.toDouble(), percentage),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Social Share Row Widget ---
  Widget _buildSocialShareRow(
      QuizAttemptState state, double maxScore, double percentage) {
    final String shareText = _getShareText(state, maxScore, percentage);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // WhatsApp
        _buildSocialIconBtn(
          icon: FontAwesomeIcons.whatsapp,
          color: const Color(0xFF25D366),
          onTap: () => _launchUrl(
              'https://wa.me/?text=${Uri.encodeComponent(shareText)}'),
          tooltip: 'Share on WhatsApp',
        ),
        const SizedBox(width: 20),

        // LinkedIn
        _buildSocialIconBtn(
          icon: FontAwesomeIcons.linkedinIn,
          color: const Color(0xFF0077B5),
          onTap: () => _launchUrl(
              'https://www.linkedin.com/feed/?shareActive=true&text=${Uri.encodeComponent(shareText)}'),
          tooltip: 'Share on LinkedIn',
        ),
        const SizedBox(width: 20),

        // Twitter (X)
        _buildSocialIconBtn(
          icon: FontAwesomeIcons.xTwitter,
          color: const Color(0xFF000000),
          onTap: () => _launchUrl(
              'https://twitter.com/intent/tweet?text=${Uri.encodeComponent(shareText)}'),
          tooltip: 'Share on X',
        ),
        const SizedBox(width: 20),

        // Gmail / Email
        _buildSocialIconBtn(
          icon: Icons.email_rounded,
          color: const Color(0xFFEA4335),
          onTap: () => _launchUrl(
              'mailto:?subject=${Uri.encodeComponent("My Quiz Result")}&body=${Uri.encodeComponent(shareText)}'),
          tooltip: 'Share via Email',
          isMaterial: true, // Email is a standard material icon
        ),
      ],
    );
  }

  Widget _buildSocialIconBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String tooltip,
    bool isMaterial = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: const EdgeInsets.all(16), // Slightly larger padding
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.1),
            border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
          ),
          // Use FaIcon for FontAwesome, Icon for Material
          child: isMaterial
              ? Icon(icon, color: color, size: 28)
              : FaIcon(icon, color: color, size: 28),
        ),
      ),
    );
  }

  // --- Helper: Generate Share Text ---
  String _getShareText(
      QuizAttemptState resultState, double maxScore, double percentage) {
    return '🏆 Quiz Result: ${widget.quiz.title}\n\n'
        'I just scored ${resultState.score} out of ${maxScore.toInt()} (${percentage.toStringAsFixed(1)}%) on Pro Olympiad!\n\n'
        'Can you beat my score? 🚀 #ProOlympiad #QuizResult';
  }

  // --- Helper: Native Share (Generic) ---
  Future<void> _shareNative(
      QuizAttemptState resultState, double maxScore, double percentage) async {
    await Share.share(
      _getShareText(resultState, maxScore, percentage),
      subject: 'My Quiz Score - ${widget.quiz.title}',
    );
  }

  // --- Helper: Launch URL (Browser/App) ---
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Could not launch application: $e'),
              backgroundColor: AppColors.error),
        );
      }
    }
  }

  // --- Helper: PDF Download ---
  Future<void> _triggerAutoDownload(
      QuizAttemptState result, var user, double maxScore, double percentage,
      {bool isRetry = false}) async {
    if (_hasDownloaded && !isRetry) return;

    try {
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Result Certificate Downloaded!'),
              backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      debugPrint('PDF Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to download result: $e'),
              backgroundColor: AppColors.error),
        );
      }
    }
  }

  Widget _buildMetricCard(
      {required String title, required int value, required Color color}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.5), width: 1)),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 150,
        child: Column(
          children: [
            Text(title,
                style: AppTextStyles.titleMedium.copyWith(fontSize: 14),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(value.toString(),
                style: AppTextStyles.displaySmall
                    .copyWith(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
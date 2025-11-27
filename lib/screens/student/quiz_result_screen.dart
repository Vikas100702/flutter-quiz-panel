// lib/screens/student/quiz_result_screen.dart

import 'package:flutter/foundation.dart'; // kIsWeb
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
  final QuizModel quiz;

  const QuizResultScreen({super.key, required this.quiz});

  @override
  ConsumerState<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends ConsumerState<QuizResultScreen> {
  bool _hasDownloaded = false;
  bool _isSharing = false;

  @override
  Widget build(BuildContext context) {
    final resultState = ref.watch(quizAttemptProvider(widget.quiz));
    final userAsync = ref.watch(userDataProvider);

    // Safety check: If quiz isn't finished, redirect
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

    final maxScore =
        resultState.quiz.totalQuestions * resultState.quiz.marksPerQuestion;
    final percentage = (resultState.score / maxScore) * 100;
    final bool passed = percentage >= 40;

    // Auto download logic (Web & Mobile)
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

                // Score Card
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
                        Text(
                          '${resultState.score} / $maxScore',
                          style: AppTextStyles.displayLarge.copyWith(
                            color: passed ? AppColors.success : AppColors.error,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: AppTextStyles.displaySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Metrics
                Text(
                  AppStrings.scoreBreakdown,
                  style: AppTextStyles.displaySmall,
                ),
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
                        color: AppColors.textSecondary,
                      ),
                      _buildMetricCard(
                        title: AppStrings.correctAnswers,
                        value: resultState.totalCorrect,
                        color: AppColors.success,
                      ),
                      _buildMetricCard(
                        title: AppStrings.incorrectAnswers,
                        value: resultState.totalIncorrect,
                        color: AppColors.error,
                      ),
                      _buildMetricCard(
                        title: AppStrings.unansweredQuestions,
                        value: resultState.totalUnanswered,
                        color: AppColors.warning,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // --- 1. Download Button (Visible on both) ---
                AppButton(
                  text: 'Download Result Again',
                  icon: Icons.download_rounded,
                  type: AppButtonType.outline,
                  onPressed: () {
                    if (userAsync.value != null) {
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
                // Only show these direct link icons on Web
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
                  _buildSocialShareRow(
                    resultState,
                    maxScore.toDouble(),
                    percentage,
                  ),
                  const SizedBox(height: 24),
                ],

                // --- 3. Native Share (Visible on both) ---
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

                // --- 4. YOUTUBE LEARNING BUTTON (Always Visible) ---
                // We ensure this is NOT inside the kIsWeb block
                AppButton(
                  text: 'Watch Related Videos',
                  icon: Icons.video_library_rounded,
                  type: AppButtonType.secondary, // Uses the secondary theme color
                  onPressed: () {
                    // Navigate to the YouTube screen with a search query
                    context.pushNamed(
                      AppRouteNames.youtubeLearning,
                      extra: '${widget.quiz.title} tutorial',
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helpers ---

  Widget _buildMetricCard({
    required String title,
    required int value,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 150,
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

      final XFile pdfFile = await ResultPdfService.generatePdfXFile(
        resultState: resultState,
        user: user,
        totalScore: resultState.score.toDouble(),
        maxScore: maxScore,
        percentage: percentage,
      );

      if (!mounted) return;

      // Copy text to clipboard for convenience
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

      await SharePlus.instance.share(
        ShareParams(
          files: [pdfFile],
          text: shareText,
          subject: 'My Quiz Result',
          sharePositionOrigin: box != null
              ? box.localToGlobal(Offset.zero) & box.size
              : null,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  Future<void> _triggerAutoDownload(
      QuizAttemptState result,
      UserModel user,
      double maxScore,
      double percentage, {
        bool isRetry = false,
      }) async {
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
        if (!isRetry) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Certificate Downloaded!')));
        }
      }
    } catch (e) {
      if (mounted && isRetry) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Download failed: $e')));
      }
    }
  }

  Widget _buildSocialShareRow(
      QuizAttemptState state, double maxScore, double percentage) {

    // Construct the share text for web sharing links
    final String shareText =
        "I scored ${state.score.toInt()}/${maxScore.toInt()} on ${widget.quiz.title}! Can you beat me? #ProOlympiad";

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialIconBtn(
          icon: FontAwesomeIcons.whatsapp,
          color: const Color(0xFF25D366),
          onTap: () => launchUrl(Uri.parse('https://wa.me/?text=${Uri.encodeComponent(shareText)}')),
        ),
        const SizedBox(width: 20),
        _buildSocialIconBtn(
          icon: FontAwesomeIcons.linkedinIn,
          color: const Color(0xFF0077B5),
          onTap: () => launchUrl(Uri.parse('https://www.linkedin.com/feed/?shareActive=true&text=${Uri.encodeComponent(shareText)}')),
        ),
        const SizedBox(width: 20),
        _buildSocialIconBtn(
          icon: FontAwesomeIcons.xTwitter,
          color: const Color(0xFF000000),
          onTap: () => launchUrl(Uri.parse('https://twitter.com/intent/tweet?text=${Uri.encodeComponent(shareText)}')),
        ),
      ],
    );
  }

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
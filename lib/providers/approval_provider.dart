// lib/screens/auth/approval_pending_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_panel/providers/auth_provider.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/widgets/buttons/app_button.dart';
import 'package:quiz_panel/widgets/layout/responsive_layout.dart';

/// **Why we used this screen (ApprovalPendingScreen):**
/// This screen acts as a "Waiting Room". When a new Teacher registers, they cannot
/// immediately access the dashboard. They must wait for an Admin to approve them.
///
/// **What it does:**
/// 1. It informs the user that their registration was successful.
/// 2. It shows a visual "timeline" of where they are in the process.
/// 3. It prevents them from navigating to protected screens.
/// 4. It provides a way to Log Out (in case they want to sign in with a different account).
class ApprovalPendingScreen extends ConsumerStatefulWidget {
  const ApprovalPendingScreen({super.key});

  @override
  ConsumerState<ApprovalPendingScreen> createState() =>
      _ApprovalPendingScreenState();
}

class _ApprovalPendingScreenState extends ConsumerState<ApprovalPendingScreen>
    with SingleTickerProviderStateMixin {
  // **Animation Controllers:**
  // These are used to make the screen elements "pop" and fade in smoothly
  // instead of just appearing abruptly.
  late AnimationController _controller;
  late Animation<double> _scaleAnimation; // Makes the icon grow/shrink.
  late Animation<double> _fadeAnimation; // Makes the text fade in.

  // **State Variables:**
  bool _isLoggingOut = false; // Shows a loader on the logout button.
  bool _isCheckingStatus =
      false; // Shows a loader on the "Check Status" button.

  @override
  void initState() {
    super.initState();

    // **Setup Animation:**
    // The animation runs for 1.2 seconds.
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // This creates a "bouncy" effect for the icon.
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    // This makes the content fade in slowly after a short delay.
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Start the animation as soon as the screen opens.
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose(); // Always clean up animations to free memory.
    super.dispose();
  }

  /// **Logic: Sign Out**
  /// If the user is tired of waiting or wants to switch accounts, they can log out.
  /// This clears their session from Firebase Auth.
  Future<void> _handleSignOut() async {
    setState(() {
      _isLoggingOut = true;
    });

    try {
      await ref.read(authRepositoryProvider).signOut();
      // Once signed out, the 'routerProvider' will automatically detect the change
      // and redirect the user back to the Login Screen.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.logoutButton} failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  /// **Logic: Check Status**
  /// In a real app, this would force-fetch the latest user data from Firestore
  /// to see if the Admin has approved the account yet.
  /// Currently, it simulates a check with a delay.
  Future<void> _checkStatus() async {
    setState(() {
      _isCheckingStatus = true;
    });

    // Simulate API call to check status
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isCheckingStatus = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Status checked - still pending approval'),
          backgroundColor: AppColors.info,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Status'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Logout button in the top right corner
          IconButton(
            icon: _isLoggingOut
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.logout_rounded),
            tooltip: AppStrings.logoutButton,
            onPressed: _isLoggingOut ? null : _handleSignOut,
          ),
        ],
      ),
      // We use ResponsiveAuthLayout to ensure the content is centered
      // and looks good on both Mobile and Web.
      body: ResponsiveAuthLayout(
        showBackground: true,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Apply the Fade and Scale animations defined in initState
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. The big animated icon
              _buildStatusIcon(),
              const SizedBox(height: 32),

              // 2. The "Pending" text message
              _buildStatusMessage(),
              const SizedBox(height: 24),

              // 3. The visual timeline (Registered -> Pending -> Approved)
              _buildProgressIndicator(),
              const SizedBox(height: 40),

              // 4. Buttons to Check Status or Logout
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  /// **Helper: Status Icon**
  /// Creates a pulsing, circular icon to visually indicate "Waiting".
  Widget _buildStatusIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulsing background layer
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
        ),

        // Main icon container
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.warning,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.warning.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.pending_actions_rounded,
            size: 40,
            color: Colors.white,
          ),
        ),

        // Rotating progress indicator around the icon
        SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.warning),
            strokeWidth: 2,
            backgroundColor: AppColors.warning.withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusMessage() {
    return Column(
      children: [
        Text(
          AppStrings.approvalPending,
          style: AppTextStyles.displaySmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.approvalPendingSubtitle,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textTertiary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'You will be notified once your account is approved by an administrator.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textTertiary,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// **Helper: Visual Progress Bar**
  /// Shows a 3-step process so the user knows exactly where they stand.
  Widget _buildProgressIndicator() {
    return Column(
      children: [
        // Step indicators row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStep(1, 'Registered', true), // Completed
            _buildStepDivider(),
            _buildStep(2, 'Pending', true), // Current Step
            _buildStepDivider(),
            _buildStep(3, 'Approved', false), // Future Step
          ],
        ),
        const SizedBox(height: 24),

        // Estimated wait time badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.schedule_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Typically approved within 24-48 hours',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper to build a single step circle (1, 2, 3)
  Widget _buildStep(int stepNumber, String label, bool isCompleted) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCompleted ? AppColors.primary : AppColors.background,
            shape: BoxShape.circle,
            border: Border.all(
              color: isCompleted ? AppColors.primary : AppColors.outline,
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted
                ? Icon(Icons.check_rounded, size: 18, color: Colors.white)
                : Text(
                    stepNumber.toString(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isCompleted ? AppColors.primary : AppColors.textTertiary,
            fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // Helper to build the line between steps
  Widget _buildStepDivider() {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(bottom: 16),
      color: AppColors.outline,
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        AppButton(
          text: 'Check Status',
          onPressed: _isCheckingStatus || _isLoggingOut ? null : _checkStatus,
          isLoading: _isCheckingStatus,
          type: AppButtonType.outline,
          icon: Icons.refresh_rounded,
        ),
        const SizedBox(height: 12),
        AppButton(
          text: AppStrings.logoutButton,
          onPressed: _isLoggingOut || _isCheckingStatus ? null : _handleSignOut,
          isLoading: _isLoggingOut,
          type: AppButtonType.text,
          icon: Icons.logout_rounded,
        ),
      ],
    );
  }
}

// lib/screens/auth/approval_pending_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_panel/providers/auth_provider.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/widgets/buttons/app_button.dart';
import 'package:quiz_panel/widgets/layout/responsive_layout.dart';
import 'package:quiz_panel/utils/responsive.dart'; // Imports utility for responsive Row/Column layouts.

/// **Why we used this Widget (ApprovalPendingScreen):**
/// This screen acts as a secure "waiting room" for new Teacher accounts.
/// Teacher registrations are marked as 'pending' by default. The router redirects them here,
/// preventing access to the dashboard until an Admin explicitly approves them.
///
/// **How it helps:**
/// 1. **Security:** It enforces the Admin approval workflow.
/// 2. **User Experience:** It clearly communicates the account status to the user and provides necessary options (logout, check status).
class ApprovalPendingScreen extends ConsumerStatefulWidget {
  const ApprovalPendingScreen({super.key});

  @override
  ConsumerState<ApprovalPendingScreen> createState() =>
      _ApprovalPendingScreenState();
}

class _ApprovalPendingScreenState extends ConsumerState<ApprovalPendingScreen>
        // **Why SingleTickerProviderStateMixin?**
        // This mixin is essential for managing the animation controller (`_controller`).
        // It provides the "ticker" that drives the animation timeline.
        with
        SingleTickerProviderStateMixin {
  // **Animation Controllers:**
  late AnimationController _controller; // Manages the animation over time.
  late Animation<double>
  _scaleAnimation; // Controls the icon's size (0.8 -> 1.0).
  late Animation<double>
  _fadeAnimation; // Controls the content's visibility (0.0 -> 1.0).

  // **Screen State:**
  bool _isLoggingOut =
      false; // Controls the loading state of the Logout button.
  bool _isCheckingStatus =
      false; // Controls the loading state of the Check Status button.

  @override
  void initState() {
    super.initState();

    // **Setup Animation:**
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200), // Total animation time.
      vsync: this, // Links the controller to this screen's lifecycle.
    );

    // **Scale Animation:** Creates a bouncy, dynamic entrance effect for the primary icon.
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut, // Gives a pleasant "pop" effect.
      ),
    );

    // **Fade Animation:** Ensures the text and buttons fade in smoothly.
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.3,
          1.0,
          curve: Curves.easeInOut,
        ), // Starts fading in after a slight delay (0.3s).
      ),
    );

    // Start the animation immediately when the screen is built.
    _controller.forward();
  }

  @override
  void dispose() {
    // **Cleanup:** Always dispose controllers to prevent memory leaks.
    _controller.dispose();
    super.dispose();
  }

  /// **Logic: Sign Out Handler**
  /// Allows the user to exit the pending screen and return to login.
  ///
  /// **How it works:**
  /// 1. Sets loading state (`_isLoggingOut = true`).
  /// 2. Calls the `AuthRepository` to perform the Firebase sign out.
  /// 3. The `AppRouterProvider` detects the logged-out state and redirects automatically.
  Future<void> _handleSignOut() async {
    setState(() {
      _isLoggingOut = true;
    });

    try {
      await ref.read(authRepositoryProvider).signOut();
    } catch (e) {
      if (mounted) {
        // Show error if sign out fails for a technical reason (rare).
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

  /// **Logic: Check Status Handler**
  /// Simulates checking the backend for account approval status.
  ///
  /// **How it works:**
  /// In a full production app, this would typically involve:
  /// 1. Reloading the Firebase User (`user.reload()`).
  /// 2. Invalidating the `userDataProvider` to force re-fetch from Firestore.
  /// For this example, we use a simple `Future.delayed` to simulate network latency.
  Future<void> _checkStatus() async {
    setState(() {
      _isCheckingStatus = true;
    });

    // Simulate API call delay (2 seconds).
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isCheckingStatus = false;
      });
      // Give feedback that the check happened.
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
          // Logout button in AppBar.
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
      // **Responsive Layout Wrapper:**
      // This centers the content and constrains its max width for a good desktop/web experience.
      body: ResponsiveAuthLayout(
        showBackground: true,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Apply the defined Scale and Fade animations to the main content block.
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
              // 1. The main status icon with a pulsing effect.
              _buildStatusIcon(),
              const SizedBox(height: 32),

              // 2. Text messages explaining the status.
              _buildStatusMessage(),
              const SizedBox(height: 24),

              // 3. The visual step-by-step progress bar.
              _buildProgressIndicator(),
              const SizedBox(height: 40),

              // 4. Action buttons (Check Status / Logout).
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  /// **Widget: Animated Status Icon**
  /// Creates a stack of containers to provide a visual indicator of a 'pending' state.
  Widget _buildStatusIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulsing background circle (light opacity).
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
        ),

        // Main icon container (Solid color with shadow).
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.warning, // Warning color for 'pending'.
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

        // Rotating Progress Indicator (Pulsing visual effect around the icon).
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

  /// **Widget: Status Message**
  /// Displays the main title and supportive instruction text.
  Widget _buildStatusMessage() {
    return Column(
      children: [
        Text(
          AppStrings.approvalPending, // "Your account is pending approval."
          style: AppTextStyles.displaySmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings
              .approvalPendingSubtitle, // "Your account has been registered but is awaiting..."
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

  /// **Widget: Progress Indicator (Visual Timeline)**
  /// Shows the three steps of the registration process (Registered -> Pending -> Approved).
  Widget _buildProgressIndicator() {
    return Column(
      children: [
        // Row of step circles and dividers.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStep(1, 'Registered', true), // Complete
            _buildStepDivider(),
            _buildStep(2, 'Pending', true), // Current
            _buildStepDivider(),
            _buildStep(3, 'Approved', false), // Future
          ],
        ),
        const SizedBox(height: 24),

        // Estimated Wait Time Badge.
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

  /// **Helper: Build Single Step Circle**
  Widget _buildStep(int stepNumber, String label, bool isCompleted) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            // Use primary color for completed steps.
            color: isCompleted ? AppColors.primary : AppColors.background,
            shape: BoxShape.circle,
            border: Border.all(
              color: isCompleted ? AppColors.primary : AppColors.outline,
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
                : Text(
                    stepNumber.toString(), // Show number if not yet completed.
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

  /// **Helper: Build Divider Line**
  Widget _buildStepDivider() {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(bottom: 16),
      color: AppColors.outline,
    );
  }

  /// **Widget: Action Buttons (Responsive)**
  /// **How it works:**
  /// Uses the `Responsive` utility widget to switch the layout of buttons:
  /// - `mobile`: Stacks buttons vertically in a `Column` (full width, easy tapping).
  /// - `desktop`: Places buttons side-by-side in a `Row` (better use of screen space).
  Widget _buildActionButtons() {
    // Define the individual buttons once.
    final checkStatusButton = AppButton(
      text: 'Check Status',
      onPressed: _isCheckingStatus || _isLoggingOut ? null : _checkStatus,
      isLoading: _isCheckingStatus,
      type: AppButtonType.outline,
      icon: Icons.refresh_rounded,
    );

    final logoutButton = AppButton(
      text: AppStrings.logoutButton,
      onPressed: _isLoggingOut || _isCheckingStatus ? null : _handleSignOut,
      isLoading: _isLoggingOut,
      type: AppButtonType.text,
      icon: Icons.logout_rounded,
    );

    // Apply the responsive layout switch.
    return Responsive(
      // Mobile Layout (Vertical)
      mobile: Column(
        children: [checkStatusButton, const SizedBox(height: 12), logoutButton],
      ),
      // Desktop Layout (Horizontal)
      desktop: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [checkStatusButton, const SizedBox(width: 16), logoutButton],
      ),
    );
  }
}

// lib/widgets/splash/splash_content.dart

/*
/// **Why we used this file (SplashContent):**
/// This widget acts as the **Visual Core** of the Splash Screen.
/// While `SplashScreen` handles the scaffolding, this widget orchestrates the actual layout,
/// branding elements (Logo, Subtitle), and the entrance animations.
///
/// **What it is doing:**
/// 1. **Layout Composition:** It vertically stacks the `SplashLogo`, `SplashSubtitle`, and `SplashLoadingIndicator` in a centered column.
/// 2. **Visual Styling:** It applies the application's primary gradient background to the entire screen.
/// 3. **Animation Orchestration:** It manages a `SingleTickerProvider` to drive coordinated Fade and Scale animations for a polished entrance effect.
///
/// **How it is working:**
/// It initializes an `AnimationController` that runs for 1.5 seconds.
/// Two distinct animations (`_fadeAnimation` and `_scaleAnimation`) are derived from this controller using `Intervals`.
/// An `AnimatedBuilder` listens to the controller and rebuilds the UI frame-by-frame to update opacity and scale.
///
/// **How it's helpful:**
/// It creates a smooth, professional first impression, distracting the user while the app performs heavy initialization tasks (like Firebase connection) in the background.
*/

import 'package:flutter/material.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/widgets/splash/splash_logo.dart';
import 'package:quiz_panel/widgets/splash/splash_loading_indicator.dart';
import 'package:quiz_panel/widgets/splash/splash_subtitle.dart';

class SplashContent extends StatefulWidget {
  const SplashContent({super.key});

  @override
  State<SplashContent> createState() => _SplashContentState();
}

class _SplashContentState extends State<SplashContent>
    with SingleTickerProviderStateMixin {
  // **Animation Controllers:**
  late AnimationController
  _controller; // The engine driving the animation loop.
  late Animation<double> _fadeAnimation; // Controls opacity (0.0 -> 1.0).
  late Animation<double> _scaleAnimation; // Controls size (80% -> 100%).

  @override
  void initState() {
    super.initState();
    // **Setup Animation:**
    // Initialize the controller to run once for 1.5 seconds.
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // **Fade Effect:**
    // Starts immediately (0.0) and finishes at 60% (0.6) of the timeline.
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    // **Scale/Pop Effect:**
    // Starts slightly later (0.3) to create a dynamic "pop-in" feel.
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );

    // Start the animation sequence.
    _controller.forward();
  }

  @override
  void dispose() {
    // **Cleanup:**
    // Always dispose of the controller to stop the Ticker and prevent memory leaks.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // **Background:**
      // Applies the brand's primary gradient.
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      // **Animation Builder:**
      // Efficiently rebuilds only the transform/opacity layers when the controller ticks.
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.scale(scale: _scaleAnimation.value, child: child),
          );
        },
        // **Static Content:**
        // passed as `child` to AnimatedBuilder so it isn't rebuilt every frame, improving performance.
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(
              flex: 2,
            ), // Pushes content slightly upwards for optical balance.
            SplashLogo(),
            SizedBox(height: 24),
            SplashSubtitle(),
            Spacer(flex: 1),
            SplashLoadingIndicator(),
            SizedBox(height: 60), // Bottom padding.
          ],
        ),
      ),
    );
  }
}

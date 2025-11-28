// lib/widgets/splash/splash_logo.dart

/*
/// **Why we used this file (SplashLogo):**
/// This widget acts as the central **Branding Component** for the application's startup screen.
/// Instead of using a simple image asset, we build the logo programmatically using Flutter widgets.
///
/// **What it is doing:**
/// 1. **Visual Composition:** It creates a multi-layered design using a `Stack`.
/// 2. **Core Icon:** Displays the main "Quiz" icon inside a gradient-styled rounded box.
/// 3. **Decoration:** Adds subtle background glows and floating accent dots to give the logo a modern, polished look.
///
/// **How it helps:**
/// - **Scalability:** Since it's drawn with code (Vectors/Icons), it looks sharp on any screen size without pixelation.
/// - **Theming:** It automatically uses the `AppColors` defined in our theme, ensuring it always matches the app's color palette even if we change it later.
///
/// **How it is working:**
/// It uses a `Stack` widget to overlay three distinct layers:
/// 1. A faint background circle for depth.
/// 2. The main gradient container holding the `Icons.quiz_rounded` icon.
/// 3. Two `Positioned` widgets acting as decorative "bubbles" or "dots" around the main logo.
*/

import 'package:flutter/material.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';

class SplashLogo extends StatelessWidget {
  const SplashLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Layer 1: Background Glow
        // Creates a subtle, semi-transparent white circle behind the main logo.
        // This helps separate the logo from the main background gradient of the Splash Screen.
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
        ),

        // Layer 2: Main Logo Container
        // The central visual element containing the app icon.
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            // **Gradient:**
            // Uses a diagonal linear gradient (Top-Left to Bottom-Right) using the primary theme colors.
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryLight,
                AppColors.primary,
              ],
            ),
            borderRadius: BorderRadius.circular(20), // Smooth rounded corners.
            // **Shadow:**
            // Adds elevation/depth to make the logo appear to "float" above the background.
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          // The actual vector icon.
          child: const Icon(
            Icons.quiz_rounded,
            size: 50,
            color: Colors.white,
          ),
        ),

        // Layer 3: Decorative Elements (Bubbles)
        // These are purely aesthetic dots positioned absolutely relative to the stack.
        // They add "playfulness" to the design.

        // Top-Right Accent Dot
        Positioned(
          top: 25,
          right: 25,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.accentColor, // Uses the secondary accent color.
              shape: BoxShape.circle,
            ),
          ),
        ),

        // Bottom-Left Success Dot
        Positioned(
          bottom: 30,
          left: 25,
          child: Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              color: AppColors.success, // Uses the success (green) color.
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}
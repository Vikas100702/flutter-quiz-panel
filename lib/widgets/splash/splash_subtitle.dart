// lib/widgets/splash/splash_subtitle.dart

/*
/// **Why we used this file (SplashSubtitle):**
/// This widget handles the **Textual Branding** on the Splash Screen.
/// It separates the static text content (App Name and Tagline) from the complex animation logic found in `SplashContent`.
///
/// **What it is doing:**
/// 1. **Title Display:** Shows the application name "Pro Olympiad" in large, bold typography.
/// 2. **Tagline Display:** Shows the slogan "Elevate Your Learning Experience" in a smaller, lighter font.
/// 3. **Layout:** Vertically stacks these two text elements with consistent spacing.
///
/// **How it helps:**
/// - **Modularity:** If we need to change the app's name or slogan, we only edit this file, without risking breaking the splash screen animations.
/// - **Readability:** It keeps the main `SplashContent` file cleaner by offloading the text rendering logic.
///
/// **How it is working:**
/// It is a simple `StatelessWidget` that returns a `Column`. Inside, it renders two `Text` widgets
/// styled with the application's global text theme (`AppTextStyles`) but overridden with white colors to stand out against the dark splash background.
*/

import 'package:flutter/material.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';

class SplashSubtitle extends StatelessWidget {
  const SplashSubtitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Main Application Title
        // Large, bold text identifying the app.
        Text(
          'Pro Olympiad',
          style: AppTextStyles.displayMedium.copyWith(
            color: Colors.white, // White text to contrast with the gradient background.
            fontWeight: FontWeight.w700, // Extra bold for emphasis.
          ),
        ),

        const SizedBox(height: 8), // Vertical spacing between title and subtitle.

        // 2. App Tagline/Slogan
        // Smaller text describing the app's purpose.
        Text(
          'Elevate Your Learning Experience',
          style: AppTextStyles.bodyLarge.copyWith(
            // Uses a slightly transparent white (80% opacity) to create a visual hierarchy (Title > Subtitle).
            color: Colors.white.withValues(alpha: 0.8),
            fontWeight: FontWeight.w400, // Normal weight for readability.
          ),
        ),
      ],
    );
  }
}
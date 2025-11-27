// lib/widgets/splash/splash_subtitle.dart
import 'package:flutter/material.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';

class SplashSubtitle extends StatelessWidget {
  const SplashSubtitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main Title
        Text(
          'Pro Olympiad',
          style: AppTextStyles.displayMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 8),

        // Subtitle
        Text(
          'Elevate Your Learning Experience',
          style: AppTextStyles.bodyLarge.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
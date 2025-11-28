// lib/screens/splash/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:quiz_panel/widgets/splash/splash_content.dart';

// Why we used this Widget (SplashScreen):
// This is the first screen presented upon application startup. Its crucial role is to
// ensure the application's core dependencies (Firebase initialization, Auth state,
// User Profile data) are fully loaded and processed before routing the user.
//
// How it's helpful:
// It serves as the single initial point defined in the AppRouter, allowing the router's
// redirect logic to block navigation until a definitive destination (like Dashboard or Login)
// is determined based on the loaded user status.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  // What it is doing: Builds the visual layout for the splash screen.
  Widget build(BuildContext context) {
    return const Scaffold(
      // How it is working: Sets the background to transparent so the inner SplashContent's
      // gradient background is fully visible behind the Scaffold structure.
      backgroundColor: Colors.transparent,
      // What it is doing: Delegates the animation and visual loading indicator to the dedicated SplashContent widget.
      body: SplashContent(),
    );
  }
}
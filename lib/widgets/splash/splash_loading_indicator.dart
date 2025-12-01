// lib/widgets/splash/splash_loading_indicator.dart

/*
/// **Why we used this file (SplashLoadingIndicator):**
/// This widget provides the **Loading Feedback** component for the Splash Screen.
/// It lets the user know that the app is active and processing (fetching data, initializing Firebase)
/// rather than frozen.
///
/// **What it is doing:**
/// 1. **Visual Feedback:** Displays a "Loading..." text and a circular spinner.
/// 2. **Animation:** It implements a continuous "Breathing" or "Pulsing" effect where the entire indicator fades in and out slightly.
///
/// **How it is working:**
/// It uses an `AnimationController` set to repeat indefinitely in reverse (`repeat(reverse: true)`).
/// An `AnimatedBuilder` listens to this controller and updates the `Opacity` of the widget
/// between 0.5 (semi-transparent) and 1.0 (fully visible) every 3 seconds.
///
/// **How it's helpful:**
/// The pulsing animation adds a subtle, polished feel to the loading state, preventing the screen from looking static or unresponsive.
*/

import 'package:flutter/material.dart';

class SplashLoadingIndicator extends StatefulWidget {
  const SplashLoadingIndicator({super.key});

  @override
  State<SplashLoadingIndicator> createState() => _SplashLoadingIndicatorState();
}

class _SplashLoadingIndicatorState extends State<SplashLoadingIndicator>
    with SingleTickerProviderStateMixin {
  // **Animation Controllers:**
  late AnimationController _controller; // Manages the timing of the pulse.
  late Animation<double>
  _animation; // Defines the value change (opacity) over time.

  @override
  void initState() {
    super.initState();
    // **Setup Animation:**
    // Cycle duration is 3 seconds.
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true); // Loop back and forth (fade out, then fade in).

    // **Define Range:**
    // The opacity will fluctuate between 0.5 and 1.0.
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut, // Smooth acceleration/deceleration.
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // **Animated Builder:**
    // Rebuilds the Opacity widget every time the controller ticks.
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Column(
            children: [
              // Loading Text
              Text(
                'Loading...',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),

              // Spinner
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation(
                    Colors.white.withValues(alpha: 0.8),
                  ),
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

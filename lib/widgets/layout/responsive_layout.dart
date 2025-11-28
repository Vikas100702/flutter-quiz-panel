// lib/widgets/layout/responsive_layout.dart

/*
/// **Why we used this file (ResponsiveAuthLayout):**
/// This is a specialized layout wrapper designed specifically for Authentication screens
/// (like Login, Register, Forgot Password).
///
/// **What it is doing:**
/// 1. **Adaptive Design:** It automatically detects if the user is on a large screen (Desktop/Web) or a small screen (Mobile).
/// 2. **Desktop Mode:** On wide screens, it displays a professional gradient background and places the content inside a centered, elevated Card.
/// 3. **Mobile Mode:** On small screens, it removes the background and card shadow, keeping the design clean and focused for touch interaction.
/// 4. **Constraint Management:** It strictly limits the width of the content (to ~450-500px) so that text fields don't stretch uncomfortably wide on a PC monitor.
///
/// **How it helps:**
/// - **Consistency:** Ensures every auth screen has the same look and feel.
/// - **Readability:** Prevents "stretched UI" on web browsers by centering the form.
///
/// **How it is working:**
/// It uses a `LayoutBuilder` to read the screen constraints. Based on the `maxWidth`,
/// it toggles between `_buildDesktopCard` (Card UI) and `_buildMobileLayout` (Flat UI).
*/

import 'package:flutter/material.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';

class ResponsiveAuthLayout extends StatelessWidget {
  final Widget child; // The main content (e.g., LoginForm).
  final bool showBackground; // Option to disable the gradient background if needed.

  const ResponsiveAuthLayout({
    super.key,
    required this.child,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // **Breakpoints:**
        // Define what counts as "Desktop" vs "Mobile" based on pixel width.
        final bool isDesktop = constraints.maxWidth > 600;
        final bool isLargeMobile = constraints.maxWidth > 400;

        return Container(
          // **Dynamic Decoration:**
          // Desktop: Show a gradient background to fill the empty space.
          // Mobile: Use the standard surface color (White) for a clean look.
          decoration: showBackground ? BoxDecoration(
            gradient: isDesktop
                ? const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.background,
                Color(0xFFE8ECF4),
              ],
            )
                : null,
            color: isDesktop ? null : AppColors.surface,
          ) : null,
          child: Center(
            // **Constraints:**
            // This Box ensures the login form never gets too wide or too narrow.
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 500 : 450, // Cap width on desktop.
                minWidth: isLargeMobile ? 350 : 300, // Ensure minimum width on mobile.
              ),
              // **Layout Switching Logic:**
              // If Desktop and background is on -> Show the "Card" style.
              // Otherwise -> Show the "Mobile" style.
              child: isDesktop && showBackground
                  ? _buildDesktopCard(child)
                  : _buildMobileLayout(child, isDesktop),
            ),
          ),
        );
      },
    );
  }

  /// **Helper: Desktop Card Layout**
  /// Wraps the content in a Material Card with shadow elevation.
  /// Used to make the form "pop" against the large background.
  Widget _buildDesktopCard(Widget child) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 40,
          vertical: 50,
        ),
        child: child,
      ),
    );
  }

  /// **Helper: Mobile Layout**
  /// A simpler layout with standard padding, optimized for small screens.
  Widget _buildMobileLayout(Widget child, bool isDesktop) {
    return Padding(
      padding: EdgeInsets.symmetric(
        // Use more horizontal padding on desktop mode (if card is disabled) to center visually.
        horizontal: isDesktop ? 40 : 20,
        vertical: isDesktop ? 32 : 20,
      ),
      child: child,
    );
  }
}
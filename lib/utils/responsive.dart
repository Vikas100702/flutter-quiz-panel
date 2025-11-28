// lib/utils/responsive.dart

/*
/// Why we used this file (Responsive):
/// This is a utility widget used to simplify **responsive design** across the entire application.
/// Instead of writing complex `MediaQuery` logic in every widget to check the screen size,
/// developers can use this single component to switch between different layouts (mobile, tablet, desktop).

/// What it is doing:
/// 1. **Defines Breakpoints:** Establishes clear, fixed screen width values to categorize devices (e.g., anything below 650px is 'mobile').
/// 2. **Conditional Rendering:** Renders one of three provided `Widget` branches (`mobile`, `tablet`, or `desktop`) based on the current screen size.

/// How it is working:
/// 1. It checks the screen's width using `MediaQuery.of(context).size.width`.
/// 2. It compares this width against predefined `_mobileWidth` (650px) and `_tabletWidth` (1100px) thresholds.
/// 3. It returns the appropriate widget. If `tablet` is null but the screen is tablet-sized, it defaults gracefully to `mobile`.

/// How it's helpful:
/// It drastically cleans up the UI code, making it declarative: `Responsive(mobile: SmallLayout(), desktop: WideLayout())`.
/// This ensures a consistent, optimized layout experience for users, whether they are on a phone, tablet, or web browser.
*/
import 'package:flutter/material.dart';

/// Why we used this class: A StatelessWidget designed specifically to choose and render one child widget based on screen size.
class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet; // Why it is nullable: Allows developers to skip designing a specific tablet layout if the mobile layout is sufficient.
  final Widget desktop;

  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  // Screen size breakpoints
  // What it is doing: Defines the pixel widths that serve as boundaries for screen categorization.
  static const double _mobileWidth = 650;
  static const double _tabletWidth = 1100;

  /// What it is doing: Checks if the current device width falls into the mobile category (< 650px).
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < _mobileWidth;

  /// What it is doing: Checks if the width falls into the tablet category (>= 650px AND < 1100px).
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= _mobileWidth &&
          MediaQuery.of(context).size.width < _tabletWidth;

  /// What it is doing: Checks if the width falls into the desktop category (>= 1100px).
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= _tabletWidth;

  @override
  /// What it is doing: The core rendering logic that decides which widget to return.
  Widget build(BuildContext context) {
    // How it is working: Retrieves the current screen dimensions efficiently.
    final Size size = MediaQuery.of(context).size;

    // 1. Desktop Condition (Widest screen)
    if (size.width >= _tabletWidth) {
      return desktop;
    }
    // 2. Tablet Condition (Medium screen)
    else if (size.width >= _mobileWidth) {
      // How it is helpful: If the `tablet` widget is not provided (is null), it defaults to using the `mobile` widget instead.
      return tablet ?? mobile;
    }
    // 3. Mobile Condition (Narrowest screen)
    else {
      return mobile;
    }
  }
}
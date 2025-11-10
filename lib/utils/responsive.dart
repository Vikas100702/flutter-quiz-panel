// lib/utils/responsive.dart
import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  // Screen size breakpoints
  static const double _mobileWidth = 650;
  static const double _tabletWidth = 1100;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < _mobileWidth;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= _mobileWidth &&
          MediaQuery.of(context).size.width < _tabletWidth;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= _tabletWidth;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    if (size.width >= _tabletWidth) {
      return desktop;
    } else if (size.width >= _mobileWidth) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
}
// lib/widgets/layout/responsive_layout.dart (updated)
import 'package:flutter/material.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';

class ResponsiveAuthLayout extends StatelessWidget {
  final Widget child;
  final bool showBackground;

  const ResponsiveAuthLayout({
    super.key,
    required this.child,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth > 600;
        final bool isLargeMobile = constraints.maxWidth > 400;

        return Container(
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
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 500 : 450,
                minWidth: isLargeMobile ? 350 : 300,
              ),
              child: isDesktop && showBackground
                  ? _buildDesktopCard(child)
                  : _buildMobileLayout(child, isDesktop),
            ),
          ),
        );
      },
    );
  }

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

  Widget _buildMobileLayout(Widget child, bool isDesktop) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 40 : 20,
        vertical: isDesktop ? 32 : 20,
      ),
      child: child,
    );
  }
}
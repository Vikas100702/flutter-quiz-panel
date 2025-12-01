// lib/widgets/buttons/app_button.dart

/*
/// **Why we used this file (AppButton):**
/// This is the primary, reusable button component for the entire application.
/// Instead of writing `ElevatedButton` or `TextButton` over and over again with custom styles,
/// we use this single widget to ensure all buttons look and behave consistently.
///
/// **What it is doing:**
/// 1. **Standardization:** It enforces a uniform design system (height, padding, border radius) for all buttons.
/// 2. **Types:** It supports four distinct visual styles (`primary`, `secondary`, `outline`, `text`) via an enum.
/// 3. **State Management:** It automatically handles `isLoading` states (showing a spinner) and `isDisabled` states (graying out).
/// 4. **Icon Support:** It allows optional icons to be placed next to the text.
///
/// **How it helps:**
/// - **Maintainability:** If we want to change the border radius of *every* button in the app, we only change it here.
/// - **Productivity:** Developers just type `AppButton(type: AppButtonType.primary)` instead of 20 lines of styling code.
///
/// **How it is working:**
/// It uses a `StatelessWidget` that takes configuration parameters (text, type, callbacks) and
/// dynamically builds the correct Flutter button (`ElevatedButton`, `OutlinedButton`, or `TextButton`)
/// with the appropriate styles applied.
*/

import 'package:flutter/material.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';

// **Enum Definition:**
// Defines the four supported button styles.
// - `primary`: Solid background (Main action).
// - `secondary`: Different solid background (Alternative main action).
// - `outline`: Transparent background with border (Secondary action).
// - `text`: No background or border (Lowest priority action).
enum AppButtonType { primary, secondary, outline, text }

class AppButton extends StatelessWidget {
  // **Inputs:**
  final String text; // The label on the button.
  final VoidCallback? onPressed; // The function to run when tapped (nullable).
  final AppButtonType type; // The visual style to apply.
  final bool isLoading; // If true, shows a spinner instead of text.
  final bool isDisabled; // If true, the button is unclickable and grayed out.
  final IconData? icon; // Optional icon to display before the text.
  final double? width; // Optional fixed width.
  final double? height; // Optional fixed height (defaults to 48).

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    // **Logic: Determine Enabled State**
    // The button is "enabled" only if:
    // 1. It is not manually disabled.
    // 2. It is not currently loading.
    // 3. The onPressed callback is not null.
    final bool isEnabled = !isDisabled && !isLoading && onPressed != null;

    // Get the specific style (colors, shape) based on the type and enabled state.
    final buttonStyle = _getButtonStyle(context, isEnabled);

    // **Logic: Content Switching**
    // If loading, show a spinner. Otherwise, show the Row (Icon + Text).
    final child = isLoading
        ? SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              // The spinner color adapts based on the button type (white for solid, primary for outline).
              valueColor: AlwaysStoppedAnimation(_getLoaderColor(isEnabled)),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(text, style: _getTextStyle(isEnabled)),
            ],
          );

    // Wrap in SizedBox to enforce dimensions.
    return SizedBox(
      width: width,
      height: height ?? 48, // Default height is 48px standard touch target.
      child: _buildButtonByType(buttonStyle, child, isEnabled),
    );
  }

  /// **Helper: Widget Builder**
  /// Returns the correct Flutter widget based on the `type` enum.
  Widget _buildButtonByType(
    ButtonStyle buttonStyle,
    Widget child,
    bool isEnabled,
  ) {
    switch (type) {
      case AppButtonType.primary:
        return ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: buttonStyle,
          child: child,
        );
      case AppButtonType.secondary:
        return ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: buttonStyle,
          child: child,
        );
      case AppButtonType.outline:
        return OutlinedButton(
          onPressed: isEnabled ? onPressed : null,
          style: buttonStyle,
          child: child,
        );
      case AppButtonType.text:
        return TextButton(
          onPressed: isEnabled ? onPressed : null,
          style: buttonStyle,
          child: child,
        );
    }
  }

  /// **Helper: Style Factory**
  /// Generates the `ButtonStyle` object. This controls padding, shape, colors, and shadows.
  ButtonStyle _getButtonStyle(BuildContext context, bool isEnabled) {
    final baseStyle = ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0, // Flat look is generally preferred.
    );

    switch (type) {
      case AppButtonType.primary:
        return baseStyle.copyWith(
          // **Dynamic Background Color:**
          // Uses `resolveWith` to handle disabled state coloring automatically.
          backgroundColor: WidgetStateProperty.resolveWith<Color>((
            Set<WidgetState> states,
          ) {
            if (!isEnabled) {
              // Dimmed color for disabled state.
              return AppColors.textTertiary.withValues(alpha: 0.3);
            }
            return AppColors.primary;
          }),
          foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
          overlayColor: WidgetStateProperty.all<Color>(
            Colors.white.withValues(alpha: 0.1), // Subtle white splash on tap.
          ),
        );

      case AppButtonType.secondary:
        return baseStyle.copyWith(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((
            Set<WidgetState> states,
          ) {
            if (!isEnabled) {
              return AppColors.textTertiary.withValues(alpha: 0.3);
            }
            return AppColors.secondary;
          }),
          foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
          overlayColor: WidgetStateProperty.all<Color>(
            Colors.white.withValues(alpha: 0.1),
          ),
        );

      case AppButtonType.outline:
        return OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          // Border color logic.
          side: BorderSide(
            color: isEnabled
                ? AppColors.primary
                : AppColors.textTertiary.withValues(alpha: 0.3),
            width: 1.5,
          ),
          backgroundColor: Colors.transparent,
          foregroundColor: isEnabled
              ? AppColors.primary
              : AppColors.textTertiary.withValues(alpha: 0.3),
        );

      case AppButtonType.text:
        return TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          foregroundColor: isEnabled
              ? AppColors.primary
              : AppColors.textTertiary.withValues(alpha: 0.3),
        );
    }
  }

  /// **Helper: Text Style Factory**
  /// Ensures the text color matches the button type (White for solid buttons, Primary color for outline/text).
  TextStyle _getTextStyle(bool isEnabled) {
    const baseStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);

    switch (type) {
      case AppButtonType.primary:
      case AppButtonType.secondary:
        return baseStyle.copyWith(
          color: isEnabled ? Colors.white : Colors.white.withValues(alpha: 0.5),
        );
      case AppButtonType.outline:
      case AppButtonType.text:
        return baseStyle.copyWith(
          color: isEnabled
              ? AppColors.primary
              : AppColors.textTertiary.withValues(alpha: 0.3),
        );
    }
  }

  /// **Helper: Loader Color Factory**
  /// Ensures the spinner is visible against the background.
  Color _getLoaderColor(bool isEnabled) {
    switch (type) {
      case AppButtonType.primary:
      case AppButtonType.secondary:
        return Colors.white; // White spinner on solid backgrounds.
      case AppButtonType.outline:
      case AppButtonType.text:
        return isEnabled
            ? AppColors.primary
            : AppColors.textTertiary.withValues(
                alpha: 0.3,
              ); // Primary spinner on transparent backgrounds.
    }
  }
}

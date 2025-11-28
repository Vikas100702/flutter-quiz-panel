// lib/widgets/buttons/app_button_variants.dart

/*
/// **Why we used this file (AppButtonVariants):**
/// This class acts as a **Factory** or **Helper** for creating `AppButton` instances.
/// Instead of manually setting the `type` parameter every time we use a button (e.g., `AppButton(type: AppButtonType.primary)`),
/// this class provides named constructors (static methods) that do it for us.
///
/// **What it is doing:**
/// It defines static methods like `primary()`, `secondary()`, `outline()`, and `text()`.
/// Each method takes the necessary inputs (text, onPressed) and returns a fully configured `AppButton`.
///
/// **How it helps:**
/// 1. **Readability:** Code like `AppButtonVariants.primary(...)` is easier to read than manual configuration.
/// 2. **Consistency:** It ensures that every "Primary" button uses the exact same underlying `AppButtonType.primary` setting.
/// 3. **Speed:** It saves developers from typing the enum value repeatedly.
///
/// **How it is working:**
/// It uses static functions that wrap the main `AppButton` constructor, pre-filling the `type` property based on the method name.
*/

import 'package:flutter/material.dart';
import 'app_button.dart';

class AppButtonVariants {
  /// **Variant: Primary Button**
  /// **Use Case:** The most important action on a screen (e.g., "Login", "Submit", "Save").
  /// **Visual:** Solid background color (Primary Theme Color).
  static AppButton primary({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    IconData? icon,
    double? width,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      type: AppButtonType.primary, // Pre-sets the type.
      isLoading: isLoading,
      isDisabled: isDisabled,
      icon: icon,
      width: width,
    );
  }

  /// **Variant: Secondary Button**
  /// **Use Case:** An alternative main action (e.g., "Next" in a tutorial, or a less critical "Submit").
  /// **Visual:** Solid background color (Secondary Theme Color).
  static AppButton secondary({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    IconData? icon,
    double? width,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      type: AppButtonType.secondary, // Pre-sets the type.
      isLoading: isLoading,
      isDisabled: isDisabled,
      icon: icon,
      width: width,
    );
  }

  /// **Variant: Outline Button**
  /// **Use Case:** Secondary actions that should not distract from the primary button (e.g., "Cancel", "Back").
  /// **Visual:** Transparent background with a visible border.
  static AppButton outline({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    IconData? icon,
    double? width,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      type: AppButtonType.outline, // Pre-sets the type.
      isLoading: isLoading,
      isDisabled: isDisabled,
      icon: icon,
      width: width,
    );
  }

  /// **Variant: Text Button**
  /// **Use Case:** Lowest priority actions, links, or inline options (e.g., "Forgot Password?", "Read More").
  /// **Visual:** No background, no border, just colored text.
  static AppButton text({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    IconData? icon,
    double? width,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      type: AppButtonType.text, // Pre-sets the type.
      isLoading: isLoading,
      isDisabled: isDisabled,
      icon: icon,
      width: width,
    );
  }
}
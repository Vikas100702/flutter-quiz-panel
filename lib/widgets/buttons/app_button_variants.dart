// lib/widgets/buttons/app_button_variants.dart
import 'package:flutter/material.dart';
import 'app_button.dart';

class AppButtonVariants {
  static AppButton primary({
    required String text,
    required VoidCallback? onPressed, // Changed to nullable
    bool isLoading = false,
    bool isDisabled = false,
    IconData? icon,
    double? width,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      type: AppButtonType.primary,
      isLoading: isLoading,
      isDisabled: isDisabled,
      icon: icon,
      width: width,
    );
  }

  static AppButton secondary({
    required String text,
    required VoidCallback? onPressed, // Changed to nullable
    bool isLoading = false,
    bool isDisabled = false,
    IconData? icon,
    double? width,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      type: AppButtonType.secondary,
      isLoading: isLoading,
      isDisabled: isDisabled,
      icon: icon,
      width: width,
    );
  }

  static AppButton outline({
    required String text,
    required VoidCallback? onPressed, // Changed to nullable
    bool isLoading = false,
    bool isDisabled = false,
    IconData? icon,
    double? width,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      type: AppButtonType.outline,
      isLoading: isLoading,
      isDisabled: isDisabled,
      icon: icon,
      width: width,
    );
  }

  static AppButton text({
    required String text,
    required VoidCallback? onPressed, // Changed to nullable
    bool isLoading = false,
    bool isDisabled = false,
    IconData? icon,
    double? width,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      type: AppButtonType.text,
      isLoading: isLoading,
      isDisabled: isDisabled,
      icon: icon,
      width: width,
    );
  }
}
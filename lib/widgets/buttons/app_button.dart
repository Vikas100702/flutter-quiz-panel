// lib/widgets/buttons/app_button.dart
import 'package:flutter/material.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';

enum AppButtonType { primary, secondary, outline, text }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // Changed to nullable
  final AppButtonType type;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final double? width;
  final double? height;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed, // Still required but now nullable
    this.type = AppButtonType.primary,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final bool _isEnabled = !isDisabled && !isLoading && onPressed != null;
    final buttonStyle = _getButtonStyle(context, _isEnabled);
    final child = isLoading
        ? SizedBox(
      height: 24,
      width: 24,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation(_getLoaderColor(_isEnabled)),
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
        Text(
          text,
          style: _getTextStyle(_isEnabled),
        ),
      ],
    );

    return SizedBox(
      width: width,
      height: height ?? 48,
      child: _buildButtonByType(buttonStyle, child, _isEnabled),
    );
  }

  Widget _buildButtonByType(ButtonStyle buttonStyle, Widget child, bool isEnabled) {
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

  ButtonStyle _getButtonStyle(BuildContext context, bool isEnabled) {
    final baseStyle = ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
    );

    switch (type) {
      case AppButtonType.primary:
        return baseStyle.copyWith(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
              if (!isEnabled) {
                return AppColors.textTertiary.withOpacity(0.3);
              }
              return AppColors.primary;
            },
          ),
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          overlayColor: MaterialStateProperty.all<Color>(
            Colors.white.withOpacity(0.1),
          ),
        );

      case AppButtonType.secondary:
        return baseStyle.copyWith(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
              if (!isEnabled) {
                return AppColors.textTertiary.withOpacity(0.3);
              }
              return AppColors.secondary;
            },
          ),
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          overlayColor: MaterialStateProperty.all<Color>(
            Colors.white.withOpacity(0.1),
          ),
        );

      case AppButtonType.outline:
        return OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(
            color: isEnabled ? AppColors.primary : AppColors.textTertiary.withOpacity(0.3),
            width: 1.5,
          ),
          backgroundColor: Colors.transparent,
          foregroundColor: isEnabled ? AppColors.primary : AppColors.textTertiary.withOpacity(0.3),
        );

      case AppButtonType.text:
        return TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          foregroundColor: isEnabled ? AppColors.primary : AppColors.textTertiary.withOpacity(0.3),
        );
    }
  }

  TextStyle _getTextStyle(bool isEnabled) {
    const baseStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );

    switch (type) {
      case AppButtonType.primary:
      case AppButtonType.secondary:
        return baseStyle.copyWith(
          color: isEnabled ? Colors.white : Colors.white.withOpacity(0.5),
        );
      case AppButtonType.outline:
      case AppButtonType.text:
        return baseStyle.copyWith(
          color: isEnabled ? AppColors.primary : AppColors.textTertiary.withOpacity(0.3),
        );
    }
  }

  Color _getLoaderColor(bool isEnabled) {
    switch (type) {
      case AppButtonType.primary:
      case AppButtonType.secondary:
        return Colors.white;
      case AppButtonType.outline:
      case AppButtonType.text:
        return isEnabled ? AppColors.primary : AppColors.textTertiary.withOpacity(0.3);
    }
  }
}
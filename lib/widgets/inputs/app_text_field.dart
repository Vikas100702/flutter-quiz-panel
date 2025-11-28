// lib/widgets/inputs/app_text_field.dart

/*
/// **Why we used this file (AppTextField):**
/// This is a custom wrapper around Flutter's standard `TextFormField`.
/// Instead of styling every single text box in the app individually (which leads to inconsistent designs),
/// we use this single widget. It ensures that every input field—whether for login, profile editing,
/// or search—looks and behaves exactly the same way.
///
/// **What it is doing:**
/// 1. **Unified Design:** It applies our specific border radius, colors, and padding defined in `AppTheme`.
/// 2. **Password Handling:** It has built-in logic to show/hide password text (the "eye" icon functionality).
/// 3. **Labeling:** It automatically places a title label above the input box for better readability.
/// 4. **Validation:** It connects seamlessly with Flutter's Form validation system.
///
/// **How it helps:**
/// - **Productivity:** Developers just need to pass a controller and a label. They don't need to write 50 lines of decoration code.
/// - **UX Consistency:** The error states, focus colors, and disabled states are identical across the app.
///
/// **How it is working:**
/// It is a `StatefulWidget` mainly to handle the internal state of `_obscureText` (for passwords).
/// It builds a `Column` containing a Text label and the actual `TextFormField` input.
*/

import 'package:flutter/material.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';

class AppTextField extends StatefulWidget {
  // **Inputs:**
  final TextEditingController controller; // Controls the text being edited.
  final String label; // The title displayed above the field.
  final String? hint; // Placeholder text inside the field.
  final IconData? prefixIcon; // Icon shown at the start of the field.
  final IconData? suffixIcon; // Icon shown at the end (overridden if isPassword is true).
  final bool isPassword; // If true, enables the show/hide toggle logic.
  final TextInputType keyboardType; // Keyboard layout (e.g., email, number, text).
  final bool enabled; // If false, the field is grayed out and uneditable.
  final Function(String)? onSubmitted; // Called when user presses "Enter".
  final String? Function(String?)? validator; // Function to check if input is valid.

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.onSubmitted,
    this.validator,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  // **State Variable:**
  // Tracks whether the text should be hidden (dots) or visible.
  // Defaults to true (hidden) for password fields.
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. The Label Title
        Text(
          widget.label,
          style: AppTextStyles.titleSmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),

        // 2. The Input Field
        TextFormField(
          controller: widget.controller,
          // Logic: Only obscure text if it IS a password field AND the user hasn't toggled visibility.
          obscureText: widget.isPassword && _obscureText,
          keyboardType: widget.keyboardType,
          enabled: widget.enabled,
          onFieldSubmitted: widget.onSubmitted,
          validator: widget.validator,
          // How it helps: Automatically shows error messages as the user types (after first interaction).
          autovalidateMode: AutovalidateMode.onUserInteraction,

          // **Styling Configuration:**
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon != null
                ? Icon(
              widget.prefixIcon,
              color: AppColors.textTertiary,
            )
                : null,
            // Logic: Calls helper to determine if we show a custom icon or the password toggle eye.
            suffixIcon: _buildSuffixIcon(),
            filled: true,
            // Dynamic Background: White if enabled, Gray if disabled.
            fillColor: widget.enabled
                ? AppColors.surface
                : AppColors.background,

            // Default Border (Idle)
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.outline),
            ),
            // Enabled Border (Unfocused but editable)
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.outline),
            ),
            // Focused Border (User is typing) - Highlighted with Primary Color.
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            // Disabled Border - Dimmed outline.
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.outline.withValues(alpha: 0.5),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  /// **Helper: Suffix Icon Builder**
  /// **What it does:** Decides what icon to show at the end of the text field.
  /// **Logic:**
  /// - If it's a **Password Field**, it returns an "Eye" button that toggles `_obscureText`.
  /// - If it's **Not** a password field but a `suffixIcon` was provided, it shows that icon.
  /// - Otherwise, it returns null (no icon).
  Widget? _buildSuffixIcon() {
    if (widget.isPassword) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_rounded : Icons.visibility_off_rounded,
          color: AppColors.textTertiary,
        ),
        onPressed: () {
          // Trigger a rebuild to update the obscureText state.
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }

    if (widget.suffixIcon != null) {
      return Icon(
        widget.suffixIcon,
        color: AppColors.textTertiary,
      );
    }

    return null;
  }
}
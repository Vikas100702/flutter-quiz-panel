// lib/widgets/auth/role_selector.dart

/*
/// **Why we used this file (RoleSelector):**
/// This widget acts as a specialized input component for the Registration form.
/// It replaces a standard dropdown or radio button with a more visually appealing,
/// card-based selection interface for choosing between "Student" and "Teacher".
///
/// **What it is doing:**
/// 1. **Visual Selection:** Displays two large, clickable cards with icons and labels for the available roles.
/// 2. **Responsiveness:** Automatically switches between a horizontal row (for wider screens) and a vertical column (for very narrow mobile screens) to prevent layout overflow.
/// 3. **State Feedback:** Visually highlights the currently selected role with a primary color border and background tint.
///
/// **How it helps:**
/// - **User Experience:** Large touch targets make it easier for users to select their role on mobile devices.
/// - **Clarity:** Icons and clear labels reduce cognitive load compared to a simple text list.
///
/// **How it is working:**
/// It receives the `selectedRole` and a callback `onRoleChanged` from the parent.
/// When a user taps a card, it triggers the callback, allowing the parent widget to update its state.
*/

import 'package:flutter/material.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/utils/constants.dart';

class RoleSelector extends StatelessWidget {
  // **Inputs:**
  // The current state (which role is picked) and the function to call when it changes.
  final String selectedRole;
  final ValueChanged<String> onRoleChanged;

  const RoleSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label above the selector
        Text(
          AppStrings.iAmA,
          style: AppTextStyles.titleSmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),

        // **Responsive Layout Logic:**
        // We use LayoutBuilder to read the exact pixel width available to this widget.
        LayoutBuilder(
          builder: (context, constraints) {
            // Threshold: If width is less than 400px, we consider it a narrow screen.
            final bool isVertical = constraints.maxWidth < 400;

            // Switch the layout direction based on the width check.
            return isVertical
                ? _buildVerticalRoleSelector()
                : _buildHorizontalRoleSelector();
          },
        ),
      ],
    );
  }

  // --- Layout Variant 1: Horizontal (Wider Screens) ---
  /// **What it is doing:** Places the two role cards side-by-side in a Row.
  Widget _buildHorizontalRoleSelector() {
    return Row(
      children: [
        // **Expanded:** Ensures both cards take up equal 50% width.
        Expanded(
          child: _buildRoleOption(
            role: UserRoles.student,
            label: AppStrings.student,
            icon: Icons.school_rounded,
          ),
        ),
        // Spacing between the two cards.
        const SizedBox(width: 12),
        Expanded(
          child: _buildRoleOption(
            role: UserRoles.teacher,
            label: AppStrings.teacher,
            icon: Icons.history_edu_rounded,
          ),
        ),
      ],
    );
  }

  // --- Layout Variant 2: Vertical (Narrow Screens) ---
  /// **What it is doing:** Stacks the two role cards vertically in a Column.
  /// This prevents "Right Overflow" errors on small phones.
  Widget _buildVerticalRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildRoleOption(
          role: UserRoles.student,
          label: AppStrings.student,
          icon: Icons.school_rounded,
        ),
        // Spacing between the top and bottom card.
        const SizedBox(height: 12),
        _buildRoleOption(
          role: UserRoles.teacher,
          label: AppStrings.teacher,
          icon: Icons.history_edu_rounded,
        ),
      ],
    );
  }

  // --- Shared Component: Role Card ---
  /// **Logic: Build Selectable Option**
  /// This function creates the actual visual card for a specific role.
  ///
  /// **Parameters:**
  /// - `role`: The ID string (e.g., 'student').
  /// - `label`: The display text (e.g., "Student").
  /// - `icon`: The visual icon.
  Widget _buildRoleOption({
    required String role,
    required String label,
    required IconData icon,
  }) {
    // Check if this specific card matches the currently selected role.
    final bool isSelected = selectedRole == role;

    return GestureDetector(
      // **Interaction:**
      // Calls the parent's function when tapped, passing back the role ID.
      onTap: () => onRoleChanged(role),
      behavior: HitTestBehavior
          .translucent, // Ensures taps work on empty space inside the container.
      child: Container(
        // Fixed height for consistency.
        height: 75,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          // **Dynamic Styling:**
          // - Background: Light primary tint if selected, otherwise standard background.
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.background,
          // - Border: Primary color and thicker if selected, otherwise thin outline.
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outline,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon changes color based on selection status.
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.primary : AppColors.textTertiary,
            ),
            const SizedBox(height: 4),
            // Text Label
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textTertiary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

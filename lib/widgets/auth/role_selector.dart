// lib/widgets/auth/role_selector.dart
import 'package:flutter/material.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/utils/constants.dart';

class RoleSelector extends StatelessWidget {
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
        Text(
          AppStrings.iAmA,
          style: AppTextStyles.titleSmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),

        // Responsive role selection
        LayoutBuilder(
          builder: (context, constraints) {
            // Hum 400px se kam width par vertical layout dikhayenge
            final bool isVertical = constraints.maxWidth < 400;

            return isVertical
                ? _buildVerticalRoleSelector()
                : _buildHorizontalRoleSelector();
          },
        ),
      ],
    );
  }

  // --- HORIZONTAL (Badi Screen) ---
  Widget _buildHorizontalRoleSelector() {
    return Row(
      children: [
        // Expanded taaki dono button barabar space lein
        Expanded(
          child: _buildRoleOption(
            role: UserRoles.student,
            label: AppStrings.student,
            icon: Icons.school_rounded,
          ),
        ),
        // --- 1. Dono buttons ke beech mein space ---
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

  // --- VERTICAL (Choti Screen) ---
  Widget _buildVerticalRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildRoleOption(
          role: UserRoles.student,
          label: AppStrings.student,
          icon: Icons.school_rounded,
        ),
        // --- 1. Dono buttons ke beech mein space ---
        const SizedBox(height: 12),
        _buildRoleOption(
          role: UserRoles.teacher,
          label: AppStrings.teacher,
          icon: Icons.history_edu_rounded,
        ),
      ],
    );
  }

  // --- 2. YEH WIDGET AB POORA SELECTION LOGIC HANDLE KARTA HAI ---
  Widget _buildRoleOption({
    required String role,
    required String label,
    required IconData icon,
  }) {
    final bool isSelected = selectedRole == role;

    return GestureDetector(
      onTap: () => onRoleChanged(role),
      behavior: HitTestBehavior.translucent,
      child: Container(
        // Ek consistent height di
        height: 75,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          // Jab selected ho toh background color badlein
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.background,
          // Border logic: select hone par primary, varna outline
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outline,
            width: isSelected ? 2 : 1,
          ),
          // Consistent border radius
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.primary : AppColors.textTertiary,
            ),
            const SizedBox(height: 4),
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
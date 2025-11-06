// lib/widgets/selection/role_selector.dart
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
            final bool isSmallScreen = constraints.maxWidth < 350;

            return isSmallScreen
                ? _buildVerticalRoleSelector()
                : _buildHorizontalRoleSelector();
          },
        ),
      ],
    );
  }

  Widget _buildHorizontalRoleSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          _buildRoleOption(
            role: UserRoles.student,
            label: AppStrings.student,
            icon: Icons.school_rounded,
            isHorizontal: true,
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.outline,
          ),
          _buildRoleOption(
            role: UserRoles.teacher,
            label: AppStrings.teacher,
            icon: Icons.history_edu_rounded,
            isHorizontal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalRoleSelector() {
    return Column(
      children: [
        _buildRoleOption(
          role: UserRoles.student,
          label: AppStrings.student,
          icon: Icons.school_rounded,
          isHorizontal: false,
        ),
        const SizedBox(height: 8),
        _buildRoleOption(
          role: UserRoles.teacher,
          label: AppStrings.teacher,
          icon: Icons.history_edu_rounded,
          isHorizontal: false,
        ),
      ],
    );
  }

  Widget _buildRoleOption({
    required String role,
    required String label,
    required IconData icon,
    required bool isHorizontal,
  }) {
    final bool isSelected = selectedRole == role;

    return Expanded(
      child: GestureDetector(
        onTap: () => onRoleChanged(role),
        child: Container(
          height: isHorizontal ? 75 : 56,
          padding: isHorizontal
              ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
              : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
            borderRadius: isHorizontal
                ? _getBorderRadius(role, isHorizontal)
                : BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
          ),
          child: Column(
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
      ),
    );
  }

  BorderRadius _getBorderRadius(String role, bool isHorizontal) {
    if (!isHorizontal) return BorderRadius.circular(8);

    if (role == UserRoles.student) {
      return const BorderRadius.only(
        topLeft: Radius.circular(8),
        bottomLeft: Radius.circular(8),
      );
    } else {
      return const BorderRadius.only(
        topRight: Radius.circular(8),
        bottomRight: Radius.circular(8),
      );
    }
  }
}
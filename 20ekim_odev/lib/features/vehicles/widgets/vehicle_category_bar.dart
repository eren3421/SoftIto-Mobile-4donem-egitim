import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../domain/models/vehicle_type.dart';

class VehicleCategoryBar extends StatelessWidget {
  final VehicleCategory? selectedCategory;
  final ValueChanged<VehicleCategory?> onCategorySelected;

  const VehicleCategoryBar({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Row(
        children: [
          _buildItem(
            context,
            label: 'Tümü',
            icon: Icons.apps,
            isSelected: selectedCategory == null,
            onTap: () => onCategorySelected(null),
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildItem(
            context,
            label: 'Kara Taşıtları',
            icon: Icons.directions_car,
            isSelected: selectedCategory == VehicleCategory.land,
            onTap: () => onCategorySelected(VehicleCategory.land),
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildItem(
            context,
            label: 'Hava Taşıtları',
            icon: Icons.flight_takeoff,
            isSelected: selectedCategory == VehicleCategory.air,
            onTap: () => onCategorySelected(VehicleCategory.air),
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildItem(
            context,
            label: 'Deniz Taşıtları',
            icon: Icons.sailing,
            isSelected: selectedCategory == VehicleCategory.sea,
            onTap: () => onCategorySelected(VehicleCategory.sea),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.radiusMd,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.crimsonPrimary
                : (isDark ? AppColors.slateCardGrey : AppColors.lightInputBg),
            borderRadius: AppSpacing.radiusMd,
            border: Border.all(
              color: isSelected
                  ? AppColors.crimsonAccent
                  : (isDark ? AppColors.steelBorderGrey : AppColors.lightBorder),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? AppColors.platinumText
                    : (isDark ? AppColors.silverText : AppColors.lightTextSecondary),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.platinumText
                      : (isDark ? AppColors.silverText : AppColors.lightTextSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

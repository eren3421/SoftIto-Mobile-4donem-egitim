import 'package:flutter/material.dart';
import '../../features/vehicles/domain/models/vehicle_type.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

class VehicleTypeBadge extends StatelessWidget {
  final VehicleCategory category;
  final bool compact;

  const VehicleTypeBadge({
    super.key,
    required this.category,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    switch (category) {
      case VehicleCategory.land:
        return _buildBadge(
          context,
          label: 'Kara Taşıtı',
          icon: Icons.directions_car_filled,
          bgColor: const Color(0xFF323740),
          borderColor: AppColors.crimsonAccent,
          textColor: AppColors.platinumText,
          iconColor: AppColors.crimsonLight,
        );
      case VehicleCategory.air:
        return _buildBadge(
          context,
          label: 'Hava Taşıtı',
          icon: Icons.flight_takeoff,
          bgColor: const Color(0xFF3A0A0E),
          borderColor: AppColors.crimsonPrimary,
          textColor: AppColors.crimsonLight,
          iconColor: AppColors.crimsonLight,
        );
      case VehicleCategory.sea:
        return _buildBadge(
          context,
          label: 'Deniz Taşıtı',
          icon: Icons.sailing,
          bgColor: const Color(0xFF262A30),
          borderColor: AppColors.silverText,
          textColor: AppColors.platinumText,
          iconColor: AppColors.seaCyan,
        );
    }
  }

  Widget _buildBadge(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
    required Color iconColor,
  }) {
    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppSpacing.radiusSm,
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: iconColor),
            const SizedBox(width: 4),
            Text(
              category.displayName,
              style: TextStyle(
                color: textColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppSpacing.radiusSm,
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: iconColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

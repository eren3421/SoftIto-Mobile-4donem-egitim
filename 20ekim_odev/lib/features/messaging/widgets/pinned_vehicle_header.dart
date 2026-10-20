import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/vehicle_type_badge.dart';
import '../domain/models/chat_room.dart';

class PinnedVehicleHeader extends StatelessWidget {
  final ChatRoom room;
  final VoidCallback onDetailsTap;

  const PinnedVehicleHeader({
    super.key,
    required this.room,
    required this.onDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.crimsonSurface,
        border: const Border(
          bottom: BorderSide(color: AppColors.crimsonPrimary, width: 1),
        ),
      ),
      child: Row(
        children: [
          VehicleTypeBadge(category: room.vehicleType, compact: true),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  room.vehicleTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.platinumText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${room.plateNumber} • ${Formatters.currency(room.unitPrice, '/ Gün')}',
                  style: AppTypography.plateCode(
                    color: AppColors.silverText,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: onDetailsTap,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              side: const BorderSide(color: AppColors.crimsonLight, width: 0.8),
            ),
            child: const Text(
              'Araç Özeti',
              style: TextStyle(color: AppColors.crimsonLight, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

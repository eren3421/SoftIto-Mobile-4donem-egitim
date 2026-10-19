import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../models/water_log.dart';

class WaterHistoryTile extends StatelessWidget {
  const WaterHistoryTile({
    required this.log,
    required this.onDelete,
    super.key,
  });

  final WaterLog log;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final timeStr =
        '${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: AppColors.neonCyan, size: 20),
          const SizedBox(width: 12),
          Text('+${log.amountMl} ml', style: context.textTheme.titleMedium),
          const Spacer(),
          Text(timeStr, style: context.textTheme.bodySmall),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.textMuted, size: 20),
            onPressed: onDelete,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

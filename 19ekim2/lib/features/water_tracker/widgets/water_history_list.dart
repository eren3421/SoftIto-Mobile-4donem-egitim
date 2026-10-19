import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/water_log_model.dart';

class WaterHistoryList extends StatelessWidget {
  final List<WaterLog> logs;

  const WaterHistoryList({
    super.key,
    required this.logs,
  });

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return _buildEmptyState(context);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bugünün Geçmişi',
          style: TextStyle(
            color: titleColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: logs.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) => _buildLogItem(context, logs[index]),
        ),
      ],
    );
  }

  Widget _buildLogItem(BuildContext context, WaterLog log) {
    final hour = log.timestamp.hour.toString().padLeft(2, '0');
    final minute = log.timestamp.minute.toString().padLeft(2, '0');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurfaceCard : AppColors.lightSurfaceCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final lime = isDark ? AppColors.neonLimeBright : AppColors.neonLime;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_rounded, color: lime, size: 20),
              const SizedBox(width: 12),
              Text(
                '${log.amountMl} ml Su',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Text(
            '$hour:$minute',
            style: TextStyle(color: subColor, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    return Container(
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      child: Text(
        'Henüz su kaydı bulunmuyor.',
        style: TextStyle(color: mutedColor, fontSize: 14),
      ),
    );
  }
}

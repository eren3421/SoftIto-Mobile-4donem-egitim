import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/topic.dart';

class TopicItemTile extends StatelessWidget {
  final Topic topic;
  final int status;
  final Color courseColor;
  final ValueChanged<int> onStatusChanged;

  const TopicItemTile({
    super.key,
    required this.topic,
    required this.status,
    required this.courseColor,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(status);
    final statusLabel = _getStatusLabel(status);
    final statusIcon = _getStatusIcon(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: status == AppConstants.statusCompleted
              ? AppColors.completed.withValues(alpha: 0.3)
              : (theme.brightness == Brightness.dark
                  ? const Color(0xFF334155)
                  : const Color(0xFFE2E8F0)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 38,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decoration: status == AppConstants.statusCompleted
                        ? TextDecoration.none
                        : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<int>(
            initialValue: status,
            onSelected: onStatusChanged,
            tooltip: 'Durumu Değiştir',
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            itemBuilder: (context) => [
              _buildMenuItem(
                value: AppConstants.statusNotStarted,
                title: 'Çalışılmadı',
                icon: Icons.circle_outlined,
                color: AppColors.notStarted,
              ),
              _buildMenuItem(
                value: AppConstants.statusNeedsReview,
                title: 'Tekrar Edilecek',
                icon: Icons.sync,
                color: AppColors.needsReview,
              ),
              _buildMenuItem(
                value: AppConstants.statusCompleted,
                title: 'Bitirdim',
                icon: Icons.check_circle,
                color: AppColors.completed,
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, color: statusColor, size: 16),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<int> _buildMenuItem({
    required int value,
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return PopupMenuItem<int>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case AppConstants.statusCompleted:
        return AppColors.completed;
      case AppConstants.statusNeedsReview:
        return AppColors.needsReview;
      default:
        return AppColors.notStarted;
    }
  }

  String _getStatusLabel(int status) {
    switch (status) {
      case AppConstants.statusCompleted:
        return 'Bitirildi';
      case AppConstants.statusNeedsReview:
        return 'Tekrar Edilecek';
      default:
        return 'Çalışılmadı';
    }
  }

  IconData _getStatusIcon(int status) {
    switch (status) {
      case AppConstants.statusCompleted:
        return Icons.check_circle;
      case AppConstants.statusNeedsReview:
        return Icons.sync;
      default:
        return Icons.radio_button_unchecked;
    }
  }
}

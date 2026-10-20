import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/kisi_model.dart';

/// Daha önce yapılmış video toplantı tutanak ve inceleme kartı.
class MeetingRecordCard extends StatelessWidget {
  final MeetingRecordModel record;
  final VoidCallback onDelete;

  const MeetingRecordCard({
    super.key,
    required this.record,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 8),
            Text(record.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Katılımcılar: ${record.participants}', style: theme.textTheme.bodySmall),
            const Divider(height: 16),
            _buildNotesSection(theme),
            if (record.decisions.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildDecisionsSection(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final date = record.date;
    final dateStr =
        '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.video_library, size: 16, color: AppColors.meetingBlue),
            const SizedBox(width: 6),
            Text('$dateStr • ${record.durationMinutes} dk', style: theme.textTheme.labelMedium),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 18),
          onPressed: onDelete,
          tooltip: 'Kaydı Sil',
        ),
      ],
    );
  }

  Widget _buildNotesSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Görüşme Tutanak Özeti:', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(record.summaryNotes, style: theme.textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildDecisionsSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.accentGold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, size: 16, color: AppColors.accentGold),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Alınan Kararlar: ${record.decisions}',
              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/kisi_model.dart';

/// Saat ve takvim ayrıntılarını gösteren randevu kartı.
class AppointmentCard extends StatelessWidget {
  final RandevuModel randevu;
  final VoidCallback onCancel;

  const AppointmentCard({
    super.key,
    required this.randevu,
    required this.onCancel,
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
            _buildTimeAndStatusRow(theme),
            const SizedBox(height: 8),
            Text(randevu.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            _buildParticipantAndLocation(theme),
            if (randevu.note.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(randevu.note, style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
            ],
            const Divider(height: 16),
            _buildActionRow(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeAndStatusRow(ThemeData theme) {
    final date = randevu.dateTime;
    final timeStr =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    final dateStr =
        '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    final isCancelled = randevu.status == 'İptal';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryLeather.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              const Icon(Icons.access_time, size: 14, color: AppColors.primaryLeather),
              const SizedBox(width: 4),
              Text(
                '$dateStr - Saat: $timeStr',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryLeather),
              ),
            ],
          ),
        ),
        Chip(
          label: Text(randevu.status),
          visualDensity: VisualDensity.compact,
          labelStyle: TextStyle(
            fontSize: 11,
            color: isCancelled ? AppColors.expenseRed : AppColors.incomeGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantAndLocation(ThemeData theme) {
    return Row(
      children: [
        const Icon(Icons.person_outline, size: 15, color: AppColors.accentGold),
        const SizedBox(width: 4),
        Text(randevu.kisiName, style: theme.textTheme.bodyMedium),
        const SizedBox(width: 12),
        const Icon(Icons.link, size: 15, color: AppColors.accentGold),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            randevu.locationOrLink,
            style: theme.textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionRow(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (randevu.status != 'İptal')
          TextButton.icon(
            onPressed: onCancel,
            icon: const Icon(Icons.cancel_outlined, size: 16),
            label: const Text('Randevuyu İptal Et'),
            style: TextButton.styleFrom(foregroundColor: AppColors.expenseRed),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/kisi_model.dart';

/// Paydaş, yatırımcı ve müşteri kişi profil kartı.
class KisiCard extends StatelessWidget {
  final KisiModel kisi;
  final VoidCallback onChat;
  final VoidCallback onVideoMeeting;
  final VoidCallback onAddAppointment;
  final VoidCallback onDelete;

  const KisiCard({
    super.key,
    required this.kisi,
    required this.onChat,
    required this.onVideoMeeting,
    required this.onAddAppointment,
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
            _buildProfileRow(theme),
            const SizedBox(height: 10),
            _buildContactInfo(theme),
            const Divider(height: 20),
            _buildActionBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(ThemeData theme) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.primaryLeather.withValues(alpha: 0.15),
          child: Text(
            kisi.name.isNotEmpty ? kisi.name[0].toUpperCase() : '?',
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryLeather),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(kisi.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              Text('${kisi.role} • ${kisi.company}', style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 18),
          onPressed: onDelete,
          tooltip: 'Kişiyi Sil',
        ),
      ],
    );
  }

  Widget _buildContactInfo(ThemeData theme) {
    return Row(
      children: [
        const Icon(Icons.email_outlined, size: 14, color: AppColors.accentGold),
        const SizedBox(width: 4),
        Expanded(
          child: Text(kisi.email, style: theme.textTheme.labelSmall, overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.phone_outlined, size: 14, color: AppColors.accentGold),
        const SizedBox(width: 4),
        Text(kisi.phone, style: theme.textTheme.labelSmall),
      ],
    );
  }

  Widget _buildActionBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton.icon(
          onPressed: onChat,
          icon: const Icon(Icons.chat_bubble_outline, size: 16),
          label: const Text('Sohbet'),
          style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
        ),
        const SizedBox(width: 8),
        FilledButton.tonalIcon(
          onPressed: onVideoMeeting,
          icon: const Icon(Icons.videocam_outlined, size: 16),
          label: const Text('Toplantı'),
          style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          onPressed: onAddAppointment,
          icon: const Icon(Icons.calendar_month, size: 18),
          tooltip: 'Randevu Ayarla',
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/diary_model.dart';

/// Defter sayfalarını listeleyen kart bileşeni.
/// project.md ve SKILL.md standartlarına uygun olarak 40 satır altı build metodu ile tasarlanmıştır.
class DiaryCard extends StatelessWidget {
  final DiaryEntryModel entry;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const DiaryCard({
    super.key,
    required this.entry,
    required this.onFavoriteToggle,
    required this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardHeader(
                entry: entry,
                onFavoriteToggle: onFavoriteToggle,
                onDelete: onDelete,
              ),
              const SizedBox(height: 12),
              _CardBody(entry: entry),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final DiaryEntryModel entry;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onDelete;

  const _CardHeader({
    required this.entry,
    required this.onFavoriteToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr =
        '${entry.createdAt.day.toString().padLeft(2, '0')}.${entry.createdAt.month.toString().padLeft(2, '0')}.${entry.createdAt.year}';

    return Row(
      children: [
        Icon(Icons.calendar_today_outlined,
            size: 14, color: theme.colorScheme.primary),
        const SizedBox(width: 6),
        Text(dateStr, style: theme.textTheme.labelMedium),
        const Spacer(),
        Chip(
          label: Text(entry.mood),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
        ),
        IconButton(
          iconSize: 20,
          onPressed: onFavoriteToggle,
          icon: Icon(
            entry.isFavorite ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            color: entry.isFavorite
                ? AppColors.favoriteActive
                : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        IconButton(
          iconSize: 20,
          onPressed: onDelete,
          icon: Icon(
            Icons.delete_outline_rounded,
            color: theme.colorScheme.error.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

class _CardBody extends StatelessWidget {
  final DiaryEntryModel entry;

  const _CardBody({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          entry.title,
          style: theme.textTheme.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Text(
          entry.content,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

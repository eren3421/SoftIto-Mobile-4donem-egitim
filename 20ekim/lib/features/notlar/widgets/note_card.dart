import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/not_model.dart';

/// Klasik defter sayfası görünümünde not ve rapor kartı.
class NoteCard extends StatelessWidget {
  final NotModel note;
  final VoidCallback onToggleFavorite;
  final VoidCallback onTogglePin;
  final VoidCallback onDelete;

  const NoteCard({
    super.key,
    required this.note,
    required this.onToggleFavorite,
    required this.onTogglePin,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Stack(
        children: [
          if (note.isPinned) _buildGoldBookmark(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(theme),
                const SizedBox(height: 8),
                Text(note.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                _buildContentPreview(theme),
                const SizedBox(height: 12),
                _buildFooter(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoldBookmark() {
    return Positioned(
      top: 0,
      right: 28,
      child: Container(
        width: 12,
        height: 20,
        decoration: const BoxDecoration(
          color: AppColors.accentGold,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(3)),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final dateStr =
        '${note.createdAt.day.toString().padLeft(2, '0')}.${note.createdAt.month.toString().padLeft(2, '0')}.${note.createdAt.year}';
    return Row(
      children: [
        Chip(
          label: Text(note.category),
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
        const SizedBox(width: 8),
        Text(dateStr, style: theme.textTheme.labelSmall),
        const Spacer(),
        IconButton(
          icon: Icon(note.isPinned ? Icons.push_pin : Icons.push_pin_outlined, size: 18),
          onPressed: onTogglePin,
          tooltip: 'Başa Sabitle',
        ),
        IconButton(
          icon: Icon(note.isFavorite ? Icons.star : Icons.star_border, size: 18),
          color: note.isFavorite ? AppColors.accentGold : null,
          onPressed: onToggleFavorite,
          tooltip: 'Favorilere Ekle',
        ),
      ],
    );
  }

  Widget _buildContentPreview(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.only(left: 8),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: AppColors.paperLine, width: 2)),
      ),
      child: Text(
        note.content,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 18),
          onPressed: onDelete,
          tooltip: 'Notu Sil',
        ),
      ],
    );
  }
}

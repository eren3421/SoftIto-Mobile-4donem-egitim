import 'package:flutter/material.dart';
import '../controllers/diary_controller.dart';

/// Seçilen tarihi gösteren ve defter sayfalarını tarihe göre filtrelemeyi sağlayan üst çubuk.
class DiaryCalendarBar extends StatelessWidget {
  final DiaryController controller;
  final VoidCallback onPickDate;

  const DiaryCalendarBar({
    super.key,
    required this.controller,
    required this.onPickDate,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime?>(
      valueListenable: controller.selectedFilterDate,
      builder: (context, filterDate, _) {
        if (filterDate == null) {
          return const SizedBox.shrink();
        }
        final theme = Theme.of(context);
        final dateStr =
            '${filterDate.day.toString().padLeft(2, '0')}.${filterDate.month.toString().padLeft(2, '0')}.${filterDate.year}';

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(Icons.event_note_rounded,
                  size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text('Tarih: $dateStr', style: theme.textTheme.labelMedium),
              const Spacer(),
              TextButton(
                onPressed: onPickDate,
                child: const Text('Değiştir'),
              ),
              IconButton(
                iconSize: 18,
                visualDensity: VisualDensity.compact,
                tooltip: 'Filtreyi Kaldır',
                icon: const Icon(Icons.close_rounded),
                onPressed: () => controller.setFilterDate(null),
              ),
            ],
          ),
        );
      },
    );
  }
}

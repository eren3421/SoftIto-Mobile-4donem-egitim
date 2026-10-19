import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Kullanıcının o anki duygu durumunu seçebileceği yatay mood seçici çubuk.
class MoodSelectorBar extends StatelessWidget {
  final String selectedMood;
  final ValueChanged<String> onMoodSelected;

  static const List<({String label, IconData icon, Color color})> moods = [
    (label: 'Huzurlu', icon: Icons.spa_outlined, color: AppColors.moodPeaceful),
    (
      label: 'Mutlu',
      icon: Icons.wb_sunny_outlined,
      color: AppColors.moodHappy,
    ),
    (
      label: 'Düşünceli',
      icon: Icons.menu_book_outlined,
      color: AppColors.moodThoughtful,
    ),
    (
      label: 'Hüzünlü',
      icon: Icons.cloud_outlined,
      color: AppColors.moodSad,
    ),
    (
      label: 'Heyecanlı',
      icon: Icons.auto_awesome_outlined,
      color: AppColors.moodExcited,
    ),
  ];

  const MoodSelectorBar({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: moods.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final mood = moods[index];
          final isSelected = mood.label == selectedMood;
          return _MoodChip(
            label: mood.label,
            icon: mood.icon,
            color: mood.color,
            isSelected: isSelected,
            onTap: () => onMoodSelected(mood.label),
          );
        },
      ),
    );
  }
}

class _MoodChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = isSelected ? color : theme.colorScheme.outlineVariant;
    final bgColor = isSelected ? color.withValues(alpha: 0.18) : Colors.transparent;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? color : theme.colorScheme.onSurface),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isSelected ? color : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

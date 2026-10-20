import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Not kategorilerini filtrelemek için kullanılan kaydırılabilir çip çubuğu.
class NoteFilterBar extends StatelessWidget {
  static const List<String> categories = [
    'Tümü',
    'Rapor',
    'Yol Haritası',
    'Toplantı',
    'Fikir',
    'Genel',
  ];

  final String selectedCategory;
  final ValueChanged<String> onSelect;

  const NoteFilterBar({
    super.key,
    required this.selectedCategory,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat == selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (_) => onSelect(cat),
              selectedColor: AppColors.primaryLeather,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : null,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }
}

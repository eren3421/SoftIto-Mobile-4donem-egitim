import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class QuickReplyBar extends StatelessWidget {
  final List<String> replies;
  final ValueChanged<String> onSelect;

  const QuickReplyBar({
    super.key,
    required this.replies,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: replies.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final reply = replies[index];
          return ActionChip(
            label: Text(reply),
            labelStyle: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.silverText : AppColors.lightTextPrimary,
            ),
            backgroundColor: isDark ? AppColors.gunmetalGrey : AppColors.lightInputBg,
            side: BorderSide(
              color: isDark ? AppColors.steelBorderGrey : AppColors.lightBorder,
              width: 0.8,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            onPressed: () => onSelect(reply),
          );
        },
      ),
    );
  }
}

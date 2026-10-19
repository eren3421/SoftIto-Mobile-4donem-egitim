import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';

class WaterQuickAddButtons extends StatelessWidget {
  const WaterQuickAddButtons({
    required this.onAdd,
    super.key,
  });

  final ValueChanged<int> onAdd;

  static const List<int> _quickAmounts = [200, 330, 500, 750];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _quickAmounts.map((amount) {
        return _QuickAddButton(
          amount: amount,
          onTap: () => onAdd(amount),
        );
      }).toList(),
    );
  }
}

class _QuickAddButton extends StatelessWidget {
  const _QuickAddButton({
    required this.amount,
    required this.onTap,
  });

  final int amount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            const Icon(Icons.water_drop_outlined, color: AppColors.neonCyan, size: 22),
            const SizedBox(height: 6),
            Text('+$amount', style: context.textTheme.titleMedium),
            Text('ml', style: context.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Kaynak ve harcama kategorileri dağılım şeması kartı.
class ResourceChartCard extends StatelessWidget {
  final Map<String, double> categoryExpenseMap;
  final double totalExpense;

  const ResourceChartCard({
    super.key,
    required this.categoryExpenseMap,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (categoryExpenseMap.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 12),
            ...categoryExpenseMap.entries.map((entry) => _buildBar(context, entry.key, entry.value)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        const Icon(Icons.pie_chart_outline, size: 20, color: AppColors.accentGold),
        const SizedBox(width: 8),
        Text(
          'Kaynak Tüketim Dağılımı',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildBar(BuildContext context, String category, double amount) {
    final theme = Theme.of(context);
    final ratio = totalExpense > 0 ? (amount / totalExpense) : 0.0;
    final percent = (ratio * 100).toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(category, style: theme.textTheme.bodySmall),
              Text('₺${amount.toStringAsFixed(0)} (%$percent)', style: theme.textTheme.labelSmall),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: theme.dividerColor.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryLeather),
            ),
          ),
        ],
      ),
    );
  }
}

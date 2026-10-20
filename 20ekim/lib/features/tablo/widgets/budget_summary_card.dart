import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Bütçe ve finansal durum özet kartı.
class BudgetSummaryCard extends StatelessWidget {
  final double netBalance;
  final double totalIncome;
  final double totalExpense;
  final double usageRatio;

  const BudgetSummaryCard({
    super.key,
    required this.netBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.usageRatio,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceHeader(theme),
            const SizedBox(height: 14),
            _buildMetricsRow(theme),
            const SizedBox(height: 12),
            _buildUsageProgress(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kalan Net Sermaye', style: theme.textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(
              '₺${netBalance.toStringAsFixed(2)}',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: netBalance >= 0 ? AppColors.incomeGreen : AppColors.expenseRed,
              ),
            ),
          ],
        ),
        const Icon(Icons.account_balance_wallet, color: AppColors.accentGold, size: 32),
      ],
    );
  }

  Widget _buildMetricsRow(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _metricBox(
            label: 'Toplam Gelir',
            amount: '₺${totalIncome.toStringAsFixed(2)}',
            color: AppColors.incomeGreen,
            icon: Icons.arrow_upward,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _metricBox(
            label: 'Toplam Gider',
            amount: '₺${totalExpense.toStringAsFixed(2)}',
            color: AppColors.expenseRed,
            icon: Icons.arrow_downward,
          ),
        ),
      ],
    );
  }

  Widget _metricBox({
    required String label,
    required String amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(fontSize: 11, color: color)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageProgress(ThemeData theme) {
    final percentage = (usageRatio * 100).toInt();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Bütçe Tüketim Oranı', style: theme.textTheme.bodySmall),
            Text('%$percentage', style: theme.textTheme.labelMedium),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: usageRatio,
            minHeight: 8,
            backgroundColor: theme.dividerColor.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              usageRatio > 0.85 ? AppColors.expenseRed : AppColors.accentAmber,
            ),
          ),
        ),
      ],
    );
  }
}

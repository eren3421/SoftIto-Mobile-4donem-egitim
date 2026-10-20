import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/tablo_model.dart';

/// Finansal işlemler tablosu ve listeleme kartı.
class TransactionTableCard extends StatelessWidget {
  final List<TransactionModel> transactions;
  final ValueChanged<String> onDelete;

  const TransactionTableCard({
    super.key,
    required this.transactions,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (transactions.isEmpty) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'Henüz kayıtlı bir gelir/gider işlemi bulunmuyor.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTableHeader(theme),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) => _buildRow(context, transactions[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.table_chart_outlined, size: 18, color: AppColors.accentGold),
          const SizedBox(width: 8),
          Text(
            'Gelir / Gider Döküm Tablosu',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, TransactionModel tx) {
    final theme = Theme.of(context);
    final color = tx.isIncome ? AppColors.incomeGreen : AppColors.expenseRed;
    final sign = tx.isIncome ? '+' : '-';
    final dateStr = '${tx.date.day.toString().padLeft(2, '0')}.${tx.date.month.toString().padLeft(2, '0')}';

    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(
          tx.isIncome ? Icons.south_west : Icons.north_east,
          color: color,
          size: 16,
        ),
      ),
      title: Text(tx.title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text('${tx.category} • $dateStr', style: theme.textTheme.bodySmall),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$sign₺${tx.amount.toStringAsFixed(2)}',
            style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            onPressed: () => onDelete(tx.id),
          ),
        ],
      ),
    );
  }
}

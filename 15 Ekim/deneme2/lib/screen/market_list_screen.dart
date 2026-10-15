import 'package:flutter/material.dart';
import '../models/asset_model.dart';
import '../models/transation_model.dart';

class MarketsGridListScreen extends StatelessWidget {
  const MarketsGridListScreen({super.key});

  static const List<Asset> assets = [
    Asset(
      symbol: 'BTC',
      name: 'Bitcoin',
      price: 67420.00,
      change24h: 4.20,
      balance: 0.4,
    ),
    Asset(
      symbol: 'ETH',
      name: 'Ethereum',
      price: 3500,
      change24h: -1.80,
      balance: 4.20,
    ),
    Asset(
      symbol: 'SOL',
      name: 'Solana',
      price: 200.00,
      change24h: 0.5,
      balance: 85.00,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactions = [
      TransactionItem(
        id: 'tx_1',
        title: 'Apple Store',
        category: 'Teknoloji',
        date: DateTime(today.year, today.month, today.day, 14, 20),
        amount: 64500,
        isExpense: true,
        icon: Icons.laptop_mac,
      ),
      TransactionItem(
        id: 'tx_2',
        title: 'Kodusta Danışmanlık Hakediş',
        category: 'Kurumsal Gelir',
        date: DateTime(yesterday.year, yesterday.month, yesterday.day, 9),
        amount: 125000.00,
        isExpense: false,
        icon: Icons.account_balance,
      ),
      TransactionItem(
        id: 'tx_3',
        title: 'Apple Store',
        category: 'Teknoloji',
        date: DateTime(today.year, today.month, today.day, 14, 20),
        amount: 64500,
        isExpense: true,
        icon: Icons.laptop_mac,
      ),
      TransactionItem(
        id: 'tx_4',
        title: 'Apple Store',
        category: 'Teknoloji',
        date: DateTime(today.year, today.month, today.day, 14, 20),
        amount: 64500,
        isExpense: true,
        icon: Icons.laptop_mac,
      ),
    ]..sort((a, b) => b.date.compareTo(a.date));

    final headingStyle = Theme.of(context).textTheme.titleLarge;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Piyasalar', style: headingStyle),
          const SizedBox(height: 4),
          const Text('Örnek veriler; canlı piyasa fiyatları değildir.'),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 900
                  ? 3
                  : constraints.maxWidth >= 560
                      ? 2
                      : 1;
              final cardWidth =
                  (constraints.maxWidth - (columns - 1) * 12) / columns;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: assets
                    .map((asset) => SizedBox(
                          width: cardWidth,
                          child: _buildAssetCard(context, asset),
                        ))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 24),
          Text('Son İşlemler', style: headingStyle),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: transactions.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) =>
                _buildTransactionTile(transactions[index], today),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetCard(BuildContext context, Asset asset) {
    final isPositive = asset.change24h >= 0;
    final changeColor =
        isPositive ? Colors.green.shade700 : Colors.red.shade700;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(asset.symbol, style: Theme.of(context).textTheme.titleMedium),
            Text(asset.name),
            const SizedBox(height: 16),
            Text(
              '\$${asset.price.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: changeColor,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    '${isPositive ? '+' : ''}${asset.change24h.toStringAsFixed(2)}% (24s)',
                    style: TextStyle(color: changeColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Bakiye: ${asset.balance} ${asset.symbol}'),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTile(TransactionItem transaction, DateTime today) {
    final color =
        transaction.isExpense ? Colors.red.shade700 : Colors.green.shade700;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: CircleAvatar(
        child: Icon(transaction.icon),
      ),
      title: Text(transaction.title),
      subtitle: Text(
        '${transaction.category}\n${_formatDate(transaction.date, today)}',
      ),
      isThreeLine: true,
      trailing: Text(
        '${transaction.isExpense ? '-' : '+'}₺${transaction.amount.toStringAsFixed(2)}',
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _formatDate(DateTime date, DateTime today) {
    final day = DateTime(date.year, date.month, date.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final String label;
    if (day == today) {
      label = 'Bugün';
    } else if (day == yesterday) {
      label = 'Dün';
    } else {
      label = '${date.day.toString().padLeft(2, '0')}.'
          '${date.month.toString().padLeft(2, '0')}.${date.year}';
    }
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$label $hour:$minute';
  }
}
import 'package:flutter/material.dart';

import '../models/transation_model.dart';

class TransferFormScreen extends StatefulWidget {
  const TransferFormScreen({super.key});

  @override
  State<TransferFormScreen> createState() => _TransferFormScreenState();
}

class _TransferFormScreenState extends State<TransferFormScreen> {
  double _balance = 148950.00;
  final List<TransactionItem> _history = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _history.addAll([
      TransactionItem(
        id: 'tx_init_1',
        title: 'Ahmet Yılmaz',
        category: 'Hızlı Transfer',
        date: DateTime(now.year, now.month, now.day, 11, 30),
        amount: 1500.00,
        isExpense: true,
        icon: Icons.send_rounded,
      ),
      TransactionItem(
        id: 'tx_init_2',
        title: 'Merve Demir',
        category: 'Hızlı Transfer',
        date: DateTime(now.year, now.month, now.day - 1, 15, 45),
        amount: 2400.00,
        isExpense: true,
        icon: Icons.send_rounded,
      ),
    ]);
  }

  Future<void> _openTransferModal() async {
    final transaction = await showModalBottomSheet<TransactionItem>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _TransferForm(balance: _balance),
    );

    if (!mounted || transaction == null) return;

    setState(() {
      _balance = ((_balance - transaction.amount) * 100).round() / 100;
      _history.add(transaction);
      _history.sort((a, b) => b.date.compareTo(a.date));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Örnek transfer geçmişe eklendi.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Para Transferi',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Kullanılabilir Bakiye'),
                  const SizedBox(height: 8),
                  Text(
                    '₺${_balance.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text('Örnek veridir; gerçek para transferi yapılmaz.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _openTransferModal,
            icon: const Icon(Icons.send_rounded),
            label: const Text('Yeni Transfer'),
          ),
          const SizedBox(height: 24),
          Text('Transfer Geçmişi',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          for (final transaction in _history) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(child: Icon(transaction.icon)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(transaction.category),
                        Text(_formatDate(transaction.date)),
                        const SizedBox(height: 4),
                        Text(
                          '-₺${transaction.amount.toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final day = DateTime(date.year, date.month, date.day);
    final String label;
    if (day == today) {
      label = 'Bugün';
    } else if (day == yesterday) {
      label = 'Dün';
    } else {
      label = '${date.day.toString().padLeft(2, '0')}.'
          '${date.month.toString().padLeft(2, '0')}.${date.year}';
    }
    return '$label ${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}

class _TransferForm extends StatefulWidget {
  const _TransferForm({required this.balance});

  final double balance;

  @override
  State<_TransferForm> createState() => _TransferFormState();
}

class _TransferFormState extends State<_TransferForm> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  double? _parseAmount(String value) {
    return double.tryParse(value.trim().replaceAll(',', '.'));
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    Navigator.of(context).pop(
      TransactionItem(
        id: 'tx_${now.microsecondsSinceEpoch}',
        title: _recipientController.text.trim(),
        category: 'Hızlı Transfer',
        date: now,
        amount: _parseAmount(_amountController.text)!,
        isExpense: true,
        icon: Icons.send_rounded,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Yeni Transfer',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                    'Kullanılabilir bakiye: ₺${widget.balance.toStringAsFixed(2)}'),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _recipientController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Alıcı adı',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Alıcı adını girin.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Tutar',
                    prefixText: '₺ ',
                    hintText: '1500,00',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final text = (value ?? '').trim();
                    final amount = _parseAmount(text);
                    if (!RegExp(r'^\d+([.,]\d{1,2})?$').hasMatch(text) ||
                        amount == null ||
                        !amount.isFinite ||
                        amount <= 0) {
                      return 'En fazla iki ondalıklı, pozitif bir tutar girin.';
                    }
                    if (amount > widget.balance) {
                      return 'Yetersiz bakiye.';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Örnek Transferi Onayla'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Vazgeç'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
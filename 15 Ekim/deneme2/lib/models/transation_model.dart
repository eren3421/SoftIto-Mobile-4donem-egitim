import 'package:flutter/material.dart';

class TransactionItem {
  final String id;
  final String title;
  final String category;
  final DateTime date;
  final double amount;
  final bool isExpense;
  final IconData icon;

  const TransactionItem({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.amount,
    required this.isExpense,
    required this.icon,
  });
}
import 'package:flutter/material.dart';

class TransactionItem {
  const TransactionItem({
    required this.id,
    required this.title,
    required this.timeLabel,
    required this.category,
    required this.amount,
    required this.isIncome,
    required this.icon,
    required this.color,
  });

  final String id;
  final String title;
  final String timeLabel;
  final String category;
  final double amount;
  final bool isIncome;
  final IconData icon;
  final Color color;
}

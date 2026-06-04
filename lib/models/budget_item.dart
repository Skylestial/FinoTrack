import 'package:flutter/material.dart';

class BudgetItem {
  const BudgetItem({
    required this.id,
    required this.name,
    required this.spent,
    required this.limit,
    required this.icon,
    required this.color,
  });

  final String id;
  final String name;
  final double spent;
  final double limit;
  final IconData icon;
  final Color color;
}

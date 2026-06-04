import 'package:flutter/material.dart';

class CategoryItem {
  const CategoryItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.amount,
    required this.percent,
  });

  final String id;
  final String name;
  final IconData icon;
  final double amount;
  final double percent;
}

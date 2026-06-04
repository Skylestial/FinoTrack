import 'package:flutter/material.dart';

import '../models/transaction_item.dart';
import '../utils/formatters.dart';
import '../utils/theme_colors.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.item,
    this.onTap,
  });

  final TransactionItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final amountPrefix = item.isIncome ? '+ ' : '- ';
    final amountColor =
        item.isIncome ? ThemeColors.success : ThemeColors.textPrimary;

    final brightness = Theme.of(context).brightness;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: ThemeColors.surfaceFor(brightness),
        borderRadius: BorderRadius.circular(18),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: item.color,
              child: Icon(item.icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.timeLabel} - ${item.category}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ThemeColors.textSecondaryFor(brightness),
                        ),
                  ),
                ],
              ),
            ),
            Text(
              '$amountPrefix${formatCurrency(item.amount)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: amountColor,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, size: 18),
          ],
            ),
          ),
        ),
      ),
    );
  }
}

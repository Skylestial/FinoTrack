import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/transaction_item.dart';
import '../utils/formatters.dart';
import '../utils/theme_colors.dart';

// ---------------------------------------------------------------------------
// Filter & Sort Enums
// ---------------------------------------------------------------------------

enum _TransactionFilter { all, expenses, income }

enum _SortOption { dateNewest, dateOldest, amountHigh, amountLow }

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key, this.showBack = false});

  final bool showBack;

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  _TransactionFilter _activeFilter = _TransactionFilter.all;
  _SortOption _sortOption = _SortOption.dateNewest;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Filtering & sorting
  // -------------------------------------------------------------------------

  List<TransactionItem> get _filteredTransactions {
    var list = List<TransactionItem>.from(recentTransactions);

    // Filter by type
    if (_activeFilter == _TransactionFilter.expenses) {
      list = list.where((t) => !t.isIncome).toList();
    } else if (_activeFilter == _TransactionFilter.income) {
      list = list.where((t) => t.isIncome).toList();
    }

    // Search
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((t) =>
              t.title.toLowerCase().contains(_searchQuery) ||
              t.category.toLowerCase().contains(_searchQuery))
          .toList();
    }

    // Sort
    switch (_sortOption) {
      case _SortOption.dateNewest:
        // keep original order (newest first in mock data)
        break;
      case _SortOption.dateOldest:
        list = list.reversed.toList();
      case _SortOption.amountHigh:
        list.sort((a, b) => b.amount.compareTo(a.amount));
      case _SortOption.amountLow:
        list.sort((a, b) => a.amount.compareTo(b.amount));
    }

    return list;
  }

  // -------------------------------------------------------------------------
  // Group by time label
  // -------------------------------------------------------------------------

  Map<String, List<TransactionItem>> get _groupedTransactions {
    final result = <String, List<TransactionItem>>{};
    for (final t in _filteredTransactions) {
      result.putIfAbsent(t.timeLabel.split(',').first.trim(), () => []).add(t);
    }
    return result;
  }

  // -------------------------------------------------------------------------
  // Sort dialog
  // -------------------------------------------------------------------------

  void _showSortOptions() {
    final brightness = Theme.of(context).brightness;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ThemeColors.surfaceFor(brightness),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _SortSheet(
        current: _sortOption,
        onSelected: (opt) {
          setState(() => _sortOption = opt);
          Navigator.pop(context);
        },
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final grouped = _groupedTransactions;
    final total = _filteredTransactions.fold<double>(0, (sum, t) {
      return sum + (t.isIncome ? t.amount : -t.amount);
    });

    return Scaffold(
      backgroundColor: ThemeColors.backgroundFor(brightness),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.showBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: Text(
          'Transactions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        actions: [
          IconButton(
            onPressed: _showSortOptions,
            icon: const Icon(Icons.sort_rounded),
            tooltip: 'Sort',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              children: [
                // Search bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: ThemeColors.surfaceFor(brightness),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: ThemeColors.textSecondaryFor(brightness)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          decoration: InputDecoration(
                            hintText: 'Search transactions',
                            hintStyle: TextStyle(
                              color: ThemeColors.textSecondaryFor(brightness),
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () => _searchCtrl.clear(),
                          child: Icon(Icons.close, size: 18,
                              color: ThemeColors.textSecondaryFor(brightness)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Filter chips
                Row(
                  children: _TransactionFilter.values.map((f) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _FilterChipButton(
                        label: _filterLabel(f),
                        isSelected: _activeFilter == f,
                        onTap: () => setState(() => _activeFilter = f),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                // Summary bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: ThemeColors.surfaceFor(brightness),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_filteredTransactions.length} transactions',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: ThemeColors.textSecondaryFor(brightness),
                            ),
                      ),
                      Text(
                        '${total >= 0 ? '+' : ''}${formatCurrency(total.abs())}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: total >= 0 ? ThemeColors.success : Colors.red,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),

          // List
          Expanded(
            child: grouped.isEmpty
                ? _EmptyState(brightness: brightness)
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    children: grouped.entries.expand((entry) {
                      final sectionTotal = entry.value.fold<double>(
                        0,
                        (sum, t) => sum + (t.isIncome ? t.amount : -t.amount),
                      );
                      return [
                        _SectionHeader(
                          title: entry.key,
                          amount: formatCurrency(sectionTotal.abs()),
                          isPositive: sectionTotal >= 0,
                        ),
                        const SizedBox(height: 10),
                        ...entry.value.map((item) => _TransactionRow(item: item)),
                        const SizedBox(height: 8),
                      ];
                    }).toList(),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add new transaction')),
          );
        },
        backgroundColor: ThemeColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  String _filterLabel(_TransactionFilter f) {
    switch (f) {
      case _TransactionFilter.all:
        return 'All';
      case _TransactionFilter.expenses:
        return 'Expenses';
      case _TransactionFilter.income:
        return 'Income';
    }
  }
}

// ---------------------------------------------------------------------------
// Sort Sheet
// ---------------------------------------------------------------------------

class _SortSheet extends StatelessWidget {
  const _SortSheet({required this.current, required this.onSelected});

  final _SortOption current;
  final ValueChanged<_SortOption> onSelected;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    const options = [
      (_SortOption.dateNewest, Icons.arrow_downward_rounded, 'Date: Newest first'),
      (_SortOption.dateOldest, Icons.arrow_upward_rounded, 'Date: Oldest first'),
      (_SortOption.amountHigh, Icons.trending_up, 'Amount: Highest first'),
      (_SortOption.amountLow, Icons.trending_down, 'Amount: Lowest first'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ThemeColors.textSecondaryFor(brightness).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Sort by',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          ...options.map((opt) {
            final (value, icon, label) = opt;
            final selected = current == value;
            return GestureDetector(
              onTap: () => onSelected(value),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: selected
                      ? ThemeColors.primary.withValues(alpha: 0.1)
                      : ThemeColors.backgroundFor(brightness),
                  borderRadius: BorderRadius.circular(14),
                  border: selected
                      ? Border.all(color: ThemeColors.primary, width: 1.5)
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(icon,
                        size: 20,
                        color: selected
                            ? ThemeColors.primary
                            : ThemeColors.textSecondaryFor(brightness)),
                    const SizedBox(width: 12),
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                            color: selected ? ThemeColors.primary : null,
                          ),
                    ),
                    if (selected) ...[
                      const Spacer(),
                      const Icon(Icons.check_rounded,
                          color: ThemeColors.primary, size: 18),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter chip button
// ---------------------------------------------------------------------------

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? ThemeColors.primary
              : ThemeColors.surfaceFor(brightness),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: ThemeColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? Colors.white
                    : ThemeColors.textSecondaryFor(brightness),
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.amount,
    required this.isPositive,
  });

  final String title;
  final String amount;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        Text(
          amount,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isPositive
                    ? ThemeColors.success
                    : ThemeColors.textSecondaryFor(brightness),
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Transaction row
// ---------------------------------------------------------------------------

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.item});

  final TransactionItem item;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final prefix = item.isIncome ? '+ ' : '- ';
    final amountColor = item.isIncome ? ThemeColors.success : Colors.red.shade400;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: ThemeColors.surfaceFor(brightness),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Opened ${item.title}')),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: item.color.withValues(alpha: 0.15),
                  child: Icon(item.icon, color: item.color, size: 20),
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
                      const SizedBox(height: 3),
                      Text(
                        item.category,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: ThemeColors.textSecondaryFor(brightness),
                            ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$prefix${formatCurrency(item.amount)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: amountColor,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.timeLabel.contains(',')
                          ? item.timeLabel.split(',').last.trim()
                          : item.timeLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: ThemeColors.textSecondaryFor(brightness),
                            fontSize: 10,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.brightness});

  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 56,
            color: ThemeColors.textSecondaryFor(brightness).withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Text(
            'No transactions found',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ThemeColors.textSecondaryFor(brightness),
                ),
          ),
        ],
      ),
    );
  }
}

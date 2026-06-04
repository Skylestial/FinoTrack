import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/app/app_bloc.dart';
import '../blocs/app/app_event.dart';
import '../blocs/app/app_state.dart';
import '../models/transaction_item.dart';
import '../utils/theme_colors.dart';
import '../widgets/category_chip.dart';
import '../widgets/section_header.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/dual_fab.dart';
import 'ai_chat_screen.dart';
import 'notifications_screen.dart';
import 'transactions_screen.dart';

// Category ID → display name mapping (must match mock_data.dart)
const _categoryMap = <String, String>{
  'food': 'Food & Drinks',
  'travel': 'Travel',
  'shopping': 'Shopping',
  'bills': 'Bills',
  'entertainment': 'Entertainment',
};

class SpendSummaryScreen extends StatelessWidget {
  const SpendSummaryScreen({super.key, this.onMenuPressed});

  final VoidCallback? onMenuPressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final brightness = Theme.of(context).brightness;

        // Filter transactions by selected category
        final categoryName = _categoryMap[state.selectedCategoryId];
        final filtered = categoryName == null
            ? state.transactions
            : state.transactions
                .where((t) => t.category == categoryName)
                .toList();

        return Scaffold(
          backgroundColor: ThemeColors.backgroundFor(brightness),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Spend Summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: onMenuPressed,
            ),
            actions: [
              IconButton(
                onPressed: () {
                  context.read<AppBloc>().add(const ThemeToggled());
                },
                icon: const Icon(Icons.brightness_6_outlined),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const NotificationsScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.notifications_none),
                    ),
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF97316),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            children: [
              SummaryCard(summary: state.summary),
              const SizedBox(height: 24),

              // Categories header — "View all" goes to full transactions list
              SectionHeader(
                title: 'Categories',
                trailing: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            const TransactionsScreen(showBack: true),
                      ),
                    );
                  },
                  child: const Text('View all'),
                ),
              ),
              const SizedBox(height: 12),

              // Horizontal category chips — tap to filter transactions below
              SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: state.categories.length,
                  itemBuilder: (context, index) {
                    final category = state.categories[index];
                    return CategoryChip(
                      category: category,
                      isSelected: state.selectedCategoryId == category.id,
                      onTap: () {
                        context
                            .read<AppBloc>()
                            .add(CategorySelected(category.id));
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),

              // Transactions header — shows count for selected category
              SectionHeader(
                title: categoryName != null
                    ? '$categoryName Transactions'
                    : 'Recent Transactions',
                trailing: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            const TransactionsScreen(showBack: true),
                      ),
                    );
                  },
                  child: Text('${filtered.length} items'),
                ),
              ),
              const SizedBox(height: 12),

              // All filtered transactions
              ...filtered.map(
                (item) => TransactionTile(
                  item: item,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Opened ${item.title}')),
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: DualFab(
            onAiPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AiChatScreen(),
                ),
              );
            },
            onAddPressed: () {
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (sheetCtx) => BlocProvider.value(
                  value: context.read<AppBloc>(),
                  child: const _AddTransactionSheet(),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Add Transaction bottom sheet
// ---------------------------------------------------------------------------

class _AddTransactionSheet extends StatefulWidget {
  const _AddTransactionSheet();

  @override
  State<_AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<_AddTransactionSheet> {
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String _selectedCategory = 'Food & Drinks';
  bool _isExpense = true;

  static const _categories = [
    'Food & Drinks',
    'Travel',
    'Shopping',
    'Bills',
    'Entertainment',
    'Income',
    'Other',
  ];

  static const _categoryMeta = <String, (IconData, Color)>{
    'Food & Drinks': (Icons.local_cafe, Color(0xFF2BB673)),
    'Travel': (Icons.flight_takeoff, Color(0xFF4B5563)),
    'Shopping': (Icons.shopping_bag, Color(0xFFF59E0B)),
    'Bills': (Icons.receipt_long, Color(0xFF2563EB)),
    'Entertainment': (Icons.movie, Color(0xFF7C3AED)),
    'Income': (Icons.account_balance_wallet, Color(0xFF16A34A)),
    'Other': (Icons.category, Color(0xFF6B7280)),
  };

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    final amountText = _amountCtrl.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please enter a title.')));
      return;
    }
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid amount.')));
      return;
    }

    final meta = _categoryMeta[_selectedCategory] ??
        (Icons.category, const Color(0xFF6B7280));

    final newItem = TransactionItem(
      id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      timeLabel: 'Just now',
      category: _isExpense ? _selectedCategory : 'Income',
      amount: amount,
      isIncome: !_isExpense,
      icon: meta.$1,
      color: meta.$2,
    );

    context.read<AppBloc>().add(AddTransaction(newItem));

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('${_isExpense ? 'Expense' : 'Income'} "$title" added!'),
        backgroundColor: ThemeColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 24 + bottomInset),
      decoration: BoxDecoration(
        color: ThemeColors.surfaceFor(brightness),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ThemeColors.textSecondaryFor(brightness)
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Add Transaction',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),

          // Income / Expense toggle
          Container(
            decoration: BoxDecoration(
              color: ThemeColors.backgroundFor(brightness),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _TypeToggle(
                    label: 'Expense',
                    icon: Icons.arrow_upward_rounded,
                    isSelected: _isExpense,
                    selectedColor: Colors.red.shade400,
                    onTap: () => setState(() => _isExpense = true),
                  ),
                ),
                Expanded(
                  child: _TypeToggle(
                    label: 'Income',
                    icon: Icons.arrow_downward_rounded,
                    isSelected: !_isExpense,
                    selectedColor: ThemeColors.success,
                    onTap: () => setState(() => _isExpense = false),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Title field
          _InputField(
            controller: _titleCtrl,
            hint: 'Title  (e.g. Zomato Order)',
            icon: Icons.label_outline,
            brightness: brightness,
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 12),

          // Amount field
          _InputField(
            controller: _amountCtrl,
            hint: 'Amount (₹)',
            icon: Icons.currency_rupee_rounded,
            brightness: brightness,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),

          // Category picker (only shown for expenses)
          if (_isExpense)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: ThemeColors.backgroundFor(brightness),
                borderRadius: BorderRadius.circular(14),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  icon: const Icon(Icons.expand_more_rounded),
                  dropdownColor: ThemeColors.surfaceFor(brightness),
                  items: _categories
                      .where((c) => c != 'Income')
                      .map((c) =>
                          DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedCategory = val);
                    }
                  },
                ),
              ),
            ),
          const SizedBox(height: 24),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Add Transaction',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeToggle extends StatelessWidget {
  const _TypeToggle({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: selectedColor, width: 1.5)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 18,
                color: isSelected
                    ? selectedColor
                    : ThemeColors.textSecondaryFor(brightness)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? selectedColor
                    : ThemeColors.textSecondaryFor(brightness),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.brightness,
    required this.keyboardType,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final Brightness brightness;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: ThemeColors.backgroundFor(brightness),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

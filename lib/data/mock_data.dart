import 'package:flutter/material.dart';

import '../models/category_item.dart';
import '../models/summary_data.dart';
import '../models/transaction_item.dart';
import '../models/notification_item.dart';
import '../models/budget_item.dart';

const summaryData = SummaryData(
  monthLabel: 'May 2024',
  totalSpend: 24680,
  percentChange: 12.5,
);

const categories = <CategoryItem>[
  CategoryItem(
    id: 'food',
    name: 'Food & Drinks',
    icon: Icons.local_cafe,
    amount: 7450,
    percent: 30,
  ),
  CategoryItem(
    id: 'travel',
    name: 'Travel',
    icon: Icons.flight_takeoff,
    amount: 5860,
    percent: 24,
  ),
  CategoryItem(
    id: 'shopping',
    name: 'Shopping',
    icon: Icons.shopping_bag,
    amount: 4950,
    percent: 20,
  ),
  CategoryItem(
    id: 'bills',
    name: 'Bills',
    icon: Icons.receipt_long,
    amount: 3210,
    percent: 13,
  ),
  CategoryItem(
    id: 'entertainment',
    name: 'Entertainment',
    icon: Icons.sports_esports,
    amount: 1210,
    percent: 5,
  ),
];

final List<TransactionItem> recentTransactions = _buildTransactions();

const notifications = <NotificationItem>[
  NotificationItem(
    id: 'n1',
    title: 'Spending Alert',
    message: 'Food & Drinks is 30% of your total spend this month.',
    timeLabel: 'Just now',
    icon: Icons.auto_graph,
    color: Color(0xFF7C3AED),
    isUnread: true,
  ),
  NotificationItem(
    id: 'n2',
    title: 'Budget Update',
    message: 'You have 20% left in your Travel budget for May.',
    timeLabel: '2h ago',
    icon: Icons.travel_explore,
    color: Color(0xFF4F46E5),
  ),
  NotificationItem(
    id: 'n3',
    title: 'Payment Reminder',
    message: 'Electricity bill due tomorrow. Pay to avoid late fees.',
    timeLabel: 'Yesterday',
    icon: Icons.bolt,
    color: Color(0xFFF59E0B),
    isUnread: true,
  ),
  NotificationItem(
    id: 'n4',
    title: 'Income Received',
    message: 'Salary credited: \u20B945,000.',
    timeLabel: '20 May',
    icon: Icons.account_balance_wallet,
    color: Color(0xFF16A34A),
  ),
];

const budgetItems = <BudgetItem>[
  BudgetItem(
    id: 'food',
    name: 'Food & Drinks',
    spent: 7450,
    limit: 10000,
    icon: Icons.local_cafe,
    color: Color(0xFFFFB266),
  ),
  BudgetItem(
    id: 'travel',
    name: 'Travel',
    spent: 5860,
    limit: 8000,
    icon: Icons.flight_takeoff,
    color: Color(0xFF8C8CFF),
  ),
  BudgetItem(
    id: 'shopping',
    name: 'Shopping',
    spent: 4950,
    limit: 7000,
    icon: Icons.shopping_bag,
    color: Color(0xFFFF7BBF),
  ),
  BudgetItem(
    id: 'bills',
    name: 'Bills',
    spent: 3210,
    limit: 5000,
    icon: Icons.receipt_long,
    color: Color(0xFF6FC5FF),
  ),
  BudgetItem(
    id: 'entertainment',
    name: 'Entertainment',
    spent: 1210,
    limit: 3000,
    icon: Icons.sports_esports,
    color: Color(0xFF6BE3C1),
  ),
];

List<TransactionItem> _buildTransactions() {
  const base = <TransactionItem>[
    TransactionItem(
      id: 't1',
      title: 'Starbucks Coffee',
      timeLabel: 'Today, 8:45 AM',
      category: 'Food & Drinks',
      amount: 320,
      isIncome: false,
      icon: Icons.local_cafe,
      color: Color(0xFF2BB673),
    ),
    TransactionItem(
      id: 't2',
      title: 'Uber Ride',
      timeLabel: 'Today, 7:30 AM',
      category: 'Travel',
      amount: 780,
      isIncome: false,
      icon: Icons.directions_car,
      color: Color(0xFF111827),
    ),
    TransactionItem(
      id: 't3',
      title: 'Zomato Order',
      timeLabel: 'Yesterday, 9:15 PM',
      category: 'Food & Drinks',
      amount: 450,
      isIncome: false,
      icon: Icons.restaurant,
      color: Color(0xFFE11D48),
    ),
    TransactionItem(
      id: 't4',
      title: 'Amazon Shopping',
      timeLabel: 'Yesterday, 6:20 PM',
      category: 'Shopping',
      amount: 1290,
      isIncome: false,
      icon: Icons.shopping_cart,
      color: Color(0xFFF59E0B),
    ),
    TransactionItem(
      id: 't5',
      title: 'Electricity Bill',
      timeLabel: 'Yesterday, 11:30 AM',
      category: 'Bills',
      amount: 1150,
      isIncome: false,
      icon: Icons.bolt,
      color: Color(0xFF2563EB),
    ),
    TransactionItem(
      id: 't6',
      title: 'Metro Card Recharge',
      timeLabel: '21 May 2024',
      category: 'Travel',
      amount: 200,
      isIncome: false,
      icon: Icons.train,
      color: Color(0xFF4B5563),
    ),
    TransactionItem(
      id: 't7',
      title: 'Salary',
      timeLabel: '20 May 2024',
      category: 'Income',
      amount: 45000,
      isIncome: true,
      icon: Icons.account_balance_wallet,
      color: Color(0xFF16A34A),
    ),
    TransactionItem(
      id: 't8',
      title: 'Cafe Mocha',
      timeLabel: '20 May 2024',
      category: 'Food & Drinks',
      amount: 260,
      isIncome: false,
      icon: Icons.local_cafe,
      color: Color(0xFF22C55E),
    ),
    TransactionItem(
      id: 't9',
      title: 'Movie Tickets',
      timeLabel: '19 May 2024',
      category: 'Entertainment',
      amount: 980,
      isIncome: false,
      icon: Icons.movie,
      color: Color(0xFF7C3AED),
    ),
    TransactionItem(
      id: 't10',
      title: 'Grocery Run',
      timeLabel: '18 May 2024',
      category: 'Food & Drinks',
      amount: 1230,
      isIncome: false,
      icon: Icons.local_grocery_store,
      color: Color(0xFF0EA5E9),
    ),
  ];

  return List<TransactionItem>.generate(57, (index) {
    final item = base[index % base.length];
    return TransactionItem(
      id: 'tx-$index',
      title: item.title,
      timeLabel: item.timeLabel,
      category: item.category,
      amount: item.amount,
      isIncome: item.isIncome,
      icon: item.icon,
      color: item.color,
    );
  });
}

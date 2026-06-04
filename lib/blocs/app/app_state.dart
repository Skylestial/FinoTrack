import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../models/category_item.dart';
import '../../models/summary_data.dart';
import '../../models/transaction_item.dart';

class AppState extends Equatable {
  const AppState({
    required this.summary,
    required this.categories,
    required this.transactions,
    required this.selectedCategoryId,
    required this.selectedTab,
    required this.themeMode,
  });

  final SummaryData summary;
  final List<CategoryItem> categories;
  final List<TransactionItem> transactions;
  final String selectedCategoryId;
  final int selectedTab;
  final ThemeMode themeMode;

  AppState copyWith({
    SummaryData? summary,
    List<CategoryItem>? categories,
    List<TransactionItem>? transactions,
    String? selectedCategoryId,
    int? selectedTab,
    ThemeMode? themeMode,
  }) {
    return AppState(
      summary: summary ?? this.summary,
      categories: categories ?? this.categories,
      transactions: transactions ?? this.transactions,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      selectedTab: selectedTab ?? this.selectedTab,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  List<Object?> get props => [
        summary,
        categories,
        transactions,
        selectedCategoryId,
        selectedTab,
        themeMode,
      ];
}

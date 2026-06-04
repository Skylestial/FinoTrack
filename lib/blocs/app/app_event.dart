import 'package:equatable/equatable.dart';

import '../../models/transaction_item.dart';

abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AppEvent {
  const AppStarted();
}

class CategorySelected extends AppEvent {
  const CategorySelected(this.categoryId);

  final String categoryId;

  @override
  List<Object?> get props => [categoryId];
}

class ThemeToggled extends AppEvent {
  const ThemeToggled();
}

class TabSelected extends AppEvent {
  const TabSelected(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

class AddTransaction extends AppEvent {
  const AddTransaction(this.item);

  final TransactionItem item;

  @override
  List<Object?> get props => [item];
}

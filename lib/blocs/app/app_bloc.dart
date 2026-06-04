import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/mock_data.dart';
import 'app_event.dart';
import 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc()
      : super(
          AppState(
            summary: summaryData,
            categories: categories,
            transactions: recentTransactions,
            selectedCategoryId: categories.first.id,
            selectedTab: 0,
            themeMode: ThemeMode.light,
          ),
        ) {
    on<AppStarted>((event, emit) {
      emit(state);
    });

    on<CategorySelected>((event, emit) {
      emit(state.copyWith(selectedCategoryId: event.categoryId));
    });

    on<ThemeToggled>((event, emit) {
      final nextMode =
          state.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
      emit(state.copyWith(themeMode: nextMode));
    });

    on<TabSelected>((event, emit) {
      emit(state.copyWith(selectedTab: event.index));
    });

    on<AddTransaction>((event, emit) {
      final updated = [event.item, ...state.transactions];
      emit(state.copyWith(transactions: updated));
    });
  }
}

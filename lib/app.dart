import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/app/app_bloc.dart';
import 'blocs/app/app_event.dart';
import 'blocs/app/app_state.dart';
import 'screens/home_shell.dart';
import 'theme/app_theme.dart';
import 'utils/app_constants.dart';

class FinoTrackApp extends StatelessWidget {
  const FinoTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppBloc()..add(const AppStarted()),
      child: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          return MaterialApp(
            title: appTitle,
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: state.themeMode,
            debugShowCheckedModeBanner: false,
            home: const HomeShell(),
          );
        },
      ),
    );
  }
}

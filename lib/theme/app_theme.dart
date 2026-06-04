import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/theme_colors.dart';

class AppTheme {
  static ThemeData lightTheme() {
    final base = ThemeData.light();
    return base.copyWith(
      scaffoldBackgroundColor: ThemeColors.background,
      textTheme: GoogleFonts.manropeTextTheme(base.textTheme).apply(
        bodyColor: ThemeColors.textPrimary,
        displayColor: ThemeColors.textPrimary,
      ),
      colorScheme: base.colorScheme.copyWith(
        primary: ThemeColors.primary,
        secondary: ThemeColors.primaryDark,
        surface: ThemeColors.card,
      ),
    );
  }

  static ThemeData darkTheme() {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: ThemeColors.darkBackground,
      textTheme: GoogleFonts.manropeTextTheme(base.textTheme).apply(
        bodyColor: ThemeColors.darkTextPrimary,
        displayColor: ThemeColors.darkTextPrimary,
      ),
      colorScheme: base.colorScheme.copyWith(
        primary: ThemeColors.primary,
        secondary: ThemeColors.primaryDark,
        surface: ThemeColors.darkCard,
      ),
    );
  }
}

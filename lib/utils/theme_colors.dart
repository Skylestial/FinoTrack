import 'package:flutter/material.dart';

class ThemeColors {
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryDark = Color(0xFF4C3BCF);
  static const Color background = Color(0xFFF5F3FF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);
  static const Color success = Color(0xFF16A34A);
  static const Color darkBackground = Color(0xFF111827);
  static const Color darkCard = Color(0xFF1F2937);
  static const Color darkSurface = Color(0xFF0F172A);
  static const Color darkTextPrimary = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);

  static Color surfaceFor(Brightness brightness) {
    return brightness == Brightness.dark ? darkCard : card;
  }

  static Color backgroundFor(Brightness brightness) {
    return brightness == Brightness.dark ? darkBackground : background;
  }

  static Color textSecondaryFor(Brightness brightness) {
    return brightness == Brightness.dark ? darkTextSecondary : textSecondary;
  }
}

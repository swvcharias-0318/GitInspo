import 'package:flutter/material.dart';

class AppTheme {
  static const coral = Color(0xFFE25143);
  static const ink = Color(0xFF242421);
  static const paper = Color(0xFFFCFBF8);
  static const muted = Color(0xFF85847F);

  static final light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: paper,
    colorScheme: ColorScheme.fromSeed(
      seedColor: coral,
      primary: coral,
      surface: paper,
      onSurface: ink,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: paper,
      foregroundColor: ink,
      elevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF2F0EB),
      hintStyle: const TextStyle(color: muted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: coral, width: 1.4),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, color: ink, height: 1.05),
      headlineMedium: TextStyle(fontSize: 27, fontWeight: FontWeight.w700, color: ink),
      titleLarge: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: ink),
      titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: ink),
      bodyMedium: TextStyle(fontSize: 14, color: ink, height: 1.4),
      bodySmall: TextStyle(fontSize: 12, color: muted),
    ),
  );
}
import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF5A004D);
  static const primaryDark = Color(0xFF3F0038);
  static const green = Color(0xFF43C900);
  static const orange = Color(0xFFFF6B2C);
  static const sky = Color(0xFFEFFAFF);
  static const bg = Color(0xFFF6FAF9);
  static const card = Color(0xFFFFFFFF);
  static const text = Color(0xFF343941);
  static const muted = Color(0xFF7B818B);
  static const line = Color(0xFFE6EBF0);
}

class AppText {
  static const h1 = TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.text, height: 1.1);
  static const h2 = TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.text);
  static const h3 = TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.text);
  static const body = TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.text);
  static const small = TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: AppColors.muted);
}

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, primary: AppColors.primary, secondary: AppColors.green),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.primary,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.text),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.card,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(color: Color(0xFF9BA1AA), fontSize: 13),
        labelStyle: const TextStyle(color: AppColors.muted, fontSize: 12.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: AppColors.line)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: AppColors.primary, width: 1.4)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          elevation: 0,
          backgroundColor: AppColors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: .2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 70,
        elevation: 5,
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primary.withAlpha(20),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(color: states.contains(WidgetState.selected) ? AppColors.primary : AppColors.muted)),
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: states.contains(WidgetState.selected) ? AppColors.primary : AppColors.muted)),
      ),
    );
  }
}

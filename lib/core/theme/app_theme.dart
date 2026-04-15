import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  // ─── 다크 테마 (기본) ───
  static ThemeData get dark => _buildTheme(
    brightness: Brightness.dark,
    bg: AppColors.bgDark,
    surface: AppColors.bgSurface,
    card: AppColors.bgCard,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
  );

  // ─── 라이트 테마 ───
  static ThemeData get light => _buildTheme(
    brightness: Brightness.light,
    bg: const Color(0xFFF8F9FA),
    surface: const Color(0xFFFFFFFF),
    card: const Color(0xFFFFFFFF),
    textPrimary: const Color(0xFF1A1A2E),
    textSecondary: const Color(0xFF6B7280),
  );

  // ─── 미드나잇 테마 ───
  static ThemeData get midnight => _buildTheme(
    brightness: Brightness.dark,
    bg: const Color(0xFF0D1117),
    surface: const Color(0xFF161B22),
    card: const Color(0xFF21262D),
    textPrimary: const Color(0xFFC9D1D9),
    textSecondary: const Color(0xFF8B949E),
  );

  // ─── 포레스트 테마 ───
  static ThemeData get forest => _buildTheme(
    brightness: Brightness.dark,
    bg: const Color(0xFF1A2E1A),
    surface: const Color(0xFF243524),
    card: const Color(0xFF2D3F2D),
    textPrimary: const Color(0xFFD4E8D4),
    textSecondary: const Color(0xFF8FA88F),
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color bg,
    required Color surface,
    required Color card,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final isLight = brightness == Brightness.light;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: surface,
        error: AppColors.scoreMiss,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: isLight ? 1 : 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isLight ? const Color(0xFFD1D5DB) : const Color(0xFF30363D)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isLight ? const Color(0xFFD1D5DB) : const Color(0xFF30363D)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: TextStyle(color: textSecondary),
        hintStyle: TextStyle(color: textSecondary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(color: textPrimary, fontSize: 28, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
        labelLarge: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
      ),
      dividerColor: isLight ? const Color(0xFFE5E7EB) : const Color(0xFF30363D),
      dialogBackgroundColor: card,
      snackBarTheme: SnackBarThemeData(
        backgroundColor: card,
        contentTextStyle: TextStyle(color: textPrimary),
      ),
    );
  }
}

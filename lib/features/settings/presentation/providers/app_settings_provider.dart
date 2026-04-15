import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── 테마 ───
enum AppThemeMode { dark, light, midnight, forest }

extension AppThemeModeExt on AppThemeMode {
  String get label {
    switch (this) {
      case AppThemeMode.dark: return '다크 (기본)';
      case AppThemeMode.light: return '라이트';
      case AppThemeMode.midnight: return '미드나잇';
      case AppThemeMode.forest: return '포레스트';
    }
  }
  Color get previewColor {
    switch (this) {
      case AppThemeMode.dark: return const Color(0xFF1E1E2E);
      case AppThemeMode.light: return const Color(0xFFF5F5F5);
      case AppThemeMode.midnight: return const Color(0xFF0D1117);
      case AppThemeMode.forest: return const Color(0xFF1A2E1A);
    }
  }
}

// ─── 글꼴 ───
enum AppFont { system, serif, mono }

extension AppFontExt on AppFont {
  String get label {
    switch (this) {
      case AppFont.system: return '기본 글꼴';
      case AppFont.serif: return '세리프';
      case AppFont.mono: return '고정폭';
    }
  }
  String? get fontFamily {
    switch (this) {
      case AppFont.system: return null;
      case AppFont.serif: return 'serif';
      case AppFont.mono: return 'monospace';
    }
  }
}

// ─── 악보 스타일 ───
enum SheetStyle { standard, colorful, minimal }

extension SheetStyleExt on SheetStyle {
  String get label {
    switch (this) {
      case SheetStyle.standard: return '표준';
      case SheetStyle.colorful: return '컬러풀';
      case SheetStyle.minimal: return '미니멀';
    }
  }
  String get description {
    switch (this) {
      case SheetStyle.standard: return '기본 흑백 악보';
      case SheetStyle.colorful: return '음표마다 다른 색상';
      case SheetStyle.minimal: return '선 최소화, 깔끔한 표시';
    }
  }
}

// ─── Providers ───
final appThemeModeProvider = StateProvider<AppThemeMode>((ref) => AppThemeMode.dark);
final appFontProvider = StateProvider<AppFont>((ref) => AppFont.system);
final sheetStyleProvider = StateProvider<SheetStyle>((ref) => SheetStyle.standard);

// ─── 설정 저장/로드 ───
class AppSettingsService {
  static Future<void> load(WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString('app_theme') ?? 'dark';
    final font = prefs.getString('app_font') ?? 'system';
    final sheet = prefs.getString('sheet_style') ?? 'standard';

    ref.read(appThemeModeProvider.notifier).state =
        AppThemeMode.values.firstWhere((e) => e.name == theme, orElse: () => AppThemeMode.dark);
    ref.read(appFontProvider.notifier).state =
        AppFont.values.firstWhere((e) => e.name == font, orElse: () => AppFont.system);
    ref.read(sheetStyleProvider.notifier).state =
        SheetStyle.values.firstWhere((e) => e.name == sheet, orElse: () => SheetStyle.standard);
  }

  static Future<void> saveTheme(AppThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_theme', mode.name);
  }

  static Future<void> saveFont(AppFont font) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_font', font.name);
  }

  static Future<void> saveSheetStyle(SheetStyle style) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sheet_style', style.name);
  }
}

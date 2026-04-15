import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── 테마 독립 상수 (항상 동일) ───
  static const Color primary = Color(0xFF6C63FF);
  static const Color accent = Color(0xFF00BFA5);
  static const Color scorePerfect = Color(0xFF3FB950);
  static const Color scoreMiss = Color(0xFFF85149);
  static const Color accentGold = Color(0xFFFFD700);

  static const Map<String, Color> instrumentColors = {
    'piano': Color(0xFF6C63FF),
    'guitar': Color(0xFF3FB950),
    'drums': Color(0xFFFF6B6B),
    'bass': Color(0xFFFFB347),
    'violin': Color(0xFF87CEEB),
    'all': Color(0xFF00BFA5),
  };

  // ─── 테마 가변 색상 (활성 테마에 따라 변경됨) ───
  static Color bgDark = const Color(0xFF0D1117);
  static Color bgSurface = const Color(0xFF161B22);
  static Color bgCard = const Color(0xFF21262D);
  static Color textPrimary = const Color(0xFFE6EDF3);
  static Color textSecondary = const Color(0xFF8B949E);

  /// 테마 변경 시 호출 — 모든 위젯이 자동 반영
  static void applyDark() {
    bgDark = const Color(0xFF0D1117);
    bgSurface = const Color(0xFF161B22);
    bgCard = const Color(0xFF21262D);
    textPrimary = const Color(0xFFE6EDF3);
    textSecondary = const Color(0xFF8B949E);
  }

  static void applyLight() {
    bgDark = const Color(0xFFF8F9FA);
    bgSurface = const Color(0xFFFFFFFF);
    bgCard = const Color(0xFFFFFFFF);
    textPrimary = const Color(0xFF1A1A2E);
    textSecondary = const Color(0xFF6B7280);
  }

  static void applyMidnight() {
    bgDark = const Color(0xFF0D1117);
    bgSurface = const Color(0xFF161B22);
    bgCard = const Color(0xFF21262D);
    textPrimary = const Color(0xFFC9D1D9);
    textSecondary = const Color(0xFF8B949E);
  }

  static void applyForest() {
    bgDark = const Color(0xFF1A2E1A);
    bgSurface = const Color(0xFF243524);
    bgCard = const Color(0xFF2D3F2D);
    textPrimary = const Color(0xFFD4E8D4);
    textSecondary = const Color(0xFF8FA88F);
  }
}

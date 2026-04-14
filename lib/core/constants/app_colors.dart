import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF6C63FF);
  static const Color accent = Color(0xFF00BFA5);
  static const Color bgDark = Color(0xFF0D1117);
  static const Color bgSurface = Color(0xFF161B22);
  static const Color bgCard = Color(0xFF21262D);
  static const Color textPrimary = Color(0xFFE6EDF3);
  static const Color textSecondary = Color(0xFF8B949E);
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
}

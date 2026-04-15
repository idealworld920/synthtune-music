import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// 정식 SynthTune Music 로고 위젯
/// 보라→청록 그라데이션 + 흰 음표 + AI 회로 점
class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 100});

  @override
  Widget build(BuildContext context) {
    final radius = size * 0.28;
    final noteSize = size * 0.45;
    final dotSize = size * 0.06;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: size * 0.2,
            offset: Offset(0, size * 0.06),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 음표 아이콘
          Icon(Icons.music_note_rounded, color: Colors.white, size: noteSize),

          // AI 회로 점 (좌상)
          Positioned(
            top: size * 0.18,
            left: size * 0.15,
            child: _Dot(dotSize, const Color(0xFFFFD700)),
          ),
          // AI 회로 점 (우하)
          Positioned(
            bottom: size * 0.18,
            right: size * 0.15,
            child: _Dot(dotSize, const Color(0xFFFFD700)),
          ),
          // AI 회로 점 (우상)
          Positioned(
            top: size * 0.22,
            right: size * 0.2,
            child: _Dot(dotSize * 0.7, Colors.white.withValues(alpha: 0.6)),
          ),
          // AI 회로 점 (좌하)
          Positioned(
            bottom: size * 0.22,
            left: size * 0.2,
            child: _Dot(dotSize * 0.7, Colors.white.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final double size;
  final Color color;
  const _Dot(this.size, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

/// 작은 로고 (AppBar용, 32~40px)
class AppLogoSmall extends StatelessWidget {
  final double size;
  const AppLogoSmall({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return AppLogo(size: size);
  }
}

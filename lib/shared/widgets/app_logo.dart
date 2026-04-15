import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// 정식 SynthTune Music 로고 — Android 앱 아이콘과 동일한 디자인
class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 100});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7B6FFF), Color(0xFF4ECDC4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: size * 0.18,
            offset: Offset(0, size * 0.05),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.26),
        child: CustomPaint(
          painter: _LogoPainter(),
          size: Size(size, size),
        ),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 108; // 기준: 108dp viewBox

    // ─── 음표 머리 (타원) ───
    final notePaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    canvas.save();
    canvas.translate(56 * s, 62 * s);
    canvas.rotate(-0.15);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 22 * s, height: 16 * s), notePaint);
    canvas.restore();

    // ─── 음표 줄기 ───
    canvas.drawRect(Rect.fromLTWH(64 * s, 32 * s, 3 * s, 30 * s), notePaint);

    // ─── 음표 깃발 ───
    final flagPath = Path()
      ..moveTo(67 * s, 32 * s)
      ..quadraticBezierTo(78 * s, 38 * s, 67 * s, 48 * s)
      ..lineTo(64 * s, 46 * s)
      ..quadraticBezierTo(73 * s, 38 * s, 64 * s, 34 * s)
      ..close();
    canvas.drawPath(flagPath, notePaint);

    // ─── AI 회로 선 1 (좌상 → 음표) ───
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..strokeWidth = 1.5 * s
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(36 * s, 42 * s), Offset(46 * s, 52 * s), linePaint);

    // ─── AI 회로 선 2 (음표 → 우하) ───
    canvas.drawLine(Offset(66 * s, 68 * s), Offset(72 * s, 72 * s), linePaint);

    // ─── AI 회로 점 1 (좌상, 금색) ───
    final goldPaint = Paint()..color = const Color(0xFFFFD700);
    canvas.drawCircle(Offset(32 * s, 42 * s), 4.5 * s, goldPaint);

    // ─── AI 회로 점 2 (우하, 금색) ───
    canvas.drawCircle(Offset(76 * s, 72 * s), 4.5 * s, goldPaint);

    // ─── AI 회로 점 3 (우상, 청록) ───
    final tealPaint = Paint()..color = const Color(0xFF00BFA5);
    canvas.drawCircle(Offset(74 * s, 38 * s), 3.5 * s, tealPaint);

    // ─── AI 회로 점 4 (좌하, 청록) ───
    canvas.drawCircle(Offset(36 * s, 74 * s), 3.5 * s, tealPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// AppBar용 작은 로고
class AppLogoSmall extends StatelessWidget {
  final double size;
  const AppLogoSmall({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return AppLogo(size: size);
  }
}

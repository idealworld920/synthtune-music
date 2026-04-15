import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../features/lesson/domain/models/lesson.dart';

/// 악보 표시 위젯
/// - 5선보 위에 음표를 렌더링
/// - 현재 연주 중인 음표를 하이라이트
/// - 히트/미스 결과 표시 가능
class SheetMusicWidget extends StatelessWidget {
  final List<MusicNote> notes;
  final int? activeNoteIndex;
  final List<bool>? hitResults; // 각 음표 히트 여부 (피드백용)
  final bool showLabels;
  final double height;
  final String? instrument;

  const SheetMusicWidget({
    super.key,
    required this.notes,
    this.activeNoteIndex,
    this.hitResults,
    this.showLabels = true,
    this.height = 180,
    this.instrument,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height == 180 ? null : height,  // 기본값이면 부모에 맞춤
      constraints: height == 180 ? const BoxConstraints(minHeight: 120) : null,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bgSurface, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: CustomPaint(
          painter: _SheetMusicPainter(
            notes: notes,
            activeNoteIndex: activeNoteIndex,
            hitResults: hitResults,
            showLabels: showLabels,
            isDrum: instrument == 'drums',
          ),
        ),
      ),
    );
  }
}

class _SheetMusicPainter extends CustomPainter {
  final List<MusicNote> notes;
  final int? activeNoteIndex;
  final List<bool>? hitResults;
  final bool showLabels;
  final bool isDrum;

  _SheetMusicPainter({
    required this.notes,
    this.activeNoteIndex,
    this.hitResults,
    required this.showLabels,
    this.isDrum = false,
  });

  // 음이름 → 5선보 위치 (0 = 가운데 B4)
  // 양수 = 위, 음수 = 아래
  static int _noteToStaffPos(String noteName) {
    final clean = noteName.replaceAll(RegExp(r'[#b♯♭]'), '');
    final letter = clean.isNotEmpty ? clean[0].toUpperCase() : 'C';
    final octave = int.tryParse(clean.length > 1 ? clean.substring(clean.length - 1) : '4') ?? 4;

    // C=0, D=1, E=2, F=3, G=4, A=5, B=6
    const noteOrder = {'C': 0, 'D': 1, 'E': 2, 'F': 3, 'G': 4, 'A': 5, 'B': 6};
    final base = noteOrder[letter] ?? 0;

    // 기준: C4 = -6 (아래 보조선)
    // E4 = -4 (첫번째 선)
    // F4 = -3
    // G4 = -2 (두번째 선)
    // A4 = -1
    // B4 =  0 (세번째 선)
    // C5 =  1
    // D5 =  2 (네번째 선)
    // E5 =  3
    // F5 =  4 (다섯번째 선)
    return base + (octave - 4) * 7 - 6;
  }

  // 드럼 음표 위치
  static int _drumToStaffPos(String noteName) {
    switch (noteName) {
      case '킥': return -4;     // 첫번째 선 아래
      case '스네어': return 0;  // 가운데
      case '하이햇': return 4;  // 다섯번째 선
      default: return 0;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (notes.isEmpty) return;

    final lineSpacing = size.height / 12;  // 선 간격
    final staffTop = size.height * 0.2;
    final staffBottom = staffTop + lineSpacing * 4;
    final staffMid = (staffTop + staffBottom) / 2;

    // ─── 5선보 그리기 ───
    final linePaint = Paint()
      ..color = AppColors.textSecondary.withValues(alpha: 0.3)
      ..strokeWidth = 1.2;

    for (int i = 0; i < 5; i++) {
      final y = staffTop + i * lineSpacing;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    // ─── 높은음자리표 표시 (단순화) ───
    final clefPaint = TextPainter(
      text: TextSpan(
        text: isDrum ? '𝄥' : '𝄞',
        style: TextStyle(
          fontSize: lineSpacing * 4.5,
          color: AppColors.textSecondary.withValues(alpha: 0.5),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    clefPaint.paint(canvas, Offset(4, staffTop - lineSpacing * 0.8));

    // ─── 음표 그리기 ───
    final leftMargin = lineSpacing * 4.5;
    final usableWidth = size.width - leftMargin - 16;
    final noteSpacing = notes.length > 1
        ? usableWidth / notes.length
        : usableWidth / 2;

    for (int i = 0; i < notes.length; i++) {
      final note = notes[i];
      final x = leftMargin + noteSpacing * i + noteSpacing * 0.5;
      final staffPos = isDrum
          ? _drumToStaffPos(note.noteName)
          : _noteToStaffPos(note.noteName);

      // staffPos 0 = 세번째 선 (B4)
      // 한 단위 = 반 lineSpacing
      final halfStep = lineSpacing / 2;
      final y = staffMid - staffPos * halfStep;

      // 색상 결정
      Color noteColor;
      if (hitResults != null && i < hitResults!.length) {
        noteColor = hitResults![i] ? AppColors.scorePerfect : const Color(0xFFE07070);
      } else if (activeNoteIndex != null && i == activeNoteIndex) {
        noteColor = AppColors.accent;
      } else if (activeNoteIndex != null && i < activeNoteIndex!) {
        noteColor = AppColors.textSecondary.withValues(alpha: 0.5);
      } else {
        noteColor = AppColors.textPrimary;
      }

      final isActive = activeNoteIndex != null && i == activeNoteIndex;

      // 음표 머리 크기
      final noteRadius = lineSpacing * 0.38;
      final isHalfOrWhole = note.duration >= 1.2;

      // 활성 음표 배경 하이라이트
      if (isActive) {
        final glowPaint = Paint()
          ..color = AppColors.accent.withValues(alpha: 0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
        canvas.drawCircle(Offset(x, y), noteRadius * 3, glowPaint);
      }

      // 보조선 (staff 밖 음표)
      final ledgerPaint = Paint()
        ..color = noteColor.withValues(alpha: 0.5)
        ..strokeWidth = 1.0;

      // 아래 보조선
      if (y > staffBottom) {
        for (double ly = staffBottom + lineSpacing; ly <= y + halfStep; ly += lineSpacing) {
          canvas.drawLine(
            Offset(x - noteRadius * 1.5, ly),
            Offset(x + noteRadius * 1.5, ly),
            ledgerPaint,
          );
        }
      }
      // 위 보조선
      if (y < staffTop) {
        for (double ly = staffTop - lineSpacing; ly >= y - halfStep; ly -= lineSpacing) {
          canvas.drawLine(
            Offset(x - noteRadius * 1.5, ly),
            Offset(x + noteRadius * 1.5, ly),
            ledgerPaint,
          );
        }
      }

      // 음표 머리
      final notePaint = Paint()
        ..color = noteColor
        ..style = isHalfOrWhole ? PaintingStyle.stroke : PaintingStyle.fill
        ..strokeWidth = 2.0;

      if (isDrum && (note.noteName == '하이햇')) {
        // X 모양 (하이햇/심벌)
        final xSize = noteRadius * 0.8;
        final xPaint = Paint()
          ..color = noteColor
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;
        canvas.drawLine(Offset(x - xSize, y - xSize), Offset(x + xSize, y + xSize), xPaint);
        canvas.drawLine(Offset(x - xSize, y + xSize), Offset(x + xSize, y - xSize), xPaint);
      } else {
        // 타원 음표 머리
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(-0.2); // 살짝 기울기
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset.zero,
            width: noteRadius * 2.2,
            height: noteRadius * 1.6,
          ),
          notePaint,
        );
        canvas.restore();
      }

      // 꼬리 (줄기) - 2분음표 이하
      if (note.duration < 3.0) {
        final stemPaint = Paint()
          ..color = noteColor
          ..strokeWidth = 1.8;
        final stemUp = staffPos < 0; // 아래쪽 음표는 줄기가 위로
        final stemLength = lineSpacing * 3;
        if (stemUp) {
          canvas.drawLine(
            Offset(x + noteRadius * 1.0, y),
            Offset(x + noteRadius * 1.0, y - stemLength),
            stemPaint,
          );
          // 8분음표 깃발
          if (note.duration < 0.7) {
            final flagPaint = Paint()
              ..color = noteColor
              ..strokeWidth = 1.5
              ..style = PaintingStyle.stroke;
            final path = Path()
              ..moveTo(x + noteRadius * 1.0, y - stemLength)
              ..quadraticBezierTo(
                x + noteRadius * 1.0 + lineSpacing, y - stemLength + lineSpacing,
                x + noteRadius * 1.0, y - stemLength + lineSpacing * 1.8,
              );
            canvas.drawPath(path, flagPaint);
          }
        } else {
          canvas.drawLine(
            Offset(x - noteRadius * 1.0, y),
            Offset(x - noteRadius * 1.0, y + stemLength),
            stemPaint,
          );
          if (note.duration < 0.7) {
            final flagPaint = Paint()
              ..color = noteColor
              ..strokeWidth = 1.5
              ..style = PaintingStyle.stroke;
            final path = Path()
              ..moveTo(x - noteRadius * 1.0, y + stemLength)
              ..quadraticBezierTo(
                x - noteRadius * 1.0 + lineSpacing, y + stemLength - lineSpacing,
                x - noteRadius * 1.0, y + stemLength - lineSpacing * 1.8,
              );
            canvas.drawPath(path, flagPaint);
          }
        }
      }

      // 샵/플랫 기호
      if (note.noteName.contains('#') || note.noteName.contains('♯')) {
        final sharpPainter = TextPainter(
          text: TextSpan(
            text: '♯',
            style: TextStyle(fontSize: lineSpacing * 0.9, color: noteColor),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        sharpPainter.paint(canvas, Offset(x - noteRadius * 2.8, y - lineSpacing * 0.5));
      }

      // 음이름 레이블 (아래에 표시)
      if (showLabels) {
        final labelY = max(staffBottom + lineSpacing * 1.8, y + lineSpacing * 1.5);
        final labelPainter = TextPainter(
          text: TextSpan(
            text: note.noteName,
            style: TextStyle(
              fontSize: min(11.0, noteSpacing * 0.35),
              color: noteColor.withValues(alpha: 0.7),
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              fontFamily: 'monospace',
            ),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        )..layout();
        labelPainter.paint(canvas, Offset(x - labelPainter.width / 2, labelY));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SheetMusicPainter old) {
    return old.activeNoteIndex != activeNoteIndex ||
        old.notes.length != notes.length ||
        old.hitResults != hitResults;
  }
}

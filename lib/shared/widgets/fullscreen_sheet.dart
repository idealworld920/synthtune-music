import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../features/lesson/domain/models/lesson.dart';
import 'vexflow_sheet.dart';

/// 전체화면 악보 (스크롤 + 핀치줌 + 필기 + AI 피드백)
class FullscreenSheet extends StatefulWidget {
  final List<MusicNote> notes;
  final String? instrument;
  final String title;
  final List<bool>? hitResults;

  const FullscreenSheet({
    super.key,
    required this.notes,
    this.instrument,
    this.title = '',
    this.hitResults,
  });

  @override
  State<FullscreenSheet> createState() => _FullscreenSheetState();
}

class _FullscreenSheetState extends State<FullscreenSheet> {
  double _scale = 1.0;
  bool _drawMode = false;
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          // 필기 모드 토글
          IconButton(
            icon: Icon(
              _drawMode ? Icons.draw_rounded : Icons.draw_outlined,
              color: _drawMode ? AppColors.accentGold : AppColors.textSecondary,
            ),
            tooltip: '필기',
            onPressed: () => setState(() => _drawMode = !_drawMode),
          ),
          // 필기 지우기
          if (_strokes.isNotEmpty)
            IconButton(
              icon: Icon(Icons.cleaning_services_rounded, color: AppColors.textSecondary),
              tooltip: '필기 지우기',
              onPressed: () => setState(() => _strokes.clear()),
            ),
          // 줌 리셋
          IconButton(
            icon: Icon(Icons.zoom_out_map_rounded, color: AppColors.textSecondary),
            tooltip: '줌 리셋',
            onPressed: () => setState(() => _scale = 1.0),
          ),
        ],
      ),
      body: GestureDetector(
        onScaleUpdate: _drawMode ? null : (details) {
          setState(() => _scale = (_scale * details.scale).clamp(0.5, 3.0));
        },
        onPanStart: _drawMode ? (details) {
          _currentStroke = [details.localPosition];
        } : null,
        onPanUpdate: _drawMode ? (details) {
          setState(() => _currentStroke.add(details.localPosition));
        } : null,
        onPanEnd: _drawMode ? (_) {
          setState(() {
            _strokes.add(List.from(_currentStroke));
            _currentStroke = [];
          });
        } : null,
        child: Stack(
          children: [
            // 악보 (줌 적용)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: Transform.scale(
                  scale: _scale,
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 2,
                    child: VexFlowSheet(
                      notes: widget.notes,
                      instrument: widget.instrument,
                      height: MediaQuery.of(context).size.height * 0.7,
                      hitResults: widget.hitResults,
                    ),
                  ),
                ),
              ),
            ),

            // 필기 레이어
            if (_strokes.isNotEmpty || _currentStroke.isNotEmpty)
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: !_drawMode,
                  child: CustomPaint(
                    painter: _DrawingPainter(
                      strokes: _strokes,
                      currentStroke: _currentStroke,
                    ),
                  ),
                ),
              ),

            // 필기 모드 안내
            if (_drawMode)
              Positioned(
                bottom: 16, left: 0, right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.draw_rounded, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text('필기 모드 ON — 손가락으로 그리세요', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DrawingPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;

  _DrawingPainter({required this.strokes, required this.currentStroke});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accentGold
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.length < 2) continue;
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }

    if (currentStroke.length >= 2) {
      final path = Path()..moveTo(currentStroke.first.dx, currentStroke.first.dy);
      for (int i = 1; i < currentStroke.length; i++) {
        path.lineTo(currentStroke[i].dx, currentStroke[i].dy);
      }
      canvas.drawPath(path, paint..color = AppColors.accentGold.withValues(alpha: 0.7));
    }
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter old) => true;
}

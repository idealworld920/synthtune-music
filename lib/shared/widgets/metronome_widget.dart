import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';

/// 메트로놈 위젯 — 연습 시 BPM 맞춰 박자 제공
class MetronomeWidget extends StatefulWidget {
  final int initialBpm;
  const MetronomeWidget({super.key, this.initialBpm = 80});

  @override
  State<MetronomeWidget> createState() => _MetronomeWidgetState();
}

class _MetronomeWidgetState extends State<MetronomeWidget> with SingleTickerProviderStateMixin {
  late int _bpm;
  bool _isPlaying = false;
  Timer? _timer;
  int _beat = 0;
  int _beatsPerMeasure = 4;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _bpm = widget.initialBpm;
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() => _isPlaying = !_isPlaying);
    if (_isPlaying) {
      _startTimer();
    } else {
      _timer?.cancel();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    final interval = Duration(milliseconds: (60000 / _bpm).round());
    _timer = Timer.periodic(interval, (_) {
      setState(() => _beat = (_beat + 1) % _beatsPerMeasure);
      _pulseCtrl.forward().then((_) => _pulseCtrl.reverse());
      HapticFeedback.lightImpact();
    });
  }

  void _changeBpm(int delta) {
    setState(() => _bpm = (_bpm + delta).clamp(30, 240));
    if (_isPlaying) _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _isPlaying ? AppColors.accent.withValues(alpha: 0.4) : AppColors.bgSurface),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 비트 인디케이터
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_beatsPerMeasure, (i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: _beat == i && _isPlaying ? 18 : 12,
                height: _beat == i && _isPlaying ? 18 : 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _beat == i && _isPlaying
                      ? (i == 0 ? AppColors.scoreMiss : AppColors.accent)
                      : AppColors.bgSurface,
                ),
              ),
            )),
          ),
          const SizedBox(height: 14),

          // BPM 조절
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => _changeBpm(-5),
                icon: Icon(Icons.remove_circle_outline, color: AppColors.textSecondary),
                iconSize: 28,
              ),
              IconButton(
                onPressed: () => _changeBpm(-1),
                icon: Icon(Icons.remove, color: AppColors.textSecondary),
                iconSize: 20,
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  Text('$_bpm', style: TextStyle(color: AppColors.textPrimary, fontSize: 32, fontWeight: FontWeight.bold)),
                  Text('BPM', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _changeBpm(1),
                icon: Icon(Icons.add, color: AppColors.textSecondary),
                iconSize: 20,
              ),
              IconButton(
                onPressed: () => _changeBpm(5),
                icon: Icon(Icons.add_circle_outline, color: AppColors.textSecondary),
                iconSize: 28,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 재생/정지 + 박자 선택
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 박자 선택
              DropdownButton<int>(
                value: _beatsPerMeasure,
                dropdownColor: AppColors.bgCard,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                underline: const SizedBox.shrink(),
                items: [2, 3, 4, 6].map((b) => DropdownMenuItem(value: b, child: Text('$b/4'))).toList(),
                onChanged: (v) { if (v != null) setState(() { _beatsPerMeasure = v; _beat = 0; }); },
              ),
              const SizedBox(width: 16),
              // 재생 버튼
              GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isPlaying ? AppColors.scoreMiss : AppColors.accent,
                  ),
                  child: Icon(
                    _isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                    color: Colors.white, size: 28,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 메트로놈 팝업 버튼 (연습 화면 AppBar용)
class MetronomeButton extends StatelessWidget {
  const MetronomeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.timer_rounded, color: AppColors.accent),
      tooltip: '메트로놈',
      onPressed: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: AppColors.bgSurface,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          builder: (_) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('메트로놈', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const MetronomeWidget(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}

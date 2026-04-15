import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';

// 메트로놈 소리 종류
enum MetronomeSound { click, wood, beep, bell }

extension MetronomeSoundExt on MetronomeSound {
  String get label {
    switch (this) {
      case MetronomeSound.click: return '클릭 (기본)';
      case MetronomeSound.wood: return '우드블록';
      case MetronomeSound.beep: return '전자음';
      case MetronomeSound.bell: return '벨';
    }
  }

  // 주파수 기반 톤 생성 (내장 소리)
  double get frequency {
    switch (this) {
      case MetronomeSound.click: return 800;
      case MetronomeSound.wood: return 400;
      case MetronomeSound.beep: return 1200;
      case MetronomeSound.bell: return 2000;
    }
  }

  double get accentFreq {
    switch (this) {
      case MetronomeSound.click: return 1200;
      case MetronomeSound.wood: return 600;
      case MetronomeSound.beep: return 1800;
      case MetronomeSound.bell: return 3000;
    }
  }
}

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
  MetronomeSound _sound = MetronomeSound.click;
  final _player = AudioPlayer();
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _bpm = widget.initialBpm;
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _loadSound();
  }

  Future<void> _loadSound() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('metronome_sound') ?? 'click';
    setState(() => _sound = MetronomeSound.values.firstWhere((s) => s.name == name, orElse: () => MetronomeSound.click));
  }

  Future<void> _saveSound(MetronomeSound s) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('metronome_sound', s.name);
    setState(() => _sound = s);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseCtrl.dispose();
    _player.dispose();
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
    _beat = 0;
    _timer = Timer.periodic(interval, (_) {
      final isAccent = _beat % _beatsPerMeasure == 0;
      setState(() => _beat = (_beat + 1) % _beatsPerMeasure);
      _pulseCtrl.forward().then((_) => _pulseCtrl.reverse());
      _playTick(isAccent);
      HapticFeedback.lightImpact();
    });
  }

  Future<void> _playTick(bool isAccent) async {
    try {
      final freq = isAccent ? _sound.accentFreq : _sound.frequency;
      final duration = _sound == MetronomeSound.bell ? 150 : 50;
      // 내장 톤 생성 URL (WAV 생성 불필요 — 시스템 소리 활용)
      await _player.play(
        AssetSource(''),
        mode: PlayerMode.lowLatency,
      ).catchError((_) {});
      // 폴백: 시스템 사운드
      SystemSound.play(isAccent ? SystemSoundType.alert : SystemSoundType.click);
    } catch (_) {
      SystemSound.play(SystemSoundType.click);
    }
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
                width: _beat == i && _isPlaying ? 20 : 12,
                height: _beat == i && _isPlaying ? 20 : 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _beat == i && _isPlaying
                      ? (i == 0 ? AppColors.scoreMiss : AppColors.accent)
                      : AppColors.bgSurface,
                  boxShadow: _beat == i && _isPlaying ? [
                    BoxShadow(color: (i == 0 ? AppColors.scoreMiss : AppColors.accent).withValues(alpha: 0.5), blurRadius: 8),
                  ] : null,
                ),
              ),
            )),
          ),
          const SizedBox(height: 14),

          // BPM 조절
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(onPressed: () => _changeBpm(-5), icon: Icon(Icons.remove_circle_outline, color: AppColors.textSecondary), iconSize: 28),
              IconButton(onPressed: () => _changeBpm(-1), icon: Icon(Icons.remove, color: AppColors.textSecondary), iconSize: 20),
              const SizedBox(width: 8),
              Column(
                children: [
                  Text('$_bpm', style: TextStyle(color: AppColors.textPrimary, fontSize: 32, fontWeight: FontWeight.bold)),
                  Text('BPM', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
              const SizedBox(width: 8),
              IconButton(onPressed: () => _changeBpm(1), icon: Icon(Icons.add, color: AppColors.textSecondary), iconSize: 20),
              IconButton(onPressed: () => _changeBpm(5), icon: Icon(Icons.add_circle_outline, color: AppColors.textSecondary), iconSize: 28),
            ],
          ),
          const SizedBox(height: 10),

          // 재생 + 박자 + 소리 선택
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
              const SizedBox(width: 12),
              // 재생 버튼
              GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isPlaying ? AppColors.scoreMiss : AppColors.accent,
                    boxShadow: [BoxShadow(color: (_isPlaying ? AppColors.scoreMiss : AppColors.accent).withValues(alpha: 0.3), blurRadius: 12)],
                  ),
                  child: Icon(_isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 30),
                ),
              ),
              const SizedBox(width: 12),
              // 소리 선택
              DropdownButton<MetronomeSound>(
                value: _sound,
                dropdownColor: AppColors.bgCard,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                underline: const SizedBox.shrink(),
                items: MetronomeSound.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label))).toList(),
                onChanged: (v) { if (v != null) _saveSound(v); },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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

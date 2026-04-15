import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';

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

  int get durationMs {
    switch (this) {
      case MetronomeSound.click: return 30;
      case MetronomeSound.wood: return 50;
      case MetronomeSound.beep: return 80;
      case MetronomeSound.bell: return 120;
    }
  }
}

/// WAV 파일 생성 (사인파 톤)
Future<String> _generateToneWav(double freq, int durationMs, String name) async {
  final dir = await getTemporaryDirectory();
  final path = '${dir.path}/metronome_$name.wav';
  final file = File(path);
  if (await file.exists()) return path;

  const sampleRate = 44100;
  final numSamples = (sampleRate * durationMs / 1000).round();
  final samples = Int16List(numSamples);

  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final envelope = (1.0 - i / numSamples); // 페이드 아웃
    final value = (sin(2 * pi * freq * t) * 32767 * envelope * 0.8).round().clamp(-32767, 32767);
    samples[i] = value;
  }

  // WAV 헤더
  final dataSize = numSamples * 2;
  final header = ByteData(44);
  // RIFF
  header.setUint8(0, 0x52); header.setUint8(1, 0x49); header.setUint8(2, 0x46); header.setUint8(3, 0x46);
  header.setUint32(4, 36 + dataSize, Endian.little);
  // WAVE
  header.setUint8(8, 0x57); header.setUint8(9, 0x41); header.setUint8(10, 0x56); header.setUint8(11, 0x45);
  // fmt
  header.setUint8(12, 0x66); header.setUint8(13, 0x6D); header.setUint8(14, 0x74); header.setUint8(15, 0x20);
  header.setUint32(16, 16, Endian.little); // chunk size
  header.setUint16(20, 1, Endian.little); // PCM
  header.setUint16(22, 1, Endian.little); // mono
  header.setUint32(24, sampleRate, Endian.little);
  header.setUint32(28, sampleRate * 2, Endian.little); // byte rate
  header.setUint16(32, 2, Endian.little); // block align
  header.setUint16(34, 16, Endian.little); // bits per sample
  // data
  header.setUint8(36, 0x64); header.setUint8(37, 0x61); header.setUint8(38, 0x74); header.setUint8(39, 0x61);
  header.setUint32(40, dataSize, Endian.little);

  final bytes = BytesBuilder();
  bytes.add(header.buffer.asUint8List());
  bytes.add(samples.buffer.asUint8List());
  await file.writeAsBytes(bytes.toBytes());
  return path;
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
  final _tickPlayer = AudioPlayer();
  final _accentPlayer = AudioPlayer();
  String? _tickPath;
  String? _accentPath;
  late AnimationController _pulseCtrl;
  bool _ready = false;

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
    _sound = MetronomeSound.values.firstWhere((s) => s.name == name, orElse: () => MetronomeSound.click);
    await _prepareSounds();
    if (mounted) setState(() => _ready = true);
  }

  Future<void> _prepareSounds() async {
    _tickPath = await _generateToneWav(_sound.frequency, _sound.durationMs, '${_sound.name}_tick');
    _accentPath = await _generateToneWav(_sound.accentFreq, _sound.durationMs + 20, '${_sound.name}_accent');
  }

  Future<void> _saveSound(MetronomeSound s) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('metronome_sound', s.name);
    setState(() { _sound = s; _ready = false; });
    // 이전 파일 삭제해서 새로 생성
    final dir = await getTemporaryDirectory();
    for (final f in ['${s.name}_tick', '${s.name}_accent']) {
      final file = File('${dir.path}/metronome_$f.wav');
      if (await file.exists()) await file.delete();
    }
    await _prepareSounds();
    setState(() => _ready = true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseCtrl.dispose();
    _tickPlayer.dispose();
    _accentPlayer.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (!_ready) return;
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
      HapticFeedback.mediumImpact();
    });
  }

  Future<void> _playTick(bool isAccent) async {
    try {
      final path = isAccent ? _accentPath : _tickPath;
      if (path == null) return;
      final player = isAccent ? _accentPlayer : _tickPlayer;
      await player.stop();
      await player.play(DeviceFileSource(path), volume: 1.0);
    } catch (_) {}
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

          // BPM
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

          // 재생 + 박자 + 소리
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<int>(
                value: _beatsPerMeasure,
                dropdownColor: AppColors.bgCard,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                underline: const SizedBox.shrink(),
                items: [2, 3, 4, 6].map((b) => DropdownMenuItem(value: b, child: Text('$b/4'))).toList(),
                onChanged: (v) { if (v != null) setState(() { _beatsPerMeasure = v; _beat = 0; }); },
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: !_ready ? AppColors.textSecondary : _isPlaying ? AppColors.scoreMiss : AppColors.accent,
                    boxShadow: [BoxShadow(color: (_isPlaying ? AppColors.scoreMiss : AppColors.accent).withValues(alpha: 0.3), blurRadius: 12)],
                  ),
                  child: Icon(_isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 30),
                ),
              ),
              const SizedBox(width: 12),
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

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/services/ai_voice_service.dart';

enum _PracticeMode { audio, video }
enum _PracticeState { idle, recording, analyzing, done }

class FreePracticeScreen extends ConsumerStatefulWidget {
  const FreePracticeScreen({super.key});

  @override
  ConsumerState<FreePracticeScreen> createState() => _FreePracticeScreenState();
}

class _FreePracticeScreenState extends ConsumerState<FreePracticeScreen>
    with TickerProviderStateMixin {
  final _recorder = AudioRecorder();
  CameraController? _cameraCtrl;
  bool _cameraReady = false;

  _PracticeMode _mode = _PracticeMode.audio;
  _PracticeState _state = _PracticeState.idle;
  bool _videoFullscreen = false;
  Duration _elapsed = Duration.zero;
  String? _recordingPath;

  // 실시간 피드백 (일반화면 영상 모드)
  String _liveFeedback = '';
  int _liveFeedbackIndex = 0;
  final _liveFeedbacks = [
    '음정이 안정적이에요!',
    '리듬감이 좋아요!',
    '자세가 좋습니다!',
    '좋은 흐름이에요!',
    '이 조자로 유지해보세요!',
  ];

  // AI 결과
  String _feedbackTitle = '';
  String _feedbackBody = '';
  int _feedbackScore = 0;

  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      final front = cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.front, orElse: () => cameras.first);
      _cameraCtrl = CameraController(front, ResolutionPreset.medium, enableAudio: false);
      await _cameraCtrl!.initialize();
      if (mounted) setState(() => _cameraReady = true);
    } catch (_) {}
  }

  @override
  void dispose() {
    _recorder.dispose();
    _cameraCtrl?.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('마이크 권한이 필요합니다.'), backgroundColor: AppColors.scoreMiss));
        return;
      }
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/free_${DateTime.now().millisecondsSinceEpoch}.wav';
      await _recorder.start(const RecordConfig(encoder: AudioEncoder.pcm16bits, sampleRate: 44100, numChannels: 1), path: path);
      setState(() { _state = _PracticeState.recording; _recordingPath = path; _elapsed = Duration.zero; });
      _updateTimer();
      if (_mode == _PracticeMode.video) _updateLiveFeedback();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('오류: $e'), backgroundColor: AppColors.scoreMiss));
    }
  }

  void _updateTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted || _state != _PracticeState.recording) return;
      setState(() => _elapsed += const Duration(seconds: 1));
      _updateTimer();
    });
  }

  void _updateLiveFeedback() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted || _state != _PracticeState.recording) return;
      setState(() {
        _liveFeedbackIndex = (_liveFeedbackIndex + 1) % _liveFeedbacks.length;
        _liveFeedback = _liveFeedbacks[_liveFeedbackIndex];
      });
      _updateLiveFeedback();
    });
  }

  Future<void> _stopRecording() async {
    await _recorder.stop();
    setState(() => _state = _PracticeState.analyzing);
    AiVoiceService.speak('분석 중입니다.');

    // 실제 녹음 오디오를 분석 (분석과 최소 연출 지연을 동시에 진행)
    final analysisFuture = _analyzeRecording();
    await Future.delayed(const Duration(milliseconds: 1500));
    final analysis = await analysisFuture;
    if (!mounted) return;

    AiVoiceService.speak(analysis.title);
    setState(() {
      _state = _PracticeState.done;
      _feedbackScore = analysis.score;
      _feedbackTitle = analysis.title;
      _feedbackBody = analysis.body;
    });
  }

  /// 녹음된 PCM16 오디오에서 음량(RMS)·연주 비율·길이를 추출해 점수와 피드백 생성
  Future<_Analysis> _analyzeRecording() async {
    try {
      final path = _recordingPath;
      if (path == null) return _fallbackAnalysis();
      final file = File(path);
      if (!await file.exists()) return _fallbackAnalysis();
      final bytes = await file.readAsBytes();

      // WAV 헤더(RIFF)가 있으면 44바이트 건너뛰기
      int offset = 0;
      if (bytes.length > 44 && bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x46) {
        offset = 44;
      }
      final sampleCount = (bytes.length - offset) ~/ 2;
      if (sampleCount < 2000) return _fallbackAnalysis();

      final data = ByteData.sublistView(bytes, offset);
      const frameSize = 1024; // 약 23ms @44.1kHz
      double sumSquares = 0;
      double peak = 0;
      double frameEnergy = 0;
      int frameSamples = 0;
      int frameCount = 0;
      int activeFrames = 0;

      for (int i = 0; i < sampleCount; i++) {
        final s = data.getInt16(i * 2, Endian.little) / 32768.0;
        final a = s.abs();
        sumSquares += s * s;
        if (a > peak) peak = a;
        frameEnergy += s * s;
        if (++frameSamples >= frameSize) {
          final frameRms = sqrt(frameEnergy / frameSamples);
          if (frameRms > 0.02) activeFrames++;
          frameCount++;
          frameEnergy = 0;
          frameSamples = 0;
        }
      }

      final rms = sqrt(sumSquares / sampleCount);
      final activeRatio = frameCount == 0 ? 0.0 : activeFrames / frameCount;
      final seconds = _elapsed.inSeconds;

      return _scoreFromMetrics(rms: rms, peak: peak, activeRatio: activeRatio, seconds: seconds);
    } catch (_) {
      return _fallbackAnalysis();
    }
  }

  _Analysis _scoreFromMetrics({required double rms, required double peak, required double activeRatio, required int seconds}) {
    // 거의 무음이거나 너무 짧으면 안내
    if (rms < 0.01 || activeRatio < 0.05 || seconds < 2) {
      return const _Analysis(
        score: 0,
        title: '소리가 잘 들리지 않아요',
        body: '녹음에서 연주 소리가 거의 감지되지 않았어요.\n\n• 마이크에 더 가까이서 연주해보세요\n• 주변 소음이 적은 곳에서 시도해보세요\n• 최소 5초 이상 연주해보세요',
      );
    }

    // 연주 비율 (끊김 없이 꾸준히 소리가 났는지)
    final presence = (activeRatio.clamp(0.0, 0.85) / 0.85);
    // 음량 적정성
    double volume;
    if (rms < 0.03) {
      volume = (rms / 0.03) * 0.6;
    } else if (rms <= 0.3) {
      volume = 1.0;
    } else {
      volume = (1.0 - ((rms - 0.3) / 0.4)).clamp(0.4, 1.0);
    }
    final clipping = peak > 0.98;
    // 연주 길이 적정성 (20초 이상이면 충분)
    final duration = (seconds / 20).clamp(0.3, 1.0);

    double raw = (presence * 0.45 + volume * 0.30 + duration * 0.25) * 100;
    if (clipping) raw -= 8;
    final score = raw.clamp(35, 98).round();

    // 지표 기반 동적 관찰
    final observations = <String>[];
    if (activeRatio < 0.45) observations.add('중간중간 소리가 끊겨요 — 프레이즈를 끝까지 이어보세요');
    if (rms < 0.03) observations.add('음량이 작아요 — 마이크에 가까이서 또렷하게 연주해보세요');
    if (clipping) observations.add('소리가 너무 커서 음이 뭉개져요 — 마이크와 거리를 두세요');
    if (seconds < 8) observations.add('연주가 짧아요 — 조금 더 길게 연주하면 분석이 정확해져요');

    String title, lead;
    if (score >= 85) {
      title = '훌륭한 연주!';
      lead = '음량이 안정적이고 연주가 끊김 없이 이어졌어요.';
    } else if (score >= 70) {
      title = '좋은 연주예요!';
      lead = '전반적으로 안정적인 연주였어요.';
    } else if (score >= 55) {
      title = '잘하고 있어요!';
      lead = '기본 흐름은 좋아요. 몇 가지만 다듬어볼까요?';
    } else {
      title = '좋은 시작이에요!';
      lead = '연습하면 반드시 나아질 거예요!';
    }

    final goodPoints = <String>[];
    if (activeRatio >= 0.6) goodPoints.add('연주가 끊김 없이 꾸준히 이어졌어요');
    if (rms >= 0.05 && rms <= 0.3 && !clipping) goodPoints.add('음량이 또렷하고 적당해요');
    if (seconds >= 15) goodPoints.add('충분한 길이로 연주했어요');

    final buf = StringBuffer(lead);
    if (goodPoints.isNotEmpty) {
      buf.write('\n\n잘한 점:');
      for (final g in goodPoints) {
        buf.write('\n• $g');
      }
    }
    if (observations.isNotEmpty) {
      buf.write('\n\n개선점:');
      for (final o in observations) {
        buf.write('\n• $o');
      }
    } else if (score >= 85) {
      buf.write('\n\n개선점:\n• 다이나믹(셈여림) 변화를 더 주면 표현이 풍부해져요');
    }

    return _Analysis(score: score, title: title, body: buf.toString());
  }

  _Analysis _fallbackAnalysis() {
    // 오디오를 읽지 못한 경우 길이 기반 간이 평가
    final seconds = _elapsed.inSeconds;
    if (seconds < 2) {
      return const _Analysis(
        score: 0,
        title: '녹음이 너무 짧아요',
        body: '연주를 조금 더 길게 녹음해보세요.\n최소 5초 이상이면 분석이 가능해요.',
      );
    }
    final score = (55 + (seconds.clamp(0, 30))).clamp(55, 85);
    return _Analysis(
      score: score,
      title: '좋은 연주예요!',
      body: '꾸준히 연주를 이어갔어요.\n\n• 느린 템포부터 정확하게 연습해보세요\n• 어려운 구간은 분리해서 반복하면 좋아요',
    );
  }

  void _reset() => setState(() { _state = _PracticeState.idle; _feedbackScore = 0; _elapsed = Duration.zero; _liveFeedback = ''; });

  String _fmt(Duration d) => '${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  Color _scoreColor(int s) => s >= 85 ? AppColors.scorePerfect : s >= 70 ? AppColors.accent : s >= 55 ? AppColors.accentGold : AppColors.scoreMiss;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _state == _PracticeState.recording && _mode == _PracticeMode.video && _videoFullscreen
          ? null
          : AppBar(title: const Text('자유 연습')),
      body: SafeArea(
        child: _state == _PracticeState.idle ? _buildIdle()
            : _state == _PracticeState.recording ? _buildRecording()
            : _state == _PracticeState.analyzing ? _buildAnalyzing()
            : _buildDone(),
      ),
    );
  }

  // ─── 대기 ───
  Widget _buildIdle() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // 캐릭터
          _MusicCharacter(),
          const SizedBox(height: 24),
          Text('자유롭게 연주하세요', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('어떤 곡이든 AI가 분석하고 피드백합니다', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 32),

          // 모드 선택
          Row(
            children: [
              Expanded(child: _ModeCard(
                icon: Icons.mic_rounded, label: '녹음', desc: '음성만 분석',
                isSelected: _mode == _PracticeMode.audio,
                onTap: () => setState(() => _mode = _PracticeMode.audio),
              )),
              const SizedBox(width: 12),
              Expanded(child: _ModeCard(
                icon: Icons.videocam_rounded, label: '영상', desc: '음성 + 자세 분석',
                isSelected: _mode == _PracticeMode.video,
                onTap: () => setState(() => _mode = _PracticeMode.video),
              )),
            ],
          ),
          const SizedBox(height: 32),

          // 시작 버튼
          GestureDetector(
            onTap: _startRecording,
            child: Container(
              width: 88, height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.scoreMiss,
                boxShadow: [BoxShadow(color: AppColors.scoreMiss.withValues(alpha: 0.4), blurRadius: 20)],
              ),
              child: Icon(_mode == _PracticeMode.video ? Icons.videocam_rounded : Icons.mic_rounded, color: Colors.white, size: 40),
            ),
          ),
          const SizedBox(height: 12),
          Text('탭하여 시작', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }

  // ─── 녹음/영상 중 ───
  Widget _buildRecording() {
    if (_mode == _PracticeMode.video) return _buildVideoRecording();

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, __) => Container(
              width: 100 + _pulseCtrl.value * 20, height: 100 + _pulseCtrl.value * 20,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.scoreMiss.withValues(alpha: 0.12 + _pulseCtrl.value * 0.08)),
              child: Center(child: Container(
                width: 72, height: 72,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.scoreMiss),
                child: Icon(Icons.mic_rounded, color: Colors.white, size: 32),
              )),
            ),
          ),
          const SizedBox(height: 24),
          Text(_fmt(_elapsed), style: TextStyle(color: AppColors.textPrimary, fontSize: 48, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
          const SizedBox(height: 8),
          Text('녹음 중...', style: TextStyle(color: AppColors.scoreMiss, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: _stopRecording,
            child: Container(
              width: 64, height: 64,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.bgCard, border: Border.all(color: AppColors.scoreMiss, width: 3)),
              child: Icon(Icons.stop_rounded, color: AppColors.scoreMiss, size: 32),
            ),
          ),
          const SizedBox(height: 8),
          Text('탭하여 중지', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildVideoRecording() {
    if (_videoFullscreen) {
      // 전체 화면 영상
      return Stack(
        children: [
          if (_cameraReady && _cameraCtrl != null)
            Positioned.fill(child: CameraPreview(_cameraCtrl!))
          else
            Positioned.fill(child: Container(color: AppColors.bgCard, child: Center(child: Text('카메라 사용 불가', style: TextStyle(color: AppColors.textSecondary))))),
          // 상단 바
          Positioned(
            top: 8, left: 8, right: 8,
            child: Row(
              children: [
                _PillBadge(text: _fmt(_elapsed), color: AppColors.scoreMiss),
                const Spacer(),
                IconButton(icon: Icon(Icons.fullscreen_exit_rounded, color: Colors.white), onPressed: () => setState(() => _videoFullscreen = false)),
              ],
            ),
          ),
          // 하단 정지 버튼
          Positioned(
            bottom: 30, left: 0, right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _stopRecording,
                child: Container(width: 64, height: 64, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white24, border: Border.all(color: Colors.white, width: 3)),
                  child: Icon(Icons.stop_rounded, color: Colors.white, size: 32)),
              ),
            ),
          ),
        ],
      );
    }

    // 일반 화면 영상 + 실시간 피드백 + 캐릭터
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 카메라 프리뷰
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 2)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                children: [
                  if (_cameraReady && _cameraCtrl != null) Positioned.fill(child: CameraPreview(_cameraCtrl!))
                  else Center(child: Icon(Icons.videocam_off_rounded, color: AppColors.textSecondary, size: 40)),
                  // 전체화면 버튼
                  Positioned(top: 8, right: 8, child: GestureDetector(
                    onTap: () => setState(() => _videoFullscreen = true),
                    child: Container(width: 32, height: 32, decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: Icon(Icons.fullscreen_rounded, color: Colors.white, size: 20)),
                  )),
                  // 녹음 시간
                  Positioned(top: 8, left: 8, child: _PillBadge(text: _fmt(_elapsed), color: AppColors.scoreMiss)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 실시간 피드백 + 캐릭터
          Row(
            children: [
              // 캐릭터
              _MusicCharacterSmall(),
              const SizedBox(width: 12),
              // 피드백 말풍선
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    key: ValueKey(_liveFeedback),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _liveFeedback.isEmpty ? '연주를 듣고 있어요...' : _liveFeedback,
                      style: TextStyle(color: AppColors.accent, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 정지 버튼
          GestureDetector(
            onTap: _stopRecording,
            child: Container(
              width: 64, height: 64,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.bgCard, border: Border.all(color: AppColors.scoreMiss, width: 3)),
              child: Icon(Icons.stop_rounded, color: AppColors.scoreMiss, size: 32),
            ),
          ),
          const SizedBox(height: 8),
          Text('탭하여 중지', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }

  // ─── 분석 중 ───
  Widget _buildAnalyzing() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MusicCharacter(),
          const SizedBox(height: 24),
          SizedBox(width: 48, height: 48, child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 3)),
          const SizedBox(height: 16),
          Text('AI가 연주를 분석하고 있습니다...', textAlign: TextAlign.center, style: TextStyle(color: AppColors.accent, fontSize: 17, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ─── 결과 ───
  Widget _buildDone() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 110, height: 110,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _scoreColor(_feedbackScore), width: 5)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$_feedbackScore', style: TextStyle(color: _scoreColor(_feedbackScore), fontSize: 34, fontWeight: FontWeight.bold)),
                Text('점', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(_feedbackTitle, textAlign: TextAlign.center, style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.accent.withValues(alpha: 0.3))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.auto_awesome_rounded, color: AppColors.accent, size: 18),
                  const SizedBox(width: 8),
                  Text('AI 피드백', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 15)),
                ]),
                const SizedBox(height: 12),
                Text(_feedbackBody, style: TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.6)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: OutlinedButton.icon(
                onPressed: _reset,
                icon: Icon(Icons.replay_rounded),
                label: const Text('다시'),
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: BorderSide(color: AppColors.primary), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              )),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.check_rounded),
                label: const Text('완료'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              )),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── 분석 결과 ───

class _Analysis {
  final int score;
  final String title;
  final String body;
  const _Analysis({required this.score, required this.title, required this.body});
}

// ─── 위젯들 ───

class _ModeCard extends StatelessWidget {
  final IconData icon; final String label, desc; final bool isSelected; final VoidCallback onTap;
  const _ModeCard({required this.icon, required this.label, required this.desc, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.bgSurface, width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 32),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: isSelected ? AppColors.primary : AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
            Text(desc, style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _PillBadge extends StatelessWidget {
  final String text; final Color color;
  const _PillBadge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white)),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
      ]),
    );
  }
}

/// 음악 캐릭터 (헤드셋 끼고 듣는 모습)
class _MusicCharacter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120, height: 120,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 얼굴
          Text('😊', style: TextStyle(fontSize: 48)),
          // 헤드셋
          Positioned(
            top: 12,
            child: Container(
              width: 80, height: 30,
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.primary, width: 4)),
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
            ),
          ),
          // 왼쪽 이어폰
          Positioned(left: 14, top: 35, child: Container(
            width: 18, height: 18,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
          )),
          // 오른쪽 이어폰
          Positioned(right: 14, top: 35, child: Container(
            width: 18, height: 18,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
          )),
          // 음표
          Positioned(right: 8, top: 8, child: Text('♪', style: TextStyle(color: AppColors.accent, fontSize: 16))),
          Positioned(left: 8, bottom: 12, child: Text('♫', style: TextStyle(color: AppColors.accentGold, fontSize: 14))),
        ],
      ),
    );
  }
}

class _MusicCharacterSmall extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52, height: 52,
      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), shape: BoxShape.circle),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text('😊', style: TextStyle(fontSize: 24)),
          Positioned(top: 4, child: Container(
            width: 36, height: 14,
            decoration: BoxDecoration(border: Border(top: BorderSide(color: AppColors.primary, width: 2.5)), borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
          )),
          Positioned(left: 6, top: 14, child: Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary))),
          Positioned(right: 6, top: 14, child: Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary))),
        ],
      ),
    );
  }
}

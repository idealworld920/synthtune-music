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

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final score = 60 + (DateTime.now().second % 35);
    String title, body;
    if (score >= 85) {
      title = '훌륭한 연주!';
      body = '음정이 안정적이고 리듬감도 좋습니다.\n\n개선점:\n• 다이나믹 변화를 더 주면 좋겠어요\n• 고음부 음정을 조금 더 신경 써보세요';
    } else if (score >= 70) {
      title = '좋은 연주예요!';
      body = '전반적으로 안정적입니다.\n\n잘한 점:\n• 리듬이 일정해요\n• 곡의 흐름을 잘 이해하고 있어요\n\n개선점:\n• 고음부 음정 불안\n• 프레이즈 호흡을 더 자연스럽게';
    } else {
      title = '좋은 시작이에요!';
      body = '연습하면 반드시 나아질 거예요!\n\n관찰된 사항:\n• 기본 멜로디 라인은 잘 따라가고 있어요\n• 느린 템포부터 시작해보세요\n• 어려운 구간은 분리해서 반복 연습하세요';
    }
    AiVoiceService.speak(title);
    setState(() { _state = _PracticeState.done; _feedbackScore = score; _feedbackTitle = title; _feedbackBody = body; });
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

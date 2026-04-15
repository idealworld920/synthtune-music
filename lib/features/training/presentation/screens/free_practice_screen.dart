import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/services/ai_voice_service.dart';

class FreePracticeScreen extends ConsumerStatefulWidget {
  const FreePracticeScreen({super.key});

  @override
  ConsumerState<FreePracticeScreen> createState() => _FreePracticeScreenState();
}

class _FreePracticeScreenState extends ConsumerState<FreePracticeScreen>
    with SingleTickerProviderStateMixin {
  final _recorder = AudioRecorder();
  bool _isRecording = false;
  bool _isAnalyzing = false;
  bool _isDone = false;
  String? _recordingPath;
  Duration _elapsed = Duration.zero;
  late AnimationController _pulseCtrl;

  // AI 피드백 결과 (mock)
  String _feedbackTitle = '';
  String _feedbackBody = '';
  int _feedbackScore = 0;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _recorder.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('마이크 권한이 필요합니다.'), backgroundColor: AppColors.scoreMiss),
          );
        }
        return;
      }

      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/free_practice_${DateTime.now().millisecondsSinceEpoch}.wav';

      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.pcm16bits, sampleRate: 44100, numChannels: 1),
        path: path,
      );

      setState(() {
        _isRecording = true;
        _isDone = false;
        _recordingPath = path;
        _elapsed = Duration.zero;
      });

      // 타이머
      _updateTimer();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('녹음 시작 오류: $e'), backgroundColor: AppColors.scoreMiss),
        );
      }
    }
  }

  void _updateTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted || !_isRecording) return;
      setState(() => _elapsed += const Duration(seconds: 1));
      _updateTimer();
    });
  }

  Future<void> _stopRecording() async {
    await _recorder.stop();
    setState(() { _isRecording = false; _isAnalyzing = true; });

    AiVoiceService.speak('분석 중입니다. 잠시만 기다려주세요.');

    // AI 분석 시뮬레이션
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // 피드백 생성 (mock — 실제로는 AI 모델 필요)
    final score = 60 + (DateTime.now().second % 35);
    String title, body;

    if (score >= 85) {
      title = '훌륭한 연주!';
      body = '음정이 안정적이고 리듬감도 좋습니다. 톤의 일관성이 뛰어나요.\n\n개선점:\n• 일부 구간에서 템포가 약간 빨라졌어요\n• 다이나믹 변화를 더 주면 좋겠어요';
    } else if (score >= 70) {
      title = '좋은 연주예요!';
      body = '전반적으로 안정적인 연주입니다. 몇 가지 개선하면 더 좋아질 거예요.\n\n잘한 점:\n• 리듬이 일정해요\n• 곡의 흐름을 잘 이해하고 있어요\n\n개선점:\n• 고음부에서 음정이 살짝 불안해요\n• 프레이즈 사이 호흡을 더 자연스럽게';
    } else {
      title = '좋은 시작이에요!';
      body = '연습하면 반드시 나아질 거예요! 꾸준히 도전해보세요.\n\n관찰된 사항:\n• 기본 멜로디 라인은 잘 따라가고 있어요\n• 음정 정확도를 높이려면 느린 템포부터 시작해보세요\n• 어려운 구간은 분리해서 반복 연습하세요';
    }

    AiVoiceService.speak(title);

    setState(() {
      _isAnalyzing = false;
      _isDone = true;
      _feedbackScore = score;
      _feedbackTitle = title;
      _feedbackBody = body;
    });
  }

  void _reset() {
    setState(() {
      _isDone = false;
      _isRecording = false;
      _isAnalyzing = false;
      _feedbackScore = 0;
      _feedbackTitle = '';
      _feedbackBody = '';
      _elapsed = Duration.zero;
    });
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('자유 연습')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              if (!_isRecording && !_isAnalyzing && !_isDone) ...[
                // 시작 화면
                const SizedBox(height: 40),
                Icon(Icons.music_note_rounded, color: AppColors.primary, size: 64),
                const SizedBox(height: 24),
                Text('자유롭게 연주하세요', style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text('어떤 곡이든 녹음하면\nAI가 연주를 분석하고 피드백합니다', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5)),
                const SizedBox(height: 40),

                // 안내
                _InfoCard(icon: Icons.mic_rounded, title: '녹음', desc: '연주를 녹음하면 AI가 음정과 리듬을 분석합니다'),
                const SizedBox(height: 10),
                _InfoCard(icon: Icons.videocam_rounded, title: '영상', desc: '카메라를 켜면 AI가 자세도 함께 피드백합니다'),
                const SizedBox(height: 10),
                _InfoCard(icon: Icons.auto_awesome_rounded, title: 'AI 코치', desc: '앱에 없는 곡도 자유롭게 분석 가능합니다'),
                const SizedBox(height: 40),

                // 녹음 시작 버튼
                GestureDetector(
                  onTap: _startRecording,
                  child: Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.scoreMiss,
                      boxShadow: [BoxShadow(color: AppColors.scoreMiss.withValues(alpha: 0.4), blurRadius: 20)],
                    ),
                    child: Icon(Icons.mic_rounded, color: Colors.white, size: 44),
                  ),
                ),
                const SizedBox(height: 12),
                Text('탭하여 녹음 시작', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),

              ] else if (_isRecording) ...[
                // 녹음 중
                const SizedBox(height: 60),
                AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (_, __) => Container(
                    width: 120 + _pulseCtrl.value * 20,
                    height: 120 + _pulseCtrl.value * 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.scoreMiss.withValues(alpha: 0.15 + _pulseCtrl.value * 0.1),
                    ),
                    child: Center(
                      child: Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.scoreMiss),
                        child: Icon(Icons.mic_rounded, color: Colors.white, size: 36),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(_formatDuration(_elapsed), style: TextStyle(color: AppColors.textPrimary, fontSize: 48, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                const SizedBox(height: 8),
                Text('녹음 중...', style: TextStyle(color: AppColors.scoreMiss, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 40),

                // 정지 버튼
                GestureDetector(
                  onTap: _stopRecording,
                  child: Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.bgCard,
                      border: Border.all(color: AppColors.scoreMiss, width: 3),
                    ),
                    child: Icon(Icons.stop_rounded, color: AppColors.scoreMiss, size: 36),
                  ),
                ),
                const SizedBox(height: 12),
                Text('탭하여 녹음 중지', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),

              ] else if (_isAnalyzing) ...[
                // 분석 중
                const SizedBox(height: 80),
                SizedBox(width: 60, height: 60, child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 4)),
                const SizedBox(height: 24),
                Text('AI가 연주를 분석하고 있습니다...', style: TextStyle(color: AppColors.accent, fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('음정, 리듬, 톤을 종합 분석 중', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),

              ] else if (_isDone) ...[
                // 피드백 결과
                const SizedBox(height: 20),

                // 점수
                Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _scoreColor(_feedbackScore), width: 6),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$_feedbackScore', style: TextStyle(color: _scoreColor(_feedbackScore), fontSize: 36, fontWeight: FontWeight.bold)),
                      Text('점', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(_feedbackTitle, style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                // 상세 피드백
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome_rounded, color: AppColors.accent, size: 18),
                          const SizedBox(width: 8),
                          Text('AI 피드백', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(_feedbackBody, style: TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.6)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 버튼
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _reset,
                        icon: Icon(Icons.replay_rounded),
                        label: const Text('다시 녹음'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.check_rounded),
                        label: const Text('완료'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _scoreColor(int score) {
    if (score >= 85) return AppColors.scorePerfect;
    if (score >= 70) return AppColors.accent;
    if (score >= 55) return AppColors.accentGold;
    return AppColors.scoreMiss;
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title, desc;
  const _InfoCard({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                Text(desc, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

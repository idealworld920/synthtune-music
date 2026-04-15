import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/sheet_music_widget.dart';
import '../../../../shared/utils/motivation.dart';
import '../../../lesson/domain/models/lesson.dart';
import '../../../lesson/presentation/providers/lesson_provider.dart';
import '../providers/practice_provider.dart';

class PracticeScreen extends ConsumerWidget {
  final String lessonId;
  const PracticeScreen({super.key, required this.lessonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lesson = ref.watch(lessonByIdProvider(lessonId));

    if (lesson == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('레슨을 찾을 수 없습니다.')),
      );
    }

    final practiceState = ref.watch(practiceNotifierProvider(lesson));

    // 완료 시 자동 이동
    ref.listen(practiceNotifierProvider(lesson), (prev, next) {
      if (next.status == PracticeStatus.done && next.result != null) {
        context.push(
          RouteNames.feedback,
          extra: {
            'session': next.result,
            'lesson': lesson,
          },
        );
      }
    });

    return PopScope(
      canPop: practiceState.status != PracticeStatus.recording,
      onPopInvoked: (didPop) async {
        if (!didPop && practiceState.status == PracticeStatus.recording) {
          await ref.read(practiceNotifierProvider(lesson).notifier).stopRecording();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(lesson.title),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () async {
              if (practiceState.status == PracticeStatus.recording) {
                await ref
                    .read(practiceNotifierProvider(lesson).notifier)
                    .stopRecording();
              }
              if (context.mounted) context.pop();
            },
          ),
        ),
        body: Stack(
          children: [
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isLandscape = constraints.maxWidth > constraints.maxHeight;
                  if (isLandscape) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          // 악보 영역 (가로 모드: 왼쪽 넓게)
                          Expanded(
                            flex: 3,
                            child: _NoteDisplay(lesson: lesson, practiceState: practiceState),
                          ),
                          const SizedBox(width: 12),
                          // 컨트롤 영역 (가로 모드: 오른쪽)
                          Expanded(
                            flex: 2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _PitchMeter(state: practiceState),
                                const SizedBox(height: 16),
                                _ControlArea(lesson: lesson, state: practiceState),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // 악보 영역 (세로 모드: 더 넓게)
                        Expanded(
                          flex: 4,
                          child: _NoteDisplay(lesson: lesson, practiceState: practiceState),
                        ),
                        const SizedBox(height: 12),
                        _PitchMeter(state: practiceState),
                        const SizedBox(height: 16),
                        _ControlArea(lesson: lesson, state: practiceState),
                        const SizedBox(height: 8),
                      ],
                    ),
                  );
                },
              ),
            ),
            // 카메라 PIP (녹음 중일 때 표시)
            if (practiceState.status == PracticeStatus.recording ||
                practiceState.status == PracticeStatus.countdown)
              const Positioned(
                top: 80,
                right: 12,
                child: _CameraPip(),
              ),
          ],
        ),
      ),
    );
  }
}

class _NoteDisplay extends StatelessWidget {
  final dynamic lesson;
  final PracticeState practiceState;
  const _NoteDisplay({required this.lesson, required this.practiceState});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: practiceState.status == PracticeStatus.recording
              ? AppColors.scoreMiss.withOpacity(0.5)
              : AppColors.bgSurface,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (practiceState.status == PracticeStatus.idle) ...[
            // 악보 표시
            Expanded(
              child: SheetMusicWidget(
                notes: lesson.targetNotes as List<MusicNote>,
                instrument: lesson.instrument as String?,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 마이크 상태
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.scorePerfect.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.scorePerfect.withValues(alpha: 0.4)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.mic_rounded, color: AppColors.scorePerfect, size: 16),
                      SizedBox(width: 6),
                      Text(
                        '마이크 준비됨',
                        style: TextStyle(color: AppColors.scorePerfect, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 동기부여 응원 메시지
            Text(
              getStartMotivation(),
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.accent.withValues(alpha: 0.8), fontSize: 13, fontStyle: FontStyle.italic),
            ),
          ] else if (practiceState.status == PracticeStatus.countdown) ...[
            Expanded(
              child: SheetMusicWidget(
                notes: lesson.targetNotes as List<MusicNote>,
                instrument: lesson.instrument as String?,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${practiceState.countdownSeconds}',
              style: const TextStyle(color: AppColors.primary, fontSize: 56, fontWeight: FontWeight.bold),
            ),
            const Text('준비하세요!', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
          ] else if (practiceState.status == PracticeStatus.recording) ...[
            Expanded(
              child: SheetMusicWidget(
                notes: lesson.targetNotes as List<MusicNote>,
                instrument: lesson.instrument as String?,
                activeNoteIndex: 0, // TODO: 실시간 추적 시 업데이트
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _PulsingDot(),
                const SizedBox(width: 10),
                const Text(
                  '녹음 중',
                  style: TextStyle(color: AppColors.scoreMiss, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                Text(
                  '현재 음: ${practiceState.detectedNote}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              getRecordingEncouragement(),
              style: TextStyle(color: AppColors.scorePerfect.withValues(alpha: 0.7), fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ] else if (practiceState.status == PracticeStatus.analyzing) ...[
            Expanded(
              child: SheetMusicWidget(
                notes: lesson.targetNotes as List<MusicNote>,
                instrument: lesson.instrument as String?,
              ),
            ),
            const SizedBox(height: 12),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2.5)),
                SizedBox(width: 12),
                Text('AI가 연주를 분석하고 있습니다...', style: TextStyle(color: AppColors.accent, fontSize: 15, fontWeight: FontWeight.w600)),
              ],
            ),
          ] else if (practiceState.status == PracticeStatus.error) ...[
            const Icon(Icons.error_outline, color: AppColors.scoreMiss, size: 48),
            const SizedBox(height: 12),
            Text(
              practiceState.errorMessage ?? '오류가 발생했습니다',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.scoreMiss, fontSize: 15),
            ),
          ],
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        width: 20 + _ctrl.value * 8,
        height: 20 + _ctrl.value * 8,
        decoration: BoxDecoration(
          color: AppColors.scoreMiss.withOpacity(0.7 + _ctrl.value * 0.3),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _PitchMeter extends StatelessWidget {
  final PracticeState state;
  const _PitchMeter({required this.state});

  @override
  Widget build(BuildContext context) {
    final isRecording = state.status == PracticeStatus.recording;
    final hz = state.currentPitchHz;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.graphic_eq_rounded,
            color: isRecording ? AppColors.scoreMiss : AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '피치 미터',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: isRecording ? (hz / 1000).clamp(0.0, 1.0) : 0.0,
                    backgroundColor: AppColors.bgSurface,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            isRecording && hz > 0 ? '${hz.round()} Hz' : '- Hz',
            style: TextStyle(
              color: isRecording ? AppColors.accent : AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlArea extends ConsumerWidget {
  final dynamic lesson;
  final PracticeState state;
  const _ControlArea({required this.lesson, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(practiceNotifierProvider(lesson).notifier);

    switch (state.status) {
      case PracticeStatus.idle:
        return _BigButton(
          label: '녹음 시작',
          icon: Icons.mic_rounded,
          color: AppColors.scoreMiss,
          onTap: () => notifier.startCountdown(),
        );

      case PracticeStatus.countdown:
        return const _BigButton(
          label: '준비 중...',
          icon: Icons.timer_rounded,
          color: AppColors.textSecondary,
        );

      case PracticeStatus.recording:
        return _BigButton(
          label: '녹음 중지',
          icon: Icons.stop_rounded,
          color: AppColors.scoreMiss,
          onTap: () => notifier.stopRecording(),
        );

      case PracticeStatus.analyzing:
        return const _BigButton(
          label: 'AI 분석 중...',
          icon: Icons.auto_awesome_rounded,
          color: AppColors.accent,
        );

      case PracticeStatus.done:
      case PracticeStatus.error:
        return Column(
          children: [
            _BigButton(
              label: '다시 시도',
              icon: Icons.refresh_rounded,
              color: AppColors.primary,
              onTap: () => notifier.reset(),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: const Text('레슨으로 돌아가기'),
              style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
            ),
          ],
        );
    }
  }
}

class _BigButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _BigButton({
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 76,
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.18) : AppColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? color.withValues(alpha: 0.6) : AppColors.bgSurface,
            width: 2,
          ),
          boxShadow: active
              ? [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4))]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: active ? color : AppColors.textSecondary, size: 28),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: active ? color : AppColors.textSecondary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CameraPip extends StatefulWidget {
  const _CameraPip();

  @override
  State<_CameraPip> createState() => _CameraPipState();
}

class _CameraPipState extends State<_CameraPip> {
  CameraController? _controller;
  bool _initialized = false;
  bool _hidden = false;
  int _sizeMode = 0; // 0=small, 1=medium, 2=large

  static const _sizes = [
    (110.0, 150.0),  // small
    (170.0, 230.0),  // medium
    (250.0, 340.0),  // large
  ];

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      // 전면 카메라 우선
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      _controller = CameraController(front, ResolutionPreset.low, enableAudio: false);
      await _controller!.initialize();
      if (mounted) setState(() => _initialized = true);
    } catch (_) {
      // 카메라 사용 불가 시 무시
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hidden) {
      return GestureDetector(
        onTap: () => setState(() => _hidden = false),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.bgCard.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 1.5),
          ),
          child: const Icon(Icons.videocam_rounded, color: AppColors.primary, size: 20),
        ),
      );
    }

    final (w, h) = _sizes[_sizeMode];
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.6), width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 8)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            if (_initialized && _controller != null)
              CameraPreview(_controller!)
            else
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.videocam_off_rounded, color: AppColors.textSecondary, size: 24),
                    SizedBox(height: 4),
                    Text('카메라', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                  ],
                ),
              ),
            // 크기 조정 + 닫기 버튼
            Positioned(
              top: 2,
              right: 2,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _sizeMode = (_sizeMode + 1) % 3),
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _sizeMode == 2 ? Icons.zoom_in_map_rounded : Icons.zoom_out_map_rounded,
                        color: Colors.white, size: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => setState(() => _hidden = true),
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 14),
                    ),
                  ),
                ],
              ),
            ),
            // AI 분석 라벨
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 3),
                color: Colors.black.withValues(alpha: 0.6),
                child: const Text(
                  'AI 자세 분석',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';
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
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 음표 악보 영역
                Expanded(
                  flex: 3,
                  child: _NoteDisplay(lesson: lesson, practiceState: practiceState),
                ),
                const SizedBox(height: 20),
                // 피치 미터
                _PitchMeter(state: practiceState),
                const SizedBox(height: 24),
                // 컨트롤 버튼
                _ControlArea(lesson: lesson, state: practiceState),
                const SizedBox(height: 16),
              ],
            ),
          ),
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
            const Text('🎵', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 12),
            const Text(
              '준비가 되면\n녹음 버튼을 누르세요',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 12),
            // 마이크 권한 상태
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
            const SizedBox(height: 16),
            // 음표 미리보기
            Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: lesson.targetNotes.take(8).map<Widget>((note) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    note.noteName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                  ),
                );
              }).toList(),
            ),
          ] else if (practiceState.status == PracticeStatus.countdown) ...[
            Text(
              '${practiceState.countdownSeconds}',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 80,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              '준비하세요!',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 18),
            ),
          ] else if (practiceState.status == PracticeStatus.recording) ...[
            const _PulsingDot(),
            const SizedBox(height: 12),
            const Text(
              '녹음 중...',
              style: TextStyle(color: AppColors.scoreMiss, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '현재 음: ${practiceState.detectedNote}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 12),
            // 연주해야 할 음표
            Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: lesson.targetNotes.take(8).map<Widget>((note) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                  ),
                  child: Text(
                    note.noteName,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                  ),
                );
              }).toList(),
            ),
          ] else if (practiceState.status == PracticeStatus.analyzing) ...[
            const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 3),
            ),
            const SizedBox(height: 16),
            const Text(
              'AI 분석 중...',
              style: TextStyle(color: AppColors.accent, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '음정을 분석하고 있습니다',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
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

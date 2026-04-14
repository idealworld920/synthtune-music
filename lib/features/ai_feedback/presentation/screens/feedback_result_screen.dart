import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../../auth/presentation/providers/user_profile_provider.dart';
import '../../../lesson/domain/models/lesson.dart';
import '../../../practice/domain/models/practice_session.dart';
import '../../../progress/presentation/providers/progress_provider.dart';

class FeedbackResultScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? extra;
  const FeedbackResultScreen({super.key, this.extra});

  @override
  ConsumerState<FeedbackResultScreen> createState() =>
      _FeedbackResultScreenState();
}

class _FeedbackResultScreenState extends ConsumerState<FeedbackResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _scoreAnim;
  late AnimationController _cardsAnim;
  late Animation<double> _scoreValue;
  late Animation<double> _cardsOpacity;

  PracticeSession? _session;
  Lesson? _lesson;

  @override
  void initState() {
    super.initState();
    _session = widget.extra?['session'] as PracticeSession?;
    _lesson = widget.extra?['lesson'] as Lesson?;

    _scoreAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _cardsAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    final targetScore = _session?.score ?? 0;
    _scoreValue = Tween<double>(begin: 0, end: targetScore).animate(
      CurvedAnimation(parent: _scoreAnim, curve: Curves.easeOut),
    );
    _cardsOpacity = CurvedAnimation(parent: _cardsAnim, curve: Curves.easeIn);

    // 애니메이션 순차 실행
    _scoreAnim.forward().then((_) => _cardsAnim.forward());

    // XP 저장
    if (_session != null && _lesson != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(userProfileProvider.notifier).addXp(
              _session!.xpEarned,
              _lesson!.id,
            );
        ref.read(practiceHistoryProvider.notifier).update(
              (state) => [_session!, ...state],
            );
      });
    }
  }

  @override
  void dispose() {
    _scoreAnim.dispose();
    _cardsAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_session == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('결과가 없습니다.')),
      );
    }

    final session = _session!;
    final hitCount = session.noteResults.where((r) => r.isHit).length;
    final totalCount = session.noteResults.length;
    final avgAccuracy = totalCount > 0
        ? session.noteResults.map((r) => r.accuracy).reduce((a, b) => a + b) /
            totalCount
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('연습 결과'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.go(RouteNames.home),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // 스코어 원형
              AnimatedBuilder(
                animation: _scoreValue,
                builder: (_, __) => _ScoreCircle(
                  score: _scoreValue.value,
                  grade: session.scoreLabel,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _scoreMessage(session.score),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                session.lessonTitle,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 24),

              FadeTransition(
                opacity: _cardsOpacity,
                child: Column(
                  children: [
                    // 통계 카드
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.check_circle_outline,
                            color: AppColors.scorePerfect,
                            label: '음정 적중',
                            value: '$hitCount / $totalCount',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.percent_rounded,
                            color: AppColors.accent,
                            label: '평균 정확도',
                            value: '${(avgAccuracy * 100).round()}%',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.star_rounded,
                            color: AppColors.accentGold,
                            label: '획득 XP',
                            value: '+${session.xpEarned}',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 음표별 결과
                    if (session.noteResults.isNotEmpty) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '음표별 결과',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _NoteResultGrid(results: session.noteResults),
                      const SizedBox(height: 20),
                    ],

                    // AI 피드백 텍스트
                    _AiFeedbackCard(session: session),
                    const SizedBox(height: 24),

                    // 버튼들
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (_lesson != null) {
                            context.go('/practice/${_lesson!.id}');
                          }
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('다시 연습'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () => context.go(RouteNames.home),
                        icon: const Icon(Icons.home_rounded),
                        label: const Text('홈으로'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: AppColors.bgCard),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _scoreMessage(double score) {
    if (score >= 95) return '완벽해요! 🎉';
    if (score >= 85) return '훌륭해요! 👏';
    if (score >= 70) return '잘 했어요! 😊';
    if (score >= 55) return '조금 더 연습해봐요';
    return '계속 도전해보세요 💪';
  }
}

class _ScoreCircle extends StatelessWidget {
  final double score;
  final String grade;
  const _ScoreCircle({required this.score, required this.grade});

  @override
  Widget build(BuildContext context) {
    final color = _gradeColor(grade);
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 160,
            height: 160,
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: 10,
              backgroundColor: AppColors.bgCard,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                grade,
                style: TextStyle(
                  color: color,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${score.round()}점',
                style: TextStyle(
                  color: color.withValues(alpha: 0.85),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _gradeColor(String grade) {
    switch (grade) {
      case 'S':
        return AppColors.accentGold;
      case 'A':
        return AppColors.scorePerfect;
      case 'B':
        return AppColors.accent;
      case 'C':
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  const _StatCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
                color: color, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _NoteResultGrid extends StatelessWidget {
  final List<dynamic> results;
  const _NoteResultGrid({required this.results});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: results.map((r) {
        final isHit = r.isHit as bool;
        final accuracy = (r.accuracy as double);
        // 접근성: 색 + 아이콘 + 텍스트 레이블 병행
        final hitColor = AppColors.scorePerfect;
        final missColor = const Color(0xFFE07070); // 색맹 친화적 amber/red
        final color = isHit ? hitColor : missColor;
        return Semantics(
          label: '${r.targetNoteName} ${isHit ? '적중' : '미스'} 정확도 ${(accuracy * 100).round()}%',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isHit ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      color: color,
                      size: 15,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      r.targetNoteName as String,
                      style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${(accuracy * 100).round()}%',
                  style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 11),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _AiFeedbackCard extends StatelessWidget {
  final PracticeSession session;
  const _AiFeedbackCard({required this.session});

  String _generateFeedback() {
    final hitCount = session.noteResults.where((r) => r.isHit).length;
    final totalCount = session.noteResults.length;
    final ratio = totalCount > 0 ? hitCount / totalCount : 0;
    final missedNotes = session.noteResults
        .where((r) => !r.isHit)
        .map((r) => r.targetNoteName)
        .toList();

    final lines = <String>[];
    if (ratio >= 0.9) {
      lines.add('거의 완벽한 연주였습니다! 음정 정확도가 매우 높습니다.');
    } else if (ratio >= 0.7) {
      lines.add('전반적으로 좋은 연주였습니다. 조금만 더 연습하면 완벽해질 거에요!');
    } else {
      lines.add('계속 연습하면 분명히 실력이 늘 거에요. 포기하지 마세요!');
    }
    if (missedNotes.isNotEmpty) {
      lines.add(
          '${missedNotes.take(3).join(", ")} 음정을 좀 더 집중적으로 연습해 보세요.');
    }
    lines.add('BPM ${session.noteResults.length > 8 ? "70" : "60"}에 맞춰 천천히 반복 연습하는 것을 권장합니다.');
    return lines.join('\n\n');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('🤖', style: TextStyle(fontSize: 14)),
              ),
              const SizedBox(width: 8),
              const Text(
                'AI 피드백',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _generateFeedback(),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

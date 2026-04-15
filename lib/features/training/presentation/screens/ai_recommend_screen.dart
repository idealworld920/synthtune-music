import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/user_profile_provider.dart';
import '../../../lesson/presentation/providers/lesson_provider.dart';
import '../../../progress/presentation/providers/progress_provider.dart';

class AiRecommendScreen extends ConsumerWidget {
  const AiRecommendScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final history = ref.watch(practiceHistoryProvider);
    final allLessons = ref.watch(lessonListProvider);
    final rng = Random(DateTime.now().day);

    final instrument = profile?.selectedInstrument ?? 'piano';
    final level = profile?.currentLevel ?? 1;
    final totalSessions = history.length;
    final avgScore = history.isEmpty ? 0.0 : history.map((s) => s.score).reduce((a, b) => a + b) / history.length;

    // 취약 음표 분석
    final missedNotes = <String, int>{};
    for (final s in history) {
      for (final nr in s.noteResults) {
        if (!nr.isHit) missedNotes[nr.targetNoteName] = (missedNotes[nr.targetNoteName] ?? 0) + 1;
      }
    }
    final weakNotes = missedNotes.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final topWeak = weakNotes.take(3).map((e) => e.key).toList();

    // AI 추천 계산
    final recCount = level <= 2 ? 3 : level <= 5 ? 4 : 5;
    final recMinutes = level <= 2 ? 15 : level <= 5 ? 25 : 40;
    final recGoal = avgScore < 70 ? '기초 음정 정확도 70% 달성' : avgScore < 85 ? '정확도 85% 이상 유지' : '새로운 곡 도전 + 완벽 연주';

    // 추천 곡 (악기 매칭 + 난이도 적절)
    final instrumentLessons = allLessons.where((l) => l.instrument == instrument).toList();
    final playedIds = history.map((s) => s.lessonId).toSet();
    final unplayed = instrumentLessons.where((l) => !playedIds.contains(l.id) && !l.isLocked).toList();
    final lowScore = history.where((s) => s.score < 80).toList();

    // 복습 곡 (점수 낮은 순)
    lowScore.sort((a, b) => a.score.compareTo(b.score));
    final reviewLessons = lowScore.take(2).map((s) {
      return instrumentLessons.cast().firstWhere((l) => l?.id == s.lessonId, orElse: () => null);
    }).where((l) => l != null).toList();

    // 새 곡
    unplayed.shuffle(rng);
    final newLessons = unplayed.take(3).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('AI 추천 연습')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI 분석 요약
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.accent.withValues(alpha: 0.15), AppColors.primary.withValues(alpha: 0.1)]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded, color: AppColors.accent, size: 22),
                      const SizedBox(width: 8),
                      Text('AI 분석 결과', style: TextStyle(color: AppColors.accent, fontSize: 17, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _MiniStat(label: 'Lv.', value: '$level', color: AppColors.primary),
                      const SizedBox(width: 12),
                      _MiniStat(label: '평균', value: '${avgScore.round()}점', color: avgScore >= 80 ? AppColors.scorePerfect : AppColors.accentGold),
                      const SizedBox(width: 12),
                      _MiniStat(label: '연습', value: '$totalSessions회', color: AppColors.accent),
                    ],
                  ),
                  if (topWeak.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text('취약 음표: ', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ...topWeak.map((n) => Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.scoreMiss.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                          child: Text(n, style: TextStyle(color: AppColors.scoreMiss, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                        )),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 추천 목표
            Text('추천 목표', style: TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14)),
              child: Column(
                children: [
                  _RecItem(icon: Icons.flag_rounded, label: '목표', value: recGoal, color: AppColors.primary),
                  const SizedBox(height: 10),
                  _RecItem(icon: Icons.repeat_rounded, label: '추천 횟수', value: '하루 $recCount회', color: AppColors.accent),
                  const SizedBox(height: 10),
                  _RecItem(icon: Icons.timer_rounded, label: '추천 시간', value: '하루 $recMinutes분', color: AppColors.accentGold),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 복습 추천
            if (reviewLessons.isNotEmpty) ...[
              Text('복습 추천', style: TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('점수가 낮은 곡을 다시 연습하세요', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 12),
              ...reviewLessons.map((l) => _LessonCard(lesson: l, tag: '복습', tagColor: AppColors.scoreMiss, onTap: () => context.push('/practice/${l.id}'))),
              const SizedBox(height: 20),
            ],

            // 새 곡 추천
            if (newLessons.isNotEmpty) ...[
              Text('새 곡 도전', style: TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('아직 연습하지 않은 곡입니다', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 12),
              ...newLessons.map((l) => _LessonCard(lesson: l, tag: '새 곡', tagColor: AppColors.scorePerfect, onTap: () => context.push('/lessons/${l.id}'))),
            ],

            if (reviewLessons.isEmpty && newLessons.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14)),
                child: Center(child: Text('연습 기록이 쌓이면 AI가 맞춤 추천을 해드려요!\n먼저 레슨에서 연습을 시작하세요.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary))),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _RecItem extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _RecItem({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const Spacer(),
        Text(value, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }
}

class _LessonCard extends StatelessWidget {
  final dynamic lesson;
  final String tag;
  final Color tagColor;
  final VoidCallback onTap;
  const _LessonCard({required this.lesson, required this.tag, required this.tagColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: tagColor.withValues(alpha: 0.2))),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: tagColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
              child: Center(child: Text(lesson.imageEmoji as String, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lesson.title as String, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(color: tagColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                        child: Text(tag, style: TextStyle(color: tagColor, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 6),
                      Text('${lesson.durationMinutes}분 · ${lesson.difficultyLabel}', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

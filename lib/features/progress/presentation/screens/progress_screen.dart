import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../../auth/presentation/providers/user_profile_provider.dart';
import '../../../community/domain/models/community_post.dart';
import '../../../community/presentation/providers/community_provider.dart';
import '../providers/progress_provider.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(userProfileProvider);
    final weeklyData = ref.watch(weeklyDataProvider);
    final scoreHistory = ref.watch(scoreHistoryProvider);
    final history = ref.watch(practiceHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('진도'),
        actions: [
          IconButton(
            icon: Icon(Icons.save_alt_rounded, size: 20, color: AppColors.textSecondary),
            tooltip: '저장',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('리포트가 저장되었습니다.'), backgroundColor: AppColors.scorePerfect),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded, size: 20, color: AppColors.primary),
            tooltip: '공유',
            onPressed: () {
              final profile = ref.read(userProfileProvider).valueOrNull;
              final hist = ref.read(practiceHistoryProvider);
              final avg = hist.isEmpty ? 0.0 : hist.map((s) => s.score).reduce((a, b) => a + b) / hist.length;
              ref.read(communityProvider.notifier).addPost(CommunityPost(
                id: 'prog_${DateTime.now().millisecondsSinceEpoch}',
                userId: profile?.uid ?? 'me',
                userName: profile?.displayName ?? '나',
                content: '📈 학습 진도 공유\nLv.${profile?.currentLevel ?? 1} | XP ${profile?.xpPoints ?? 0} | 평균 ${avg.round()}점\n스트릭 ${profile?.streakDays ?? 0}일 연속!',
                lessonTitle: '학습 진도',
                instrument: profile?.selectedInstrument ?? 'piano',
                score: avg,
                likes: 0, isLiked: false,
                createdAt: DateTime.now(),
              ));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('커뮤니티에 공유되었습니다.'), backgroundColor: AppColors.primary),
              );
            },
          ),
          TextButton.icon(
            onPressed: () => context.push(RouteNames.advancedReport),
            icon: const Icon(Icons.analytics_rounded, size: 18, color: AppColors.accentGold),
            label: Text('고급', style: TextStyle(color: AppColors.accentGold, fontSize: 13)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 레벨 & XP 카드
            profileState.when(
              loading: () => const SizedBox(height: 100),
              error: (_, __) => const SizedBox.shrink(),
              data: (profile) =>
                  profile != null ? _LevelCard(profile: profile) : const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),

            // 통계 요약
            profileState.maybeWhen(
              data: (profile) => profile != null
                  ? _StatsRow(profile: profile)
                  : const SizedBox.shrink(),
              orElse: () => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            // 주간 연습 차트
            Text('이번 주 연습 시간', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _WeeklyBarChart(data: weeklyData),
            const SizedBox(height: 24),

            // 점수 추이
            Text('점수 변화', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _ScoreLineChart(scores: scoreHistory),
            const SizedBox(height: 24),

            // 연습 기록
            Text('최근 연습 기록', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...history.take(5).map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _HistoryCard(session: s),
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final dynamic profile;
  const _LevelCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.4), AppColors.accent.withOpacity(0.2)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary.withOpacity(0.3),
                child: Text(
                  'Lv\n${profile.currentLevel}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.displayName,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.levelLabel,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 22)),
                  Text(
                    '${profile.streakDays}일',
                    style: TextStyle(
                      color: AppColors.accentGold,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${profile.xpPoints} XP',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
              ),
              Text(
                '${profile.xpForNextLevel} XP (Lv.${profile.currentLevel + 1})',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: profile.xpProgress,
              backgroundColor: AppColors.bgCard,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final dynamic profile;
  const _StatsRow({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MiniStatCard(
            value: '${profile.totalPracticeMinutes}',
            unit: '분',
            label: '총 연습 시간',
            color: AppColors.accent,
            icon: Icons.timer_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStatCard(
            value: '${profile.completedLessonIds.length}',
            unit: '개',
            label: '완료한 레슨',
            color: AppColors.scorePerfect,
            icon: Icons.check_circle_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStatCard(
            value: '${profile.xpPoints}',
            unit: 'XP',
            label: '경험치',
            color: AppColors.accentGold,
            icon: Icons.star_rounded,
          ),
        ),
      ],
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String value;
  final String unit;
  final String label;
  final Color color;
  final IconData icon;
  const _MiniStatCard({
    required this.value,
    required this.unit,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _WeeklyBarChart extends StatelessWidget {
  final List<WeeklyData> data;
  const _WeeklyBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxVal = data.map((d) => d.minutes).reduce((a, b) => a > b ? a : b).toDouble();

    return Container(
      height: 160,
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxVal > 0 ? maxVal * 1.2 : 50,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, meta) {
                  if (val.toInt() < data.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        data[val.toInt()].day,
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 11),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          barGroups: List.generate(data.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: data[i].minutes.toDouble(),
                  color: AppColors.primary.withOpacity(data[i].minutes > 0 ? 1 : 0.3),
                  width: 22,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _ScoreLineChart extends StatelessWidget {
  final List<double> scores;
  const _ScoreLineChart({required this.scores});

  @override
  Widget build(BuildContext context) {
    if (scores.isEmpty) {
      return Container(
        height: 130,
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text('연습 기록이 없습니다.', style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    final spots = scores.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value);
    }).toList();

    return Container(
      height: 130,
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 100,
          lineTouchData: const LineTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 50,
                getTitlesWidget: (val, meta) => Text(
                  '${val.round()}',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
                ),
              ),
            ),
            bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (_) => const FlLine(
              color: Color(0xFF21262D),
              strokeWidth: 1,
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.accent,
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                  radius: 3,
                  color: AppColors.accent,
                  strokeWidth: 0,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.accent.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final dynamic session;
  const _HistoryCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final score = session.score as double;
    final gradeColor = _gradeColor(session.scoreLabel as String);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: gradeColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                session.scoreLabel as String,
                style: TextStyle(
                  color: gradeColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.lessonTitle as String,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(session.createdAt as DateTime),
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '${score.round()}점',
            style: TextStyle(
              color: gradeColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
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

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return '오늘';
    if (diff.inDays == 1) return '어제';
    return '${diff.inDays}일 전';
  }
}

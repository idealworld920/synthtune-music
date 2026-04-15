import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../../auth/presentation/providers/user_profile_provider.dart';
import '../../../subscription/domain/subscription_tier.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../providers/progress_provider.dart';

class AdvancedReportScreen extends ConsumerWidget {
  const AdvancedReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tier = ref.watch(subscriptionTierProvider);
    final isPremium = tier == SubscriptionTier.premium || tier == SubscriptionTier.student;

    return Scaffold(
      appBar: AppBar(title: const Text('고급 리포트')),
      body: isPremium
          ? _ReportContent()
          : _PremiumGate(),
    );
  }
}

class _PremiumGate extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.accentGold.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_rounded, color: AppColors.accentGold, size: 40),
            ),
            const SizedBox(height: 24),
            const Text(
              '프리미엄 기능',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            const Text(
              '고급 리포트에서 상세한 음정 분석,\nAI 맞춤 연습 루틴, 연습 방법을\n확인할 수 있습니다.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 200,
              height: 48,
              child: ElevatedButton(
                onPressed: () => context.push(RouteNames.subscription),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGold,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('업그레이드', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final history = ref.watch(practiceHistoryProvider);
    final instrument = profile?.selectedInstrument ?? 'piano';
    final instrumentLabel = _instrumentName(instrument);

    // 분석 데이터 (mock)
    final avgScore = history.isEmpty
        ? 0.0
        : history.map((s) => s.score).reduce((a, b) => a + b) / history.length;
    final totalSessions = history.length;
    final weakNotes = _findWeakNotes(history);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── 종합 분석 ───
          _SectionTitle(icon: Icons.analytics_rounded, title: '종합 분석'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _MetricCard(label: '평균 점수', value: '${avgScore.round()}점', color: AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(child: _MetricCard(label: '총 연습', value: '$totalSessions회', color: AppColors.accent)),
              const SizedBox(width: 12),
              Expanded(child: _MetricCard(label: '악기', value: instrumentLabel, color: AppColors.accentGold)),
            ],
          ),
          const SizedBox(height: 24),

          // ─── 음정 정확도 차트 ───
          _SectionTitle(icon: Icons.bar_chart_rounded, title: '음정 정확도 분석'),
          const SizedBox(height: 12),
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: _PitchAccuracyChart(),
          ),
          const SizedBox(height: 24),

          // ─── 취약 음표 ───
          _SectionTitle(icon: Icons.warning_amber_rounded, title: '취약 음표'),
          const SizedBox(height: 12),
          if (weakNotes.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12)),
              child: const Center(
                child: Text('연습 기록이 쌓이면 취약 음표가 표시됩니다.', style: TextStyle(color: AppColors.textSecondary)),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: weakNotes.map((n) => Chip(
                label: Text(n, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                backgroundColor: const Color(0xFFE07070),
                side: BorderSide.none,
              )).toList(),
            ),
          const SizedBox(height: 24),

          // ─── AI 추천 연습 루틴 ───
          _SectionTitle(icon: Icons.auto_awesome_rounded, title: 'AI 추천 연습 루틴'),
          const SizedBox(height: 12),
          _RoutineCard(
            day: '오늘',
            items: [
              _RoutineItem('기초 스케일 (C장조)', '5분', Icons.music_note_rounded),
              _RoutineItem('취약 음표 반복 연습', '10분', Icons.repeat_rounded),
              if (totalSessions < 5)
                _RoutineItem('반짝반짝 작은별', '10분', Icons.star_rounded)
              else
                _RoutineItem('나비야 나비야', '10분', Icons.flutter_dash_rounded),
            ],
          ),
          const SizedBox(height: 12),
          _RoutineCard(
            day: '내일',
            items: [
              _RoutineItem('G장조 스케일', '5분', Icons.music_note_rounded),
              _RoutineItem('곰 세 마리', '10분', Icons.pets_rounded),
              _RoutineItem('음정 집중 훈련', '8분', Icons.tune_rounded),
            ],
          ),
          const SizedBox(height: 12),
          _RoutineCard(
            day: '모레',
            items: [
              _RoutineItem('복습: 이전 곡 돌아보기', '10분', Icons.replay_rounded),
              _RoutineItem('새 곡 도전', '15분', Icons.new_releases_rounded),
              _RoutineItem('자유 연습', '10분', Icons.piano_rounded),
            ],
          ),
          const SizedBox(height: 24),

          // ─── 연습 방법 팁 ───
          _SectionTitle(icon: Icons.lightbulb_rounded, title: '연습 방법 가이드'),
          const SizedBox(height: 12),
          _TipCard(
            title: '느린 템포로 시작하기',
            body: '새로운 곡은 정확한 템포보다 정확한 음정이 우선입니다. BPM을 50%로 낮추고 정확하게 연주한 후 점차 빠르게 올려보세요.',
            icon: Icons.speed_rounded,
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          _TipCard(
            title: '반복 구간 연습',
            body: '틀리는 부분만 반복해서 연습하세요. 4마디를 10번 반복하는 것이 전체를 2번 치는 것보다 효과적입니다.',
            icon: Icons.loop_rounded,
            color: AppColors.accent,
          ),
          const SizedBox(height: 12),
          _TipCard(
            title: '매일 꾸준히 연습',
            body: '하루 15분 연습이 일주일에 2시간 몰아서 하는 것보다 효과적입니다. 스트릭을 유지하며 꾸준히 연습하세요.',
            icon: Icons.calendar_today_rounded,
            color: AppColors.accentGold,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _instrumentName(String id) {
    switch (id) {
      case 'piano': return '피아노';
      case 'guitar': return '기타';
      case 'drums': return '드럼';
      case 'violin': return '바이올린';
      default: return id;
    }
  }

  List<String> _findWeakNotes(List<dynamic> history) {
    if (history.isEmpty) return [];
    // Mock: 연습 기록에서 자주 틀리는 음표
    final missed = <String, int>{};
    for (final session in history) {
      for (final nr in session.noteResults) {
        if (!nr.isHit) {
          missed[nr.targetNoteName] = (missed[nr.targetNoteName] ?? 0) + 1;
        }
      }
    }
    final sorted = missed.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).map((e) => e.key).toList();
  }
}

// ─── 위젯들 ───

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MetricCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}

class _PitchAccuracyChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Mock data: 음이름별 정확도
    final data = [
      ('C', 0.92), ('D', 0.85), ('E', 0.88), ('F', 0.65),
      ('G', 0.90), ('A', 0.78), ('B', 0.72),
    ];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 1.0,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (v, _) => Text(
                '${(v * 100).round()}%',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final idx = v.toInt();
                if (idx >= 0 && idx < data.length) {
                  return Text(data[idx].$1, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12));
                }
                return const Text('');
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (v) => FlLine(color: AppColors.bgSurface, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(data.length, (i) {
          final accuracy = data[i].$2;
          final color = accuracy >= 0.8 ? AppColors.scorePerfect
              : accuracy >= 0.6 ? AppColors.accent
              : const Color(0xFFE07070);
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: accuracy,
                color: color,
                width: 18,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _RoutineItem {
  final String title;
  final String duration;
  final IconData icon;
  const _RoutineItem(this.title, this.duration, this.icon);
}

class _RoutineCard extends StatelessWidget {
  final String day;
  final List<_RoutineItem> items;
  const _RoutineCard({required this.day, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(day, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Icon(item.icon, color: AppColors.textSecondary, size: 18),
                const SizedBox(width: 10),
                Expanded(child: Text(item.title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(6)),
                  child: Text(item.duration, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final String title;
  final String body;
  final IconData icon;
  final Color color;
  const _TipCard({required this.title, required this.body, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 6),
                Text(body, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

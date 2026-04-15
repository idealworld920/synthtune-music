import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../lesson/presentation/providers/lesson_provider.dart';
import '../../../progress/presentation/providers/progress_provider.dart';
import 'ai_recommend_screen.dart';
import 'free_practice_screen.dart';

class TrainingScreen extends ConsumerStatefulWidget {
  const TrainingScreen({super.key});

  @override
  ConsumerState<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends ConsumerState<TrainingScreen> {
  int _targetCount = 3;
  int _targetMinutes = 15;
  String _goal = '';
  int _completedToday = 0;
  bool _showAchievement = false;

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(practiceHistoryProvider);
    final todayHistory = history.where((s) {
      final now = DateTime.now();
      return s.createdAt.year == now.year && s.createdAt.month == now.month && s.createdAt.day == now.day;
    }).toList();
    _completedToday = todayHistory.length;

    final isGoalMet = _completedToday >= _targetCount;

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)?.practiceStart ?? '연습')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 오늘의 목표
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary.withValues(alpha: 0.2), AppColors.accent.withValues(alpha: 0.1)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.flag_rounded, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('오늘의 목표', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      if (isGoalMet)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.scorePerfect.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                          child: Text('달성!', style: TextStyle(color: AppColors.scorePerfect, fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 진행률
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text('$_completedToday / $_targetCount회', style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: (_completedToday / _targetCount).clamp(0.0, 1.0),
                                backgroundColor: AppColors.bgCard,
                                valueColor: AlwaysStoppedAnimation(isGoalMet ? AppColors.scorePerfect : AppColors.primary),
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        children: [
                          Icon(Icons.timer_rounded, color: AppColors.accent, size: 20),
                          Text('$_targetMinutes분', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                  if (_goal.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text('목표: $_goal', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontStyle: FontStyle.italic)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 목표 설정 버튼
            OutlinedButton.icon(
              onPressed: () => _showGoalSettings(context),
              icon: Icon(Icons.settings_rounded, size: 18),
              label: const Text('목표 설정'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: BorderSide(color: AppColors.bgCard),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),

            // 연습 시작
            Text('연습하기', style: TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _TrainingOptionCard(
              icon: Icons.play_circle_rounded,
              title: '새 연습 시작',
              desc: '레슨을 선택해서 연습하세요',
              color: AppColors.primary,
              onTap: () => context.go('/lessons'),
            ),
            const SizedBox(height: 10),
            _TrainingOptionCard(
              icon: Icons.replay_rounded,
              title: '복습하기',
              desc: '이전에 연습한 곡을 다시 연습',
              color: AppColors.accent,
              onTap: () => _showReviewList(context),
            ),
            const SizedBox(height: 10),
            _TrainingOptionCard(
              icon: Icons.auto_awesome_rounded,
              title: 'AI 추천 연습',
              desc: '데이터 기반 맞춤 추천 목표·곡',
              color: AppColors.accentGold,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiRecommendScreen())),
            ),
            const SizedBox(height: 10),
            _TrainingOptionCard(
              icon: Icons.music_off_rounded,
              title: '자유 연습',
              desc: '어떤 곡이든 녹음하면 AI가 피드백',
              color: AppColors.scoreMiss,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FreePracticeScreen())),
            ),
            const SizedBox(height: 24),

            // 오늘 연습 기록
            Text('오늘 연습 기록', style: TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (todayHistory.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14)),
                child: Center(child: Text('아직 오늘 연습 기록이 없어요.\n첫 연습을 시작해보세요!', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary))),
              )
            else
              ...todayHistory.map((s) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                      child: Center(child: Text(s.scoreLabel, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.lessonTitle, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                          Text('${s.score.round()}점 · +${s.xpEarned} XP', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                    Text('${s.createdAt.hour}:${s.createdAt.minute.toString().padLeft(2, '0')}', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              )),

            // 달성 메시지
            if (isGoalMet && !_showAchievement) ...[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => setState(() => _showAchievement = true),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.scorePerfect.withValues(alpha: 0.2), AppColors.accentGold.withValues(alpha: 0.15)]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Text('🎉', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('목표 달성! 대단해요!', style: TextStyle(color: AppColors.scorePerfect, fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('오늘 $_completedToday회 연습 완료! 꾸준함이 실력입니다.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showGoalSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('목표 설정', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Text('연습 횟수', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              Slider(
                value: _targetCount.toDouble(),
                min: 1, max: 10, divisions: 9,
                label: '$_targetCount회',
                activeColor: AppColors.primary,
                onChanged: (v) { setSheetState(() => _targetCount = v.round()); setState(() {}); },
              ),
              Text('연습 시간', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              Slider(
                value: _targetMinutes.toDouble(),
                min: 5, max: 60, divisions: 11,
                label: '$_targetMinutes분',
                activeColor: AppColors.accent,
                onChanged: (v) { setSheetState(() => _targetMinutes = v.round()); setState(() {}); },
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (v) => setState(() => _goal = v),
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: '목표를 입력하세요 (예: 반짝반짝 작은별 90점 이상)',
                  hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  filled: true, fillColor: AppColors.bgCard,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(AppLocalizations.of(context)?.save ?? '저장'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showReviewList(BuildContext context) {
    final history = ref.read(practiceHistoryProvider);
    final unique = <String, dynamic>{};
    for (final s in history) { unique[s.lessonId] = s; }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('복습하기', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (unique.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Center(child: Text('연습 기록이 없습니다.', style: TextStyle(color: AppColors.textSecondary))),
              )
            else
              ...unique.values.take(5).map((s) => ListTile(
                leading: Icon(Icons.replay_rounded, color: AppColors.accent),
                title: Text(s.lessonTitle, style: TextStyle(color: AppColors.textPrimary)),
                subtitle: Text('최고 ${s.score.round()}점', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                trailing: Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/practice/${s.lessonId}');
                },
              )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _TrainingOptionCard extends StatelessWidget {
  final IconData icon;
  final String title, desc;
  final Color color;
  final VoidCallback onTap;
  const _TrainingOptionCard({required this.icon, required this.title, required this.desc, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
                  Text(desc, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
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

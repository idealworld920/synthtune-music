import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../../auth/presentation/providers/user_profile_provider.dart';
import '../../../subscription/domain/subscription_tier.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../../domain/models/lesson.dart';
import '../providers/lesson_provider.dart';
import 'tutorial_screen.dart';

class LessonsScreen extends ConsumerWidget {
  const LessonsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(selectedInstrumentFilterProvider);
    final lessons = ref.watch(filteredLessonsProvider);
    final isStandard = ref.watch(isStandardOrAboveProvider);
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final categoryFilter = ref.watch(selectedCategoryFilterProvider);
    final selectedInstrument = profile?.selectedInstrument ?? 'piano';

    final filters = [
      ('all', '전체', '🎼'),
      ('piano', '피아노', '🎹'),
      ('guitar', '기타', '🎸'),
      ('drums', '드럼', '🥁'),
      ('violin', '바이올린', '🎻'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('레슨'),
      ),
      body: Column(
        children: [
          // 악기 필터 탭
          SizedBox(
            height: 52,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filters.length,
              itemBuilder: (context, i) {
                final f = filters[i];
                final isSelected = filter == f.$1;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      // 무료 티어: 선택한 악기 + 전체만 접근 가능
                      if (!isStandard && f.$1 != 'all' && f.$1 != selectedInstrument) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('스탠다드 이상 구독 시 전체 악기를 이용할 수 있습니다.'),
                            action: SnackBarAction(
                              label: '업그레이드',
                              onPressed: () => context.push(RouteNames.subscription),
                            ),
                            backgroundColor: AppColors.bgCard,
                          ),
                        );
                        return;
                      }
                      ref.read(selectedInstrumentFilterProvider.notifier).state = f.$1;
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.bgCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.bgSurface,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(f.$3, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text(
                            f.$2,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // 카테고리 탭
          _CategoryTabs(ref: ref),
          // 난이도 필터
          _DifficultyTabs(ref: ref),
          // 레슨 목록 or 특수 탭 안내
          Expanded(
            child: categoryFilter == 'tutorial'
                ? _TutorialList(selectedInstrument: filter == 'all' ? (profile?.selectedInstrument ?? 'piano') : filter)
                : categoryFilter == 'my' && lessons.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.create_rounded, color: AppColors.accentGold, size: 56),
                        const SizedBox(height: 16),
                        Text('나만의 음악을 만들고\n연습하자!', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('창작 탭에서 악보를 만들고\n여기서 연습할 수 있어요', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => context.push(RouteNames.compose),
                          icon: Icon(Icons.create_rounded),
                          label: const Text('악보 만들기'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentGold,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ],
                    ),
                  )
                : lessons.isEmpty
                    ? Center(child: Text('해당 조건의 레슨이 없습니다.', style: TextStyle(color: AppColors.textSecondary)))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: lessons.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) => _LessonListCard(lesson: lessons[i]),
                      ),
          ),
        ],
      ),
    );
  }
}

class _LessonListCard extends StatelessWidget {
  final Lesson lesson;
  const _LessonListCard({required this.lesson});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.instrumentColors[lesson.instrument] ?? AppColors.primary;

    return GestureDetector(
      onTap: lesson.isLocked
          ? () => _showLockedDialog(context)
          : () => context.push('/lessons/${lesson.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: lesson.isLocked
                ? AppColors.bgSurface
                : color.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            // 이모지 아이콘
            Stack(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: lesson.isLocked
                        ? AppColors.bgSurface
                        : color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      lesson.isLocked ? '🔒' : lesson.imageEmoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: TextStyle(
                      color: lesson.isLocked
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    lesson.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _Chip(label: lesson.instrumentLabel, color: color),
                      const SizedBox(width: 6),
                      _Chip(label: lesson.difficultyLabel, color: _difficultyColor(lesson.difficulty)),
                      const SizedBox(width: 6),
                      _Chip(label: '${lesson.durationMinutes}분', color: AppColors.textSecondary),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                if (!lesson.isLocked)
                  const Icon(Icons.play_circle_rounded,
                      color: AppColors.primary, size: 32),
                const SizedBox(height: 4),
                Text(
                  '+${lesson.xpReward} XP',
                  style: const TextStyle(
                    color: AppColors.accentGold,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _difficultyColor(String difficulty) {
    switch (difficulty) {
      case 'beginner':
        return AppColors.scorePerfect;
      case 'intermediate':
        return AppColors.accent;
      case 'advanced':
        return AppColors.scoreMiss;
      default:
        return AppColors.textSecondary;
    }
  }

  void _showLockedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: Text('잠긴 레슨', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          '이전 레슨을 먼저 완료해야 해제됩니다.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('확인', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style:
              TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }
}

class _CategoryTabs extends StatelessWidget {
  final WidgetRef ref;
  const _CategoryTabs({required this.ref});

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(selectedCategoryFilterProvider);
    final categories = [
      ('all', '전체', Icons.apps_rounded),
      ('tutorial', '악기 입문', Icons.school_rounded),
      ('scale', '기본 스케일', Icons.piano_rounded),
      ('nursery', '동요', Icons.child_care_rounded),
      ('classic', '클래식', Icons.library_music_rounded),
      ('skill', '스킬', Icons.fitness_center_rounded),
      ('my', '나만의 음악', Icons.create_rounded),
    ];

    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: categories.length,
        itemBuilder: (context, i) {
          final c = categories[i];
          final isSelected = selected == c.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                if (c.$1 == 'my') {
                  final tier = ref.read(subscriptionTierProvider);
                  if (tier != SubscriptionTier.premium && tier != SubscriptionTier.student) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('프리미엄 구독 시 나만의 음악을 이용할 수 있습니다.'),
                        action: SnackBarAction(label: '업그레이드', onPressed: () => context.push(RouteNames.subscription)),
                        backgroundColor: AppColors.bgCard,
                      ),
                    );
                    return;
                  }
                }
                ref.read(selectedCategoryFilterProvider.notifier).state = c.$1;
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.accent : AppColors.bgSurface,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(c.$3, size: 15, color: isSelected ? Colors.white : AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      c.$2,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DifficultyTabs extends StatelessWidget {
  final WidgetRef ref;
  const _DifficultyTabs({required this.ref});

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(selectedDifficultyFilterProvider);
    final difficulties = [
      ('all', '전체', null),
      ('beginner', 'Easy', AppColors.scorePerfect),
      ('intermediate', 'Medium', AppColors.accentGold),
      ('advanced', 'Hard', AppColors.scoreMiss),
    ];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        itemCount: difficulties.length,
        itemBuilder: (context, i) {
          final d = difficulties[i];
          final isSelected = selected == d.$1;
          final color = d.$3 ?? AppColors.textSecondary;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => ref.read(selectedDifficultyFilterProvider.notifier).state = d.$1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isSelected ? color : AppColors.bgSurface),
                ),
                child: Text(d.$2, style: TextStyle(
                  color: isSelected ? color : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                )),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TutorialList extends StatelessWidget {
  final String selectedInstrument;
  const _TutorialList({required this.selectedInstrument});

  @override
  Widget build(BuildContext context) {
    final instruments = [
      ('piano', '피아노', '🎹', '건반 악기의 대표'),
      ('guitar', '기타', '🎸', '6줄 현악기'),
      ('violin', '바이올린', '🎻', '활로 연주하는 현악기'),
      ('drums', '드럼', '🥁', '리듬의 기초 타악기'),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text('악기를 처음 접하시나요?\n입문 튜토리얼로 시작해보세요!', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        ),
        ...instruments.map((inst) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TutorialScreen(instrument: inst.$1))),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: inst.$1 == selectedInstrument ? AppColors.primary.withValues(alpha: 0.5) : AppColors.bgSurface),
              ),
              child: Row(
                children: [
                  Text(inst.$3, style: const TextStyle(fontSize: 36)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${inst.$2} 입문', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('${inst.$4} · 소개/자세/음위치/운지법', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
        )),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/lesson.dart';
import '../providers/lesson_provider.dart';

class LessonsScreen extends ConsumerWidget {
  const LessonsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(selectedInstrumentFilterProvider);
    final lessons = ref.watch(filteredLessonsProvider);

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
                    onTap: () => ref
                        .read(selectedInstrumentFilterProvider.notifier)
                        .state = f.$1,
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
          // 레슨 목록
          Expanded(
            child: ListView.separated(
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
                    style: const TextStyle(
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
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: const Text('잠긴 레슨', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          '이전 레슨을 먼저 완료해야 해제됩니다.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인', style: TextStyle(color: AppColors.primary)),
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

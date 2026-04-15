import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/sheet_music_widget.dart';
import '../../domain/models/lesson.dart';
import '../providers/lesson_provider.dart';

class LessonDetailScreen extends ConsumerWidget {
  final String lessonId;
  const LessonDetailScreen({super.key, required this.lessonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lesson = ref.watch(lessonByIdProvider(lessonId));

    if (lesson == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('레슨을 찾을 수 없습니다.', style: TextStyle(color: AppColors.textPrimary)),
        ),
      );
    }

    final color = AppColors.instrumentColors[lesson.instrument] ?? AppColors.primary;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 헤더
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back_ios_rounded, size: 16),
              ),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.8), AppColors.bgDark],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Text(lesson.imageEmoji, style: const TextStyle(fontSize: 64)),
                    const SizedBox(height: 12),
                    Text(
                      lesson.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 콘텐츠
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 태그 행
                  Row(
                    children: [
                      _InfoChip(label: lesson.instrumentLabel, color: color, icon: Icons.music_note_rounded),
                      const SizedBox(width: 8),
                      _InfoChip(label: lesson.difficultyLabel, color: _difficultyColor(lesson.difficulty), icon: Icons.bar_chart_rounded),
                      const SizedBox(width: 8),
                      _InfoChip(label: '${lesson.durationMinutes}분', color: AppColors.textSecondary, icon: Icons.timer_outlined),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 설명
                  Text('레슨 소개', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(lesson.description, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 24),

                  // 보상 카드
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.accentGold.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Text('🏆', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('완료 보상', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            Text(
                              '+${lesson.xpReward} XP',
                              style: const TextStyle(
                                color: AppColors.accentGold,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 악보
                  Text('악보 (${lesson.targetNotes.length}개 음표)',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  SheetMusicWidget(
                    notes: lesson.targetNotes,
                    instrument: lesson.instrument,
                    height: 200,
                  ),
                  const SizedBox(height: 28),

                  // 연습 시작 버튼
                  if (!lesson.isLocked)
                    PrimaryButton(
                      label: '연습 시작',
                      icon: Icons.mic_rounded,
                      onPressed: () => context.push('/practice/${lesson.id}'),
                    )
                  else
                    Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_outline, color: AppColors.textSecondary),
                            SizedBox(width: 8),
                            Text('이전 레슨을 먼저 완료해주세요',
                                style: TextStyle(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
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
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  const _InfoChip({required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _NoteList extends StatelessWidget {
  final Lesson lesson;
  const _NoteList({required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: lesson.targetNotes.map((note) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.bgCard),
          ),
          child: Text(
            note.noteName,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              fontFamily: 'monospace',
            ),
          ),
        );
      }).toList(),
    );
  }
}

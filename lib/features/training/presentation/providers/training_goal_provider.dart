import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 오늘의 연습 목표 (연습 화면과 AI 추천 화면이 공유)
class TrainingGoal {
  final int targetCount;
  final int targetMinutes;
  final String goal;

  const TrainingGoal({
    this.targetCount = 3,
    this.targetMinutes = 15,
    this.goal = '',
  });

  TrainingGoal copyWith({int? targetCount, int? targetMinutes, String? goal}) {
    return TrainingGoal(
      targetCount: targetCount ?? this.targetCount,
      targetMinutes: targetMinutes ?? this.targetMinutes,
      goal: goal ?? this.goal,
    );
  }
}

/// AI 추천 화면에서 설정한 목표가 연습 화면 "오늘의 목표"에 반영된다.
final trainingGoalProvider =
    StateProvider<TrainingGoal>((ref) => const TrainingGoal());

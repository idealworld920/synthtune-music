import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

/// 연습 목표를 관리하고 SharedPreferences에 영속화한다.
/// AI 추천 화면에서 설정한 목표가 연습 화면 "오늘의 목표"에 반영되며,
/// 앱을 재시작해도 마지막 목표가 유지된다.
class TrainingGoalNotifier extends StateNotifier<TrainingGoal> {
  TrainingGoalNotifier() : super(const TrainingGoal()) {
    _load();
  }

  static const _kCount = 'training_goal_count';
  static const _kMinutes = 'training_goal_minutes';
  static const _kGoal = 'training_goal_text';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_kCount);
    final minutes = prefs.getInt(_kMinutes);
    final goal = prefs.getString(_kGoal);
    if (!mounted) return;
    if (count == null && minutes == null && goal == null) return;
    state = TrainingGoal(
      targetCount: count ?? state.targetCount,
      targetMinutes: minutes ?? state.targetMinutes,
      goal: goal ?? state.goal,
    );
  }

  Future<void> setGoal(TrainingGoal goal) async {
    state = goal;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kCount, goal.targetCount);
    await prefs.setInt(_kMinutes, goal.targetMinutes);
    await prefs.setString(_kGoal, goal.goal);
  }
}

final trainingGoalProvider =
    StateNotifierProvider<TrainingGoalNotifier, TrainingGoal>(
        (ref) => TrainingGoalNotifier());

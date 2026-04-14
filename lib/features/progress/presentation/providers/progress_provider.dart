import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../practice/domain/models/practice_session.dart';

// 주간 연습 데이터
class WeeklyData {
  final String day;
  final int minutes;
  const WeeklyData(this.day, this.minutes);
}

// 연습 기록 목록
final practiceHistoryProvider = StateProvider<List<PracticeSession>>((ref) {
  final rng = Random(42);
  final now = DateTime.now();
  return List.generate(8, (i) {
    final score = 60.0 + rng.nextDouble() * 38;
    final lessonTitles = ['도레미파솔라시도', '반짝반짝 작은별', '비행기', 'Am 코드'];
    return PracticeSession(
      id: 'hist_$i',
      lessonId: 'piano_00${(i % 3) + 1}',
      lessonTitle: lessonTitles[i % lessonTitles.length],
      userId: 'user',
      score: score,
      duration: Duration(minutes: 5 + rng.nextInt(10)),
      noteResults: [],
      createdAt: now.subtract(Duration(days: i, hours: rng.nextInt(12))),
      xpEarned: (score / 100 * 150).round(),
    );
  });
});

// 주간 연습 시간 (분)
final weeklyDataProvider = Provider<List<WeeklyData>>((ref) {
  final rng = Random(7);
  const days = ['월', '화', '수', '목', '금', '토', '일'];
  return days.map((d) => WeeklyData(d, rng.nextInt(40))).toList();
});

// 점수 히스토리 (최근 7회)
final scoreHistoryProvider = Provider<List<double>>((ref) {
  final history = ref.watch(practiceHistoryProvider);
  return history.take(7).map((s) => s.score).toList().reversed.toList();
});

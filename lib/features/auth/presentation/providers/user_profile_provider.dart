import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../features/auth/domain/models/user_profile.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../shared/providers/firebase_providers.dart';

// SharedPreferences 프로바이더
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

// 유저 프로필 상태 관리
class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  final Ref _ref;

  UserProfileNotifier(this._ref) : super(const AsyncValue.loading()) {
    _load();
  }

  void _load() {
    final user = _ref.read(currentUserProvider);
    if (user == null) {
      state = const AsyncValue.data(null);
      return;
    }

    // Firestore에서 프로필 로드
    final firestore = _ref.read(firestoreProvider);
    firestore.collection('users').doc(user.uid).get().then((doc) {
      if (doc.exists) {
        final data = doc.data()!;
        state = AsyncValue.data(UserProfile(
          uid: user.uid,
          displayName: data['displayName'] ?? user.displayName ?? '사용자',
          email: user.email ?? '',
          selectedInstrument: data['selectedInstrument'] ?? 'piano',
          level: data['level'] ?? 'beginner',
          totalPracticeMinutes: data['totalPracticeMinutes'] ?? 0,
          streakDays: data['streakDays'] ?? 0,
          xpPoints: data['xpPoints'] ?? 0,
          lastPracticeDate: data['lastPracticeDate'] != null
              ? DateTime.parse(data['lastPracticeDate'])
              : null,
          completedLessonIds:
              List<String>.from(data['completedLessonIds'] ?? []),
        ));
      } else {
        // 새 유저 기본 프로필
        state = AsyncValue.data(UserProfile(
          uid: user.uid,
          displayName: user.displayName ?? '사용자',
          email: user.email ?? '',
          selectedInstrument: 'piano',
          level: 'beginner',
          totalPracticeMinutes: 0,
          streakDays: 0,
          xpPoints: 0,
          completedLessonIds: [],
        ));
      }
    }).catchError((e) {
      // 오프라인 시 기본 데이터 사용
      state = AsyncValue.data(UserProfile(
        uid: user.uid,
        displayName: user.displayName ?? '사용자',
        email: user.email ?? '',
        selectedInstrument: 'piano',
        level: 'beginner',
        totalPracticeMinutes: _mockMinutes(),
        streakDays: _mockStreak(),
        xpPoints: _mockXp(),
        completedLessonIds: [],
      ));
    });
  }

  int _mockMinutes() => 30 + Random().nextInt(120);
  int _mockStreak() => 1 + Random().nextInt(7);
  int _mockXp() => 100 + Random().nextInt(500);

  Future<void> saveOnboarding(String instrument, String level) async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    final current = state.valueOrNull;
    final updated = (current ?? UserProfile(
      uid: user.uid,
      displayName: user.displayName ?? '사용자',
      email: user.email ?? '',
      selectedInstrument: instrument,
      level: level,
      totalPracticeMinutes: 0,
      streakDays: 0,
      xpPoints: 0,
      completedLessonIds: [],
    )).copyWith(selectedInstrument: instrument, level: level);

    state = AsyncValue.data(updated);

    try {
      await _ref.read(firestoreProvider).collection('users').doc(user.uid).set({
        'displayName': updated.displayName,
        'selectedInstrument': instrument,
        'level': level,
        'totalPracticeMinutes': updated.totalPracticeMinutes,
        'streakDays': updated.streakDays,
        'xpPoints': updated.xpPoints,
        'completedLessonIds': updated.completedLessonIds,
      });
    } catch (_) {}
  }

  Future<void> addXp(int xp, String lessonId) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final newCompleted = current.completedLessonIds.contains(lessonId)
        ? current.completedLessonIds
        : [...current.completedLessonIds, lessonId];

    final updated = current.copyWith(
      xpPoints: current.xpPoints + xp,
      totalPracticeMinutes: current.totalPracticeMinutes + 5,
      lastPracticeDate: DateTime.now(),
      completedLessonIds: newCompleted,
    );
    state = AsyncValue.data(updated);

    try {
      final user = _ref.read(currentUserProvider);
      if (user != null) {
        await _ref.read(firestoreProvider).collection('users').doc(user.uid).update({
          'xpPoints': updated.xpPoints,
          'totalPracticeMinutes': updated.totalPracticeMinutes,
          'lastPracticeDate': updated.lastPracticeDate?.toIso8601String(),
          'completedLessonIds': updated.completedLessonIds,
        });
      }
    } catch (_) {}
  }
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile?>>(
  (ref) => UserProfileNotifier(ref),
);

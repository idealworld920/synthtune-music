class UserProfile {
  final String uid;
  final String displayName;
  final String email;
  final String selectedInstrument;
  final String level;
  final int totalPracticeMinutes;
  final int streakDays;
  final int xpPoints;
  final DateTime? lastPracticeDate;
  final List<String> completedLessonIds;

  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.selectedInstrument,
    required this.level,
    required this.totalPracticeMinutes,
    required this.streakDays,
    required this.xpPoints,
    this.lastPracticeDate,
    required this.completedLessonIds,
  });

  UserProfile copyWith({
    String? displayName,
    String? selectedInstrument,
    String? level,
    int? totalPracticeMinutes,
    int? streakDays,
    int? xpPoints,
    DateTime? lastPracticeDate,
    List<String>? completedLessonIds,
  }) {
    return UserProfile(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email,
      selectedInstrument: selectedInstrument ?? this.selectedInstrument,
      level: level ?? this.level,
      totalPracticeMinutes: totalPracticeMinutes ?? this.totalPracticeMinutes,
      streakDays: streakDays ?? this.streakDays,
      xpPoints: xpPoints ?? this.xpPoints,
      lastPracticeDate: lastPracticeDate ?? this.lastPracticeDate,
      completedLessonIds: completedLessonIds ?? this.completedLessonIds,
    );
  }

  String get levelLabel {
    switch (level) {
      case 'beginner':
        return '입문자';
      case 'intermediate':
        return '중급자';
      case 'advanced':
        return '고급자';
      default:
        return level;
    }
  }

  int get currentLevel {
    if (xpPoints < 500) return 1;
    if (xpPoints < 1500) return 2;
    if (xpPoints < 3000) return 3;
    if (xpPoints < 5000) return 4;
    if (xpPoints < 8000) return 5;
    return 6;
  }

  int get xpForNextLevel {
    final levels = [500, 1500, 3000, 5000, 8000, 12000];
    final lvl = currentLevel;
    if (lvl > levels.length) return levels.last;
    return levels[lvl - 1];
  }

  double get xpProgress {
    final levels = [0, 500, 1500, 3000, 5000, 8000];
    final lvl = currentLevel - 1;
    final start = lvl < levels.length ? levels[lvl] : levels.last;
    final end = xpForNextLevel;
    if (end == start) return 1.0;
    return ((xpPoints - start) / (end - start)).clamp(0.0, 1.0);
  }
}

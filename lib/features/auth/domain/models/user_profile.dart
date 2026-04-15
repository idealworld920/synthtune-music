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

  // 레벨 시스템: 1단계=100EXP, 2단계=200EXP, 3단계=300EXP... (+100씩)
  int get currentLevel {
    int level = 1;
    int totalNeeded = 0;
    while (true) {
      totalNeeded += level * 100;
      if (xpPoints < totalNeeded) return level;
      level++;
      if (level > 99) return 99;
    }
  }

  // 현재 레벨 최대 EXP
  int get xpForCurrentLevel => currentLevel * 100;

  // 현재 레벨 시작 EXP
  int get _xpAtLevelStart {
    int total = 0;
    for (int i = 1; i < currentLevel; i++) {
      total += i * 100;
    }
    return total;
  }

  // 다음 레벨까지 필요한 총 EXP
  int get xpForNextLevel => _xpAtLevelStart + xpForCurrentLevel;

  // 현재 레벨 내 진행률
  double get xpProgress {
    final current = xpPoints - _xpAtLevelStart;
    final needed = xpForCurrentLevel;
    if (needed == 0) return 1.0;
    return (current / needed).clamp(0.0, 1.0);
  }

  // 현재 레벨 내 현재 EXP
  int get xpInCurrentLevel => xpPoints - _xpAtLevelStart;
}

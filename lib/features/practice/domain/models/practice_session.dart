class NoteResult {
  final String targetNoteName;
  final double targetFrequency;
  final double? detectedFrequency;
  final bool isHit;
  final double accuracy; // 0.0 ~ 1.0

  const NoteResult({
    required this.targetNoteName,
    required this.targetFrequency,
    this.detectedFrequency,
    required this.isHit,
    required this.accuracy,
  });
}

class PracticeSession {
  final String id;
  final String lessonId;
  final String lessonTitle;
  final String userId;
  final double score; // 0 ~ 100
  final Duration duration;
  final List<NoteResult> noteResults;
  final DateTime createdAt;
  final int xpEarned;

  const PracticeSession({
    required this.id,
    required this.lessonId,
    required this.lessonTitle,
    required this.userId,
    required this.score,
    required this.duration,
    required this.noteResults,
    required this.createdAt,
    required this.xpEarned,
  });

  String get scoreLabel {
    if (score >= 95) return 'S';
    if (score >= 85) return 'A';
    if (score >= 70) return 'B';
    if (score >= 55) return 'C';
    return 'D';
  }
}

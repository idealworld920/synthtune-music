class MusicNote {
  final String noteName;
  final double frequency;
  final double startTime;
  final double duration;
  final int order;

  const MusicNote({
    required this.noteName,
    required this.frequency,
    required this.startTime,
    required this.duration,
    required this.order,
  });
}

class Lesson {
  final String id;
  final String title;
  final String description;
  final String instrument;
  final String difficulty;
  final int durationMinutes;
  final String imageEmoji;
  final List<MusicNote> targetNotes;
  final int bpm;
  final bool isLocked;
  final int xpReward;
  final int orderIndex;
  final String category; // 'scale', 'nursery', 'classic'

  const Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.instrument,
    required this.difficulty,
    required this.durationMinutes,
    required this.imageEmoji,
    required this.targetNotes,
    required this.bpm,
    this.isLocked = false,
    required this.xpReward,
    required this.orderIndex,
    this.category = 'scale',
  });

  String get difficultyLabel {
    switch (difficulty) {
      case 'beginner':
        return '입문';
      case 'intermediate':
        return '중급';
      case 'advanced':
        return '고급';
      default:
        return difficulty;
    }
  }

  String get categoryLabel {
    switch (category) {
      case 'scale': return '기본 스케일';
      case 'nursery': return '동요';
      case 'classic': return '클래식';
      case 'skill': return '스킬';
      case 'my': return '나만의 음악';
      default: return category;
    }
  }

  String get instrumentLabel {
    switch (instrument) {
      case 'piano':
        return '피아노';
      case 'guitar':
        return '기타';
      case 'drums':
        return '드럼';
      case 'violin':
        return '바이올린';
      default:
        return instrument;
    }
  }
}

// 노트 주파수 상수
class NoteFrequency {
  static const double c4 = 261.63;
  static const double d4 = 293.66;
  static const double e4 = 329.63;
  static const double f4 = 349.23;
  static const double g4 = 392.00;
  static const double a4 = 440.00;
  static const double b4 = 493.88;
  static const double c5 = 523.25;
  static const double d5 = 587.33;
  static const double e5 = 659.25;
  static const double f5 = 698.46;
  static const double g5 = 783.99;
  static const double a5 = 880.00;
  static const double g3 = 196.00;
  static const double a3 = 220.00;
  static const double b3 = 246.94;
  static const double cSharp4 = 277.18;
  static const double dSharp4 = 311.13;
  static const double fSharp4 = 369.99;
  static const double gSharp4 = 415.30;
  static const double aSharp4 = 466.16;
  static const double d3 = 146.83;
  static const double g2 = 98.00;

  // 드럼 (성부별 기준 주파수)
  static const double drumKick  = 80.0;   // 킥
  static const double drumSnare = 200.0;  // 스네어
  static const double drumHihat = 600.0;  // 하이햇 (심벌)
}

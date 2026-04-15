import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/user_profile_provider.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../../domain/models/lesson.dart';

// 레슨 목데이터
final _allLessons = <Lesson>[
  // ─── 피아노 입문 ───
  Lesson(
    id: 'piano_001',
    title: '도레미파솔라시도',
    description: '피아노의 기초! C장조 음계를 연습해 봅시다. 각 건반의 위치를 익히고 부드럽게 연주해 보세요.',
    instrument: 'piano',
    difficulty: 'beginner',
    durationMinutes: 5,
    imageEmoji: '🎹',
    bpm: 60,
    xpReward: 100,
    orderIndex: 1,
    category: 'scale',
    targetNotes: [
      MusicNote(noteName: 'C4', frequency: NoteFrequency.c4, startTime: 0.0, duration: 1.0, order: 0),
      MusicNote(noteName: 'D4', frequency: NoteFrequency.d4, startTime: 1.0, duration: 1.0, order: 1),
      MusicNote(noteName: 'E4', frequency: NoteFrequency.e4, startTime: 2.0, duration: 1.0, order: 2),
      MusicNote(noteName: 'F4', frequency: NoteFrequency.f4, startTime: 3.0, duration: 1.0, order: 3),
      MusicNote(noteName: 'G4', frequency: NoteFrequency.g4, startTime: 4.0, duration: 1.0, order: 4),
      MusicNote(noteName: 'A4', frequency: NoteFrequency.a4, startTime: 5.0, duration: 1.0, order: 5),
      MusicNote(noteName: 'B4', frequency: NoteFrequency.b4, startTime: 6.0, duration: 1.0, order: 6),
      MusicNote(noteName: 'C5', frequency: NoteFrequency.c5, startTime: 7.0, duration: 1.0, order: 7),
    ],
  ),
  Lesson(
    id: 'piano_002',
    title: '반짝반짝 작은별',
    description: '누구나 아는 동요! 멜로디를 따라 피아노로 연주해 보세요.',
    instrument: 'piano',
    difficulty: 'beginner',
    durationMinutes: 8,
    imageEmoji: '⭐',
    bpm: 70,
    xpReward: 150,
    orderIndex: 2,
    category: 'nursery',
    targetNotes: [
      MusicNote(noteName: 'C4', frequency: NoteFrequency.c4, startTime: 0.0, duration: 0.8, order: 0),
      MusicNote(noteName: 'C4', frequency: NoteFrequency.c4, startTime: 0.8, duration: 0.8, order: 1),
      MusicNote(noteName: 'G4', frequency: NoteFrequency.g4, startTime: 1.6, duration: 0.8, order: 2),
      MusicNote(noteName: 'G4', frequency: NoteFrequency.g4, startTime: 2.4, duration: 0.8, order: 3),
      MusicNote(noteName: 'A4', frequency: NoteFrequency.a4, startTime: 3.2, duration: 0.8, order: 4),
      MusicNote(noteName: 'A4', frequency: NoteFrequency.a4, startTime: 4.0, duration: 0.8, order: 5),
      MusicNote(noteName: 'G4', frequency: NoteFrequency.g4, startTime: 4.8, duration: 1.6, order: 6),
      MusicNote(noteName: 'F4', frequency: NoteFrequency.f4, startTime: 6.4, duration: 0.8, order: 7),
      MusicNote(noteName: 'F4', frequency: NoteFrequency.f4, startTime: 7.2, duration: 0.8, order: 8),
      MusicNote(noteName: 'E4', frequency: NoteFrequency.e4, startTime: 8.0, duration: 0.8, order: 9),
      MusicNote(noteName: 'E4', frequency: NoteFrequency.e4, startTime: 8.8, duration: 0.8, order: 10),
      MusicNote(noteName: 'D4', frequency: NoteFrequency.d4, startTime: 9.6, duration: 0.8, order: 11),
      MusicNote(noteName: 'D4', frequency: NoteFrequency.d4, startTime: 10.4, duration: 0.8, order: 12),
      MusicNote(noteName: 'C4', frequency: NoteFrequency.c4, startTime: 11.2, duration: 1.6, order: 13),
    ],
  ),
  Lesson(
    id: 'piano_003',
    title: '비행기',
    description: '경쾌한 동요 "비행기"를 피아노로 연주해 봅시다.',
    instrument: 'piano',
    difficulty: 'beginner',
    durationMinutes: 8,
    imageEmoji: '✈️',
    bpm: 80,
    xpReward: 150,
    orderIndex: 3,
    category: 'nursery',
    targetNotes: [
      MusicNote(noteName: 'C4', frequency: NoteFrequency.c4, startTime: 0.0, duration: 0.75, order: 0),
      MusicNote(noteName: 'E4', frequency: NoteFrequency.e4, startTime: 0.75, duration: 0.75, order: 1),
      MusicNote(noteName: 'G4', frequency: NoteFrequency.g4, startTime: 1.5, duration: 1.5, order: 2),
      MusicNote(noteName: 'G4', frequency: NoteFrequency.g4, startTime: 3.0, duration: 0.75, order: 3),
      MusicNote(noteName: 'E4', frequency: NoteFrequency.e4, startTime: 3.75, duration: 0.75, order: 4),
      MusicNote(noteName: 'G4', frequency: NoteFrequency.g4, startTime: 4.5, duration: 1.5, order: 5),
      MusicNote(noteName: 'A4', frequency: NoteFrequency.a4, startTime: 6.0, duration: 0.75, order: 6),
      MusicNote(noteName: 'A4', frequency: NoteFrequency.a4, startTime: 6.75, duration: 0.75, order: 7),
      MusicNote(noteName: 'G4', frequency: NoteFrequency.g4, startTime: 7.5, duration: 1.5, order: 8),
    ],
  ),
  Lesson(
    id: 'piano_s01',
    title: 'G장조 음계',
    description: 'G장조 스케일을 연습합니다. #파(F#)에 주의하세요.',
    instrument: 'piano',
    difficulty: 'beginner',
    durationMinutes: 5,
    imageEmoji: '🎹',
    bpm: 60,
    xpReward: 100,
    orderIndex: 2,
    category: 'scale',
    targetNotes: [
      MusicNote(noteName: 'G4', frequency: NoteFrequency.g4, startTime: 0.0, duration: 1.0, order: 0),
      MusicNote(noteName: 'A4', frequency: NoteFrequency.a4, startTime: 1.0, duration: 1.0, order: 1),
      MusicNote(noteName: 'B4', frequency: NoteFrequency.b4, startTime: 2.0, duration: 1.0, order: 2),
      MusicNote(noteName: 'C5', frequency: NoteFrequency.c5, startTime: 3.0, duration: 1.0, order: 3),
      MusicNote(noteName: 'D5', frequency: NoteFrequency.d5, startTime: 4.0, duration: 1.0, order: 4),
      MusicNote(noteName: 'E5', frequency: NoteFrequency.e5, startTime: 5.0, duration: 1.0, order: 5),
      MusicNote(noteName: 'F#4', frequency: NoteFrequency.fSharp4, startTime: 6.0, duration: 1.0, order: 6),
      MusicNote(noteName: 'G5', frequency: NoteFrequency.g5, startTime: 7.0, duration: 1.0, order: 7),
    ],
  ),
  Lesson(
    id: 'piano_n01',
    title: '나비야 나비야',
    description: '한국 대표 동요! 쉽고 즐거운 멜로디를 피아노로 연주해 보세요.',
    instrument: 'piano',
    difficulty: 'beginner',
    durationMinutes: 6,
    imageEmoji: '🦋',
    bpm: 80,
    xpReward: 130,
    orderIndex: 3,
    category: 'nursery',
    targetNotes: [
      MusicNote(noteName: 'G4', frequency: NoteFrequency.g4, startTime: 0.0, duration: 0.75, order: 0),
      MusicNote(noteName: 'E4', frequency: NoteFrequency.e4, startTime: 0.75, duration: 0.75, order: 1),
      MusicNote(noteName: 'E4', frequency: NoteFrequency.e4, startTime: 1.5, duration: 1.5, order: 2),
      MusicNote(noteName: 'F4', frequency: NoteFrequency.f4, startTime: 3.0, duration: 0.75, order: 3),
      MusicNote(noteName: 'D4', frequency: NoteFrequency.d4, startTime: 3.75, duration: 0.75, order: 4),
      MusicNote(noteName: 'D4', frequency: NoteFrequency.d4, startTime: 4.5, duration: 1.5, order: 5),
      MusicNote(noteName: 'C4', frequency: NoteFrequency.c4, startTime: 6.0, duration: 0.75, order: 6),
      MusicNote(noteName: 'D4', frequency: NoteFrequency.d4, startTime: 6.75, duration: 0.75, order: 7),
      MusicNote(noteName: 'E4', frequency: NoteFrequency.e4, startTime: 7.5, duration: 0.75, order: 8),
      MusicNote(noteName: 'F4', frequency: NoteFrequency.f4, startTime: 8.25, duration: 0.75, order: 9),
      MusicNote(noteName: 'G4', frequency: NoteFrequency.g4, startTime: 9.0, duration: 0.75, order: 10),
      MusicNote(noteName: 'G4', frequency: NoteFrequency.g4, startTime: 9.75, duration: 0.75, order: 11),
      MusicNote(noteName: 'G4', frequency: NoteFrequency.g4, startTime: 10.5, duration: 1.5, order: 12),
    ],
  ),
  Lesson(
    id: 'piano_n02',
    title: '곰 세 마리',
    description: '엄마곰 아빠곰 애기곰! 아이들이 좋아하는 동요를 피아노로 연주해 보세요.',
    instrument: 'piano',
    difficulty: 'beginner',
    durationMinutes: 7,
    imageEmoji: '🐻',
    bpm: 85,
    xpReward: 140,
    orderIndex: 4,
    category: 'nursery',
    targetNotes: [
      MusicNote(noteName: 'C4', frequency: NoteFrequency.c4, startTime: 0.0, duration: 0.7, order: 0),
      MusicNote(noteName: 'D4', frequency: NoteFrequency.d4, startTime: 0.7, duration: 0.7, order: 1),
      MusicNote(noteName: 'E4', frequency: NoteFrequency.e4, startTime: 1.4, duration: 0.7, order: 2),
      MusicNote(noteName: 'C4', frequency: NoteFrequency.c4, startTime: 2.1, duration: 0.7, order: 3),
      MusicNote(noteName: 'C4', frequency: NoteFrequency.c4, startTime: 2.8, duration: 0.7, order: 4),
      MusicNote(noteName: 'D4', frequency: NoteFrequency.d4, startTime: 3.5, duration: 0.7, order: 5),
      MusicNote(noteName: 'E4', frequency: NoteFrequency.e4, startTime: 4.2, duration: 0.7, order: 6),
      MusicNote(noteName: 'C4', frequency: NoteFrequency.c4, startTime: 4.9, duration: 0.7, order: 7),
      MusicNote(noteName: 'E4', frequency: NoteFrequency.e4, startTime: 5.6, duration: 0.7, order: 8),
      MusicNote(noteName: 'F4', frequency: NoteFrequency.f4, startTime: 6.3, duration: 0.7, order: 9),
      MusicNote(noteName: 'G4', frequency: NoteFrequency.g4, startTime: 7.0, duration: 1.4, order: 10),
    ],
  ),
  Lesson(
    id: 'piano_n03',
    title: '산토끼',
    description: '산토끼 토끼야! 신나는 동요를 피아노로 연주해 봅시다.',
    instrument: 'piano',
    difficulty: 'beginner',
    durationMinutes: 7,
    imageEmoji: '🐰',
    bpm: 90,
    xpReward: 140,
    orderIndex: 5,
    category: 'nursery',
    targetNotes: [
      MusicNote(noteName: 'E4', frequency: NoteFrequency.e4, startTime: 0.0, duration: 0.66, order: 0),
      MusicNote(noteName: 'E4', frequency: NoteFrequency.e4, startTime: 0.66, duration: 0.66, order: 1),
      MusicNote(noteName: 'F4', frequency: NoteFrequency.f4, startTime: 1.32, duration: 0.66, order: 2),
      MusicNote(noteName: 'G4', frequency: NoteFrequency.g4, startTime: 1.98, duration: 0.66, order: 3),
      MusicNote(noteName: 'G4', frequency: NoteFrequency.g4, startTime: 2.64, duration: 0.66, order: 4),
      MusicNote(noteName: 'F4', frequency: NoteFrequency.f4, startTime: 3.3, duration: 0.66, order: 5),
      MusicNote(noteName: 'E4', frequency: NoteFrequency.e4, startTime: 3.96, duration: 0.66, order: 6),
      MusicNote(noteName: 'D4', frequency: NoteFrequency.d4, startTime: 4.62, duration: 0.66, order: 7),
      MusicNote(noteName: 'C4', frequency: NoteFrequency.c4, startTime: 5.28, duration: 0.66, order: 8),
      MusicNote(noteName: 'C4', frequency: NoteFrequency.c4, startTime: 5.94, duration: 0.66, order: 9),
      MusicNote(noteName: 'D4', frequency: NoteFrequency.d4, startTime: 6.6, duration: 0.66, order: 10),
      MusicNote(noteName: 'E4', frequency: NoteFrequency.e4, startTime: 7.26, duration: 1.32, order: 11),
    ],
  ),
  Lesson(
    id: 'piano_c01',
    title: '환희의 송가 (베토벤)',
    description: '베토벤 교향곡 9번의 유명한 선율! 간단한 멜로디로 클래식에 입문해 보세요.',
    instrument: 'piano',
    difficulty: 'intermediate',
    durationMinutes: 10,
    imageEmoji: '🎼',
    bpm: 80,
    xpReward: 250,
    orderIndex: 6,
    category: 'classic',
    isLocked: true,
    targetNotes: [
      MusicNote(noteName: 'E4', frequency: NoteFrequency.e4, startTime: 0.0, duration: 0.75, order: 0),
      MusicNote(noteName: 'E4', frequency: NoteFrequency.e4, startTime: 0.75, duration: 0.75, order: 1),
      MusicNote(noteName: 'F4', frequency: NoteFrequency.f4, startTime: 1.5, duration: 0.75, order: 2),
      MusicNote(noteName: 'G4', frequency: NoteFrequency.g4, startTime: 2.25, duration: 0.75, order: 3),
      MusicNote(noteName: 'G4', frequency: NoteFrequency.g4, startTime: 3.0, duration: 0.75, order: 4),
      MusicNote(noteName: 'F4', frequency: NoteFrequency.f4, startTime: 3.75, duration: 0.75, order: 5),
      MusicNote(noteName: 'E4', frequency: NoteFrequency.e4, startTime: 4.5, duration: 0.75, order: 6),
      MusicNote(noteName: 'D4', frequency: NoteFrequency.d4, startTime: 5.25, duration: 0.75, order: 7),
      MusicNote(noteName: 'C4', frequency: NoteFrequency.c4, startTime: 6.0, duration: 0.75, order: 8),
      MusicNote(noteName: 'C4', frequency: NoteFrequency.c4, startTime: 6.75, duration: 0.75, order: 9),
      MusicNote(noteName: 'D4', frequency: NoteFrequency.d4, startTime: 7.5, duration: 0.75, order: 10),
      MusicNote(noteName: 'E4', frequency: NoteFrequency.e4, startTime: 8.25, duration: 0.75, order: 11),
      MusicNote(noteName: 'E4', frequency: NoteFrequency.e4, startTime: 9.0, duration: 1.1, order: 12),
      MusicNote(noteName: 'D4', frequency: NoteFrequency.d4, startTime: 10.1, duration: 0.4, order: 13),
      MusicNote(noteName: 'D4', frequency: NoteFrequency.d4, startTime: 10.5, duration: 1.5, order: 14),
    ],
  ),
  Lesson(
    id: 'piano_004',
    title: '엘리제를 위하여 (인트로)',
    description: '베토벤의 명곡! 가장 유명한 클래식 피아노 곡의 도입부를 배워봅시다.',
    instrument: 'piano',
    difficulty: 'intermediate',
    durationMinutes: 15,
    imageEmoji: '🎼',
    bpm: 90,
    xpReward: 300,
    orderIndex: 4,
    category: 'classic',
    isLocked: true,
    targetNotes: [
      MusicNote(noteName: 'E4', frequency: NoteFrequency.e4, startTime: 0.0, duration: 0.5, order: 0),
      MusicNote(noteName: 'D#4', frequency: NoteFrequency.dSharp4, startTime: 0.5, duration: 0.5, order: 1),
      MusicNote(noteName: 'E4', frequency: NoteFrequency.e4, startTime: 1.0, duration: 0.5, order: 2),
      MusicNote(noteName: 'D#4', frequency: NoteFrequency.dSharp4, startTime: 1.5, duration: 0.5, order: 3),
      MusicNote(noteName: 'E4', frequency: NoteFrequency.e4, startTime: 2.0, duration: 0.5, order: 4),
      MusicNote(noteName: 'B3', frequency: NoteFrequency.b3, startTime: 2.5, duration: 0.5, order: 5),
      MusicNote(noteName: 'D4', frequency: NoteFrequency.d4, startTime: 3.0, duration: 0.5, order: 6),
      MusicNote(noteName: 'C4', frequency: NoteFrequency.c4, startTime: 3.5, duration: 0.5, order: 7),
      MusicNote(noteName: 'A3', frequency: NoteFrequency.a3, startTime: 4.0, duration: 1.0, order: 8),
    ],
  ),

  // ─── 드럼 입문 ───
  Lesson(
    id: 'drums_001',
    title: '드럼 기초 - 4비트 패턴',
    description: '드럼의 기본! 킥(K)과 스네어(S)로 가장 기본적인 4비트 리듬을 익혀봅시다.',
    instrument: 'drums',
    difficulty: 'beginner',
    durationMinutes: 8,
    imageEmoji: '🥁',
    bpm: 70,
    xpReward: 120,
    orderIndex: 1,
    category: 'scale',
    targetNotes: [
      MusicNote(noteName: '킥', frequency: NoteFrequency.drumKick, startTime: 0.0, duration: 0.5, order: 0),
      MusicNote(noteName: '스네어', frequency: NoteFrequency.drumSnare, startTime: 1.0, duration: 0.5, order: 1),
      MusicNote(noteName: '킥', frequency: NoteFrequency.drumKick, startTime: 2.0, duration: 0.5, order: 2),
      MusicNote(noteName: '스네어', frequency: NoteFrequency.drumSnare, startTime: 3.0, duration: 0.5, order: 3),
      MusicNote(noteName: '킥', frequency: NoteFrequency.drumKick, startTime: 4.0, duration: 0.5, order: 4),
      MusicNote(noteName: '스네어', frequency: NoteFrequency.drumSnare, startTime: 5.0, duration: 0.5, order: 5),
      MusicNote(noteName: '킥', frequency: NoteFrequency.drumKick, startTime: 6.0, duration: 0.5, order: 6),
      MusicNote(noteName: '스네어', frequency: NoteFrequency.drumSnare, startTime: 7.0, duration: 0.5, order: 7),
    ],
  ),
  Lesson(
    id: 'drums_002',
    title: '드럼 기초 - 하이햇 추가',
    description: '킥·스네어에 하이햇(HH)을 더해 풍성한 8비트 리듬을 만들어 보세요.',
    instrument: 'drums',
    difficulty: 'beginner',
    durationMinutes: 10,
    imageEmoji: '🎶',
    bpm: 80,
    xpReward: 150,
    orderIndex: 2,
    category: 'scale',
    targetNotes: [
      MusicNote(noteName: '하이햇', frequency: NoteFrequency.drumHihat, startTime: 0.0, duration: 0.4, order: 0),
      MusicNote(noteName: '킥', frequency: NoteFrequency.drumKick, startTime: 0.0, duration: 0.4, order: 1),
      MusicNote(noteName: '하이햇', frequency: NoteFrequency.drumHihat, startTime: 0.5, duration: 0.4, order: 2),
      MusicNote(noteName: '스네어', frequency: NoteFrequency.drumSnare, startTime: 1.0, duration: 0.4, order: 3),
      MusicNote(noteName: '하이햇', frequency: NoteFrequency.drumHihat, startTime: 1.5, duration: 0.4, order: 4),
      MusicNote(noteName: '킥', frequency: NoteFrequency.drumKick, startTime: 2.0, duration: 0.4, order: 5),
      MusicNote(noteName: '하이햇', frequency: NoteFrequency.drumHihat, startTime: 2.5, duration: 0.4, order: 6),
      MusicNote(noteName: '스네어', frequency: NoteFrequency.drumSnare, startTime: 3.0, duration: 0.4, order: 7),
    ],
  ),
  Lesson(
    id: 'drums_003',
    title: '드럼 - 록 비트',
    description: '록 음악의 기본 드럼 패턴을 배워봅시다. 에너지 넘치는 리듬!',
    instrument: 'drums',
    difficulty: 'intermediate',
    durationMinutes: 12,
    imageEmoji: '🤘',
    bpm: 100,
    xpReward: 250,
    orderIndex: 3,
    category: 'scale',
    isLocked: true,
    targetNotes: [
      MusicNote(noteName: '킥', frequency: NoteFrequency.drumKick, startTime: 0.0, duration: 0.3, order: 0),
      MusicNote(noteName: '킥', frequency: NoteFrequency.drumKick, startTime: 0.3, duration: 0.3, order: 1),
      MusicNote(noteName: '스네어', frequency: NoteFrequency.drumSnare, startTime: 0.6, duration: 0.3, order: 2),
      MusicNote(noteName: '킥', frequency: NoteFrequency.drumKick, startTime: 0.9, duration: 0.3, order: 3),
      MusicNote(noteName: '킥', frequency: NoteFrequency.drumKick, startTime: 1.2, duration: 0.3, order: 4),
      MusicNote(noteName: '스네어', frequency: NoteFrequency.drumSnare, startTime: 1.5, duration: 0.3, order: 5),
      MusicNote(noteName: '킥', frequency: NoteFrequency.drumKick, startTime: 1.8, duration: 0.3, order: 6),
      MusicNote(noteName: '스네어', frequency: NoteFrequency.drumSnare, startTime: 2.1, duration: 0.3, order: 7),
    ],
  ),

  // ─── 바이올린 입문 ───
  Lesson(
    id: 'violin_001',
    title: '바이올린 개방현 4개',
    description: '바이올린의 4개 개방현(G·D·A·E)을 활로 올바르게 긋는 연습을 시작해 봅시다.',
    instrument: 'violin',
    difficulty: 'beginner',
    durationMinutes: 8,
    imageEmoji: '🎻',
    bpm: 50,
    xpReward: 120,
    orderIndex: 1,
    category: 'scale',
    targetNotes: [
      MusicNote(noteName: 'G3', frequency: NoteFrequency.g3, startTime: 0.0, duration: 2.0, order: 0),
      MusicNote(noteName: 'D4', frequency: NoteFrequency.d4, startTime: 2.0, duration: 2.0, order: 1),
      MusicNote(noteName: 'A4', frequency: NoteFrequency.a4, startTime: 4.0, duration: 2.0, order: 2),
      MusicNote(noteName: 'E5', frequency: NoteFrequency.e5, startTime: 6.0, duration: 2.0, order: 3),
    ],
  ),
  Lesson(
    id: 'violin_002',
    title: '반짝반짝 작은별 (바이올린)',
    description: '바이올린으로 반짝반짝 작은별을 연주해 봅시다. A현을 주로 사용합니다.',
    instrument: 'violin',
    difficulty: 'beginner',
    durationMinutes: 10,
    imageEmoji: '⭐',
    bpm: 65,
    xpReward: 160,
    orderIndex: 2,
    category: 'nursery',
    targetNotes: [
      MusicNote(noteName: 'A4', frequency: NoteFrequency.a4, startTime: 0.0, duration: 0.8, order: 0),
      MusicNote(noteName: 'A4', frequency: NoteFrequency.a4, startTime: 0.8, duration: 0.8, order: 1),
      MusicNote(noteName: 'E5', frequency: NoteFrequency.e5, startTime: 1.6, duration: 0.8, order: 2),
      MusicNote(noteName: 'E5', frequency: NoteFrequency.e5, startTime: 2.4, duration: 0.8, order: 3),
      MusicNote(noteName: 'F5', frequency: NoteFrequency.f5, startTime: 3.2, duration: 0.8, order: 4),
      MusicNote(noteName: 'F5', frequency: NoteFrequency.f5, startTime: 4.0, duration: 0.8, order: 5),
      MusicNote(noteName: 'E5', frequency: NoteFrequency.e5, startTime: 4.8, duration: 1.6, order: 6),
      MusicNote(noteName: 'D5', frequency: NoteFrequency.d5, startTime: 6.4, duration: 0.8, order: 7),
      MusicNote(noteName: 'D5', frequency: NoteFrequency.d5, startTime: 7.2, duration: 0.8, order: 8),
      MusicNote(noteName: 'C5', frequency: NoteFrequency.c5, startTime: 8.0, duration: 0.8, order: 9),
      MusicNote(noteName: 'C5', frequency: NoteFrequency.c5, startTime: 8.8, duration: 0.8, order: 10),
      MusicNote(noteName: 'B4', frequency: NoteFrequency.b4, startTime: 9.6, duration: 0.8, order: 11),
      MusicNote(noteName: 'A4', frequency: NoteFrequency.a4, startTime: 10.4, duration: 1.6, order: 12),
    ],
  ),
  Lesson(
    id: 'violin_003',
    title: '아리랑 (바이올린)',
    description: '바이올린으로 연주하는 아리랑. D현과 A현을 번갈아 사용합니다.',
    instrument: 'violin',
    difficulty: 'intermediate',
    durationMinutes: 12,
    imageEmoji: '🇰🇷',
    bpm: 70,
    xpReward: 260,
    orderIndex: 3,
    category: 'classic',
    isLocked: true,
    targetNotes: [
      MusicNote(noteName: 'E5', frequency: NoteFrequency.e5, startTime: 0.0, duration: 0.8, order: 0),
      MusicNote(noteName: 'D5', frequency: NoteFrequency.d5, startTime: 0.8, duration: 0.8, order: 1),
      MusicNote(noteName: 'B4', frequency: NoteFrequency.b4, startTime: 1.6, duration: 1.6, order: 2),
      MusicNote(noteName: 'A4', frequency: NoteFrequency.a4, startTime: 3.2, duration: 0.8, order: 3),
      MusicNote(noteName: 'B4', frequency: NoteFrequency.b4, startTime: 4.0, duration: 1.6, order: 4),
      MusicNote(noteName: 'D5', frequency: NoteFrequency.d5, startTime: 5.6, duration: 0.8, order: 5),
      MusicNote(noteName: 'E5', frequency: NoteFrequency.e5, startTime: 6.4, duration: 1.6, order: 6),
    ],
  ),

  Lesson(
    id: 'violin_n01',
    title: '나비야 나비야 (바이올린)',
    description: '동요 나비야를 바이올린으로 연주해 봅시다. A현과 E현을 사용합니다.',
    instrument: 'violin',
    difficulty: 'beginner',
    durationMinutes: 8,
    imageEmoji: '🦋',
    bpm: 75,
    xpReward: 150,
    orderIndex: 3,
    category: 'nursery',
    targetNotes: [
      MusicNote(noteName: 'E5', frequency: NoteFrequency.e5, startTime: 0.0, duration: 0.8, order: 0),
      MusicNote(noteName: 'C5', frequency: NoteFrequency.c5, startTime: 0.8, duration: 0.8, order: 1),
      MusicNote(noteName: 'C5', frequency: NoteFrequency.c5, startTime: 1.6, duration: 1.6, order: 2),
      MusicNote(noteName: 'D5', frequency: NoteFrequency.d5, startTime: 3.2, duration: 0.8, order: 3),
      MusicNote(noteName: 'B4', frequency: NoteFrequency.b4, startTime: 4.0, duration: 0.8, order: 4),
      MusicNote(noteName: 'B4', frequency: NoteFrequency.b4, startTime: 4.8, duration: 1.6, order: 5),
      MusicNote(noteName: 'A4', frequency: NoteFrequency.a4, startTime: 6.4, duration: 0.8, order: 6),
      MusicNote(noteName: 'B4', frequency: NoteFrequency.b4, startTime: 7.2, duration: 0.8, order: 7),
      MusicNote(noteName: 'C5', frequency: NoteFrequency.c5, startTime: 8.0, duration: 0.8, order: 8),
      MusicNote(noteName: 'D5', frequency: NoteFrequency.d5, startTime: 8.8, duration: 0.8, order: 9),
      MusicNote(noteName: 'E5', frequency: NoteFrequency.e5, startTime: 9.6, duration: 0.8, order: 10),
      MusicNote(noteName: 'E5', frequency: NoteFrequency.e5, startTime: 10.4, duration: 1.6, order: 11),
    ],
  ),

  // ─── 기타 입문 ───
  Lesson(
    id: 'guitar_001',
    title: '기타 기초 - Am 코드',
    description: 'Am 코드는 기타의 시작! 올바른 운지법으로 맑은 소리를 내는 방법을 배워봅시다.',
    instrument: 'guitar',
    difficulty: 'beginner',
    durationMinutes: 10,
    imageEmoji: '🎸',
    bpm: 60,
    xpReward: 120,
    orderIndex: 1,
    category: 'scale',
    targetNotes: [
      MusicNote(noteName: 'A2', frequency: 110.00, startTime: 0.0, duration: 2.0, order: 0),
      MusicNote(noteName: 'A2', frequency: 110.00, startTime: 2.0, duration: 2.0, order: 1),
      MusicNote(noteName: 'A2', frequency: 110.00, startTime: 4.0, duration: 2.0, order: 2),
      MusicNote(noteName: 'A2', frequency: 110.00, startTime: 6.0, duration: 2.0, order: 3),
    ],
  ),
  Lesson(
    id: 'guitar_002',
    title: '기타 기초 - G 코드',
    description: 'G 코드를 마스터하면 수많은 노래를 연주할 수 있어요. Am과 함께 연습해 봅시다.',
    instrument: 'guitar',
    difficulty: 'beginner',
    durationMinutes: 10,
    imageEmoji: '🎵',
    bpm: 60,
    xpReward: 120,
    orderIndex: 2,
    category: 'scale',
    targetNotes: [
      MusicNote(noteName: 'G2', frequency: 98.00, startTime: 0.0, duration: 2.0, order: 0),
      MusicNote(noteName: 'G2', frequency: 98.00, startTime: 2.0, duration: 2.0, order: 1),
      MusicNote(noteName: 'G2', frequency: 98.00, startTime: 4.0, duration: 2.0, order: 2),
      MusicNote(noteName: 'G2', frequency: 98.00, startTime: 6.0, duration: 2.0, order: 3),
    ],
  ),
  Lesson(
    id: 'guitar_003',
    title: '아리랑',
    description: '우리나라 대표 민요 아리랑을 기타로 연주해 봅시다.',
    instrument: 'guitar',
    difficulty: 'intermediate',
    durationMinutes: 12,
    imageEmoji: '🇰🇷',
    bpm: 75,
    xpReward: 250,
    orderIndex: 3,
    category: 'classic',
    isLocked: true,
    targetNotes: [
      MusicNote(noteName: 'E4', frequency: NoteFrequency.e4, startTime: 0.0, duration: 0.8, order: 0),
      MusicNote(noteName: 'D4', frequency: NoteFrequency.d4, startTime: 0.8, duration: 0.8, order: 1),
      MusicNote(noteName: 'B3', frequency: NoteFrequency.b3, startTime: 1.6, duration: 1.6, order: 2),
      MusicNote(noteName: 'A3', frequency: NoteFrequency.a3, startTime: 3.2, duration: 0.8, order: 3),
      MusicNote(noteName: 'B3', frequency: NoteFrequency.b3, startTime: 4.0, duration: 1.6, order: 4),
    ],
  ),
];

// 전체 레슨 목록 프로바이더
final lessonListProvider = Provider<List<Lesson>>((ref) => _allLessons);

// 악기별 필터 프로바이더
final selectedInstrumentFilterProvider = StateProvider<String>((ref) => 'all');

// 카테고리 필터 프로바이더
final selectedCategoryFilterProvider = StateProvider<String>((ref) => 'all');

// 필터링된 레슨 목록 (구독 티어 + 카테고리 반영)
final filteredLessonsProvider = Provider<List<Lesson>>((ref) {
  final instrumentFilter = ref.watch(selectedInstrumentFilterProvider);
  final categoryFilter = ref.watch(selectedCategoryFilterProvider);
  final lessons = ref.watch(lessonListProvider);
  final isStandard = ref.watch(isStandardOrAboveProvider);
  final profile = ref.watch(userProfileProvider).valueOrNull;
  final selectedInstrument = profile?.selectedInstrument ?? 'piano';

  var result = lessons.toList();

  // 악기 필터
  if (instrumentFilter == 'all') {
    if (!isStandard) {
      result = result.where((l) => l.instrument == selectedInstrument).toList();
    }
  } else {
    result = result.where((l) => l.instrument == instrumentFilter).toList();
  }

  // 카테고리 필터
  if (categoryFilter != 'all') {
    result = result.where((l) => l.category == categoryFilter).toList();
  }

  return result;
});

// 특정 레슨 가져오기
final lessonByIdProvider = Provider.family<Lesson?, String>((ref, id) {
  return ref.watch(lessonListProvider).cast<Lesson?>().firstWhere(
    (l) => l?.id == id,
    orElse: () => null,
  );
});

// 추천 레슨 (입문 중 처음 3개)
final featuredLessonsProvider = Provider<List<Lesson>>((ref) {
  return ref
      .watch(lessonListProvider)
      .where((l) => l.difficulty == 'beginner')
      .take(3)
      .toList();
});

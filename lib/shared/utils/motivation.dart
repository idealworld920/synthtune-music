import 'dart:math';

final _rng = Random();

/// 연습 시작 전 응원
String getStartMotivation() {
  const msgs = [
    '오늘도 한 걸음 성장하는 시간!',
    '매일 연습하는 당신은 이미 대단해요!',
    '자, 악보를 펼치고 시작해봅시다!',
    '실수해도 괜찮아요. 연습이니까!',
    '집중! 오늘의 연습이 내일의 실력입니다.',
    '좋아하는 음악을 연주할 수 있다는 건 정말 멋진 일이에요!',
    '어제보다 조금만 더! 그게 성장의 비결이에요.',
    '깊게 숨 한번 쉬고, 편안하게 시작해요.',
    '당신의 연주를 기대하고 있어요!',
    '음악은 마음의 언어. 오늘도 아름다운 대화를 시작해봐요.',
  ];
  return msgs[_rng.nextInt(msgs.length)];
}

/// 녹음 중 격려
String getRecordingEncouragement() {
  const msgs = [
    '잘하고 있어요! 계속 가보세요!',
    '집중하세요! 소리에 귀 기울여봐요.',
    '리듬을 느끼며 연주해보세요!',
    '좋은 흐름이에요! 유지해봐요!',
    '실수는 성장의 증거예요!',
  ];
  return msgs[_rng.nextInt(msgs.length)];
}

/// 점수별 결과 응원
String getScoreMotivation(double score) {
  if (score >= 95) {
    const msgs = ['완벽해요! 프로급 연주입니다!', '놀랍습니다! 천재 아닌가요?', '만점에 가까운 연주! 자랑스러워요!'];
    return msgs[_rng.nextInt(msgs.length)];
  }
  if (score >= 85) {
    const msgs = ['훌륭해요! 거의 완벽합니다!', '대단해요! 조금만 다듬으면 완벽!', '최고의 연주에요! 계속 이렇게!'];
    return msgs[_rng.nextInt(msgs.length)];
  }
  if (score >= 70) {
    const msgs = ['잘했어요! 실력이 많이 늘었네요!', '좋은 연주예요! 한두 군데만 더 연습하면 완벽!', '착실하게 성장하고 있어요!'];
    return msgs[_rng.nextInt(msgs.length)];
  }
  if (score >= 55) {
    const msgs = ['괜찮아요! 연습하면 반드시 늘어요!', '포기하지 마세요! 이 정도면 좋은 시작이에요!', '어려운 부분만 반복하면 금방 좋아져요!'];
    return msgs[_rng.nextInt(msgs.length)];
  }
  const msgs = ['첫 걸음을 뗐다는 게 중요해요!', '모든 프로도 처음엔 이랬어요. 계속 도전!', '도전 자체가 대단한 거예요! 다시 해봐요!'];
  return msgs[_rng.nextInt(msgs.length)];
}

/// 스트릭 응원
String getStreakMotivation(int streakDays) {
  if (streakDays >= 30) return '$streakDays일 연속 연습! 당신은 진정한 음악인입니다!';
  if (streakDays >= 14) return '$streakDays일 연속! 습관이 되고 있어요!';
  if (streakDays >= 7) return '일주일 연속 연습! 대단해요!';
  if (streakDays >= 3) return '$streakDays일 연속! 이 페이스 유지해요!';
  return '오늘도 연습하러 오셨군요! 멋져요!';
}
